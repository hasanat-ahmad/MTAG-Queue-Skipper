// Runs ../firestore.rules against the Firestore emulator: `npm test`.
import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  setLogLevel,
  updateDoc,
} from 'firebase/firestore';

// Denied writes are the expected outcome of most tests; do not log them.
setLogLevel('silent');

const RIDER = 'rider1';
const OTHER_RIDER = 'rider2';

const BIKE = {
  plateNumber: 'ICT-1234',
  engineNo: 'E1234567',
  chasisNumber: 'C7654321',
  brand: 'Honda',
  color: 'Black',
  year: '2021',
};

// The same field mask the app's FirestoreService.saveUserAndBike uses.
const REGISTRATION_FIELDS = [
  'email',
  'name',
  'cnic',
  'phoneNumber',
  'updatedAt',
  'bikeRegistration.bikeDetails',
];

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-mtag',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

/** Firestore as seen by a signed-in rider. */
function riderDb(uid = RIDER) {
  return env.authenticatedContext(uid, { email: `${uid}@example.com` }).firestore();
}

function riderDoc(uid = RIDER, asUid = uid) {
  return doc(riderDb(asUid), 'users', uid);
}

/** Writes as the server (Admin SDK / Cloud Functions bypass the rules). */
async function seed(data, uid = RIDER) {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', uid), data);
  });
}

async function readAsServer(uid = RIDER) {
  let data;
  await env.withSecurityRulesDisabled(async (context) => {
    data = (await getDoc(doc(context.firestore(), 'users', uid))).data();
  });
  return data;
}

function registration(overrides = {}) {
  return {
    email: `${RIDER}@example.com`,
    name: 'Ali Khan',
    cnic: '3520212345671',
    phoneNumber: '03001234567',
    bikeRegistration: { bikeDetails: BIKE },
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

function saveRegistration(data, ref = riderDoc()) {
  return setDoc(ref, data, { mergeFields: REGISTRATION_FIELDS });
}

const PAID_WITH_TOKEN = {
  email: `${RIDER}@example.com`,
  bikeRegistration: {
    bikeDetails: BIKE,
    tokenNumber: 'TKN-0001',
    tokenStatus: 'Pending Verification',
    tokenEstimatedTime: '15-20 minutes',
    tokenGeneratedAt: '2026-10-07T10:00:00.000Z',
  },
  payment: { status: 'paid', amountCents: 500, currency: 'usd' },
};

describe('reading', () => {
  test('a rider can read their own document', async () => {
    await seed(PAID_WITH_TOKEN);
    await assertSucceeds(getDoc(riderDoc()));
  });

  test("a rider cannot read another rider's document", async () => {
    await seed(PAID_WITH_TOKEN, OTHER_RIDER);
    await assertFails(getDoc(riderDoc(OTHER_RIDER, RIDER)));
  });

  test('signed-out users cannot read anything', async () => {
    await seed(PAID_WITH_TOKEN);
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users', RIDER)));
  });
});

describe('rider-owned fields', () => {
  test('a rider can save their profile and bike', async () => {
    await assertSucceeds(saveRegistration(registration()));
  });

  test('a rider can edit their bike after paying, keeping server fields', async () => {
    await seed(PAID_WITH_TOKEN);
    const newBike = { ...BIKE, color: 'Red' };
    await assertSucceeds(
      saveRegistration(registration({ bikeRegistration: { bikeDetails: newBike } })),
    );
    const stored = await readAsServer();
    assert.equal(stored.bikeRegistration.bikeDetails.color, 'Red');
    assert.equal(stored.bikeRegistration.tokenNumber, 'TKN-0001');
    assert.equal(stored.payment.status, 'paid');
  });

  test('saving bike details replaces legacy owner keys stored inside them', async () => {
    await seed({
      bikeRegistration: {
        bikeDetails: { ...BIKE, fullName: 'Old Name', cnic: '1', phoneNo: '2' },
        tokenNumber: 'TKN-0001',
      },
    });
    await assertSucceeds(saveRegistration(registration()));
    const stored = await readAsServer();
    assert.deepEqual(stored.bikeRegistration.bikeDetails, BIKE);
    assert.equal(stored.bikeRegistration.tokenNumber, 'TKN-0001');
  });

  test("a rider cannot write another rider's document", async () => {
    await assertFails(saveRegistration(registration(), riderDoc(OTHER_RIDER, RIDER)));
  });

  for (const [field, value] of [
    ['cnic', '9520212345671'],
    ['cnic', '35202-1234567-1'],
    ['phoneNumber', '3001234567'],
    ['phoneNumber', '+923001234567'],
    ['name', ''],
    ['name', 'x'.repeat(101)],
    ['email', 'someone-else@example.com'],
  ]) {
    test(`rejects ${field} = ${JSON.stringify(value).slice(0, 30)}`, async () => {
      await assertFails(saveRegistration(registration({ [field]: value })));
    });
  }

  for (const [field, value] of [
    ['year', '21'],
    ['plateNumber', ''],
    ['plateNumber', 'P'.repeat(21)],
    ['engineNo', 'E'.repeat(31)],
    ['isStolen', false],
  ]) {
    test(`rejects bike ${field} = ${JSON.stringify(value).slice(0, 30)}`, async () => {
      const bike = { ...BIKE, [field]: value };
      await assertFails(
        saveRegistration(registration({ bikeRegistration: { bikeDetails: bike } })),
      );
    });
  }

  test('updatedAt must be the server time', async () => {
    await assertFails(
      saveRegistration(registration({ updatedAt: new Date('2020-01-01') })),
    );
  });

  test('riders cannot delete their document', async () => {
    await seed(PAID_WITH_TOKEN);
    await assertFails(deleteDoc(riderDoc()));
  });
});

describe('server-owned fields', () => {
  test('a rider cannot mark themselves as paid', async () => {
    await assertFails(
      setDoc(riderDoc(), { payment: { status: 'paid' } }, { merge: true }),
    );
    await seed({ email: `${RIDER}@example.com` });
    await assertFails(updateDoc(riderDoc(), { 'payment.status': 'paid' }));
  });

  test('a rider cannot issue their own MTAG card', async () => {
    await seed(PAID_WITH_TOKEN);
    await assertFails(updateDoc(riderDoc(), { 'mtagCard.issued': true }));
  });

  test('a rider cannot pick their own queue token', async () => {
    await assertFails(
      setDoc(
        riderDoc(),
        { bikeRegistration: { bikeDetails: BIKE, tokenNumber: 'TKN-0001' } },
        { merge: true },
      ),
    );
  });

  test('a rider cannot change their token status', async () => {
    await seed(PAID_WITH_TOKEN);
    await assertFails(
      updateDoc(riderDoc(), { 'bikeRegistration.tokenStatus': 'Card Issued' }),
    );
  });

  test('a rider cannot add arbitrary top-level fields', async () => {
    await assertFails(setDoc(riderDoc(), { isAdmin: true }, { merge: true }));
  });

  test('riders cannot touch the queue token counter', async () => {
    const db = riderDb();
    await assertFails(getDoc(doc(db, 'counters', 'queueTokens')));
    await assertFails(setDoc(doc(db, 'counters', 'queueTokens'), { last: 0 }));
  });
});

describe('reference photo URL', () => {
  const ownUrl = `https://res.cloudinary.com/demo-cloud/image/upload/v1700000000/mtag/users/${RIDER}/face.jpg`;

  function savePhoto(url) {
    return setDoc(
      riderDoc(),
      { facePhotoUrl: url, facePhotoCapturedAt: serverTimestamp(), updatedAt: serverTimestamp() },
      { merge: true },
    );
  }

  test("accepts the rider's own Cloudinary upload", async () => {
    await assertSucceeds(savePhoto(ownUrl));
    await assertSucceeds(savePhoto(ownUrl.replace('v1700000000/', '')));
  });

  for (const [label, url] of [
    ["another rider's photo", ownUrl.replace(`/${RIDER}/`, `/${OTHER_RIDER}/`)],
    ['another host', `https://evil.example.com/mtag/users/${RIDER}/face.jpg`],
    ['plain http', ownUrl.replace('https://', 'http://')],
    ['a non-image', ownUrl.replace('face.jpg', 'face.svg')],
  ]) {
    test(`rejects ${label}`, async () => {
      await assertFails(savePhoto(url));
    });
  }

  test('facePhotoCapturedAt must be the server time', async () => {
    await assertFails(
      setDoc(
        riderDoc(),
        { facePhotoUrl: ownUrl, facePhotoCapturedAt: new Date('2020-01-01') },
        { merge: true },
      ),
    );
  });
});
