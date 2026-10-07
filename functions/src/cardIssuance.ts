import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { COLLECTED_ESTIMATED_WAIT, COLLECTED_TOKEN_STATUS } from "./config";
import { readTokenFields } from "./queueToken";
import { asMap, asString, requireString, requireUid } from "./shared";

/**
 * Issues the caller's MTAG card after re-checking, server-side, everything
 * the app checks before the face match: the token belongs to the caller,
 * the fee is paid, a reference photo exists and no card was issued yet.
 *
 * The face match itself still runs on the device (see SECURITY.md).
 */
export const issueMtagCard = onCall(async (request) => {
  const uid = requireUid(request);
  const tokenNumber = requireString(request.data, "tokenNumber", 20);
  const db = getFirestore();
  const userRef = db.doc(`users/${uid}`);

  return db.runTransaction(async (tx) => {
    const snapshot = await tx.get(userRef);
    if (!snapshot.exists) {
      throw new HttpsError(
        "not-found",
        "No registration found for your account.",
      );
    }
    const user = asMap(snapshot.data());
    const storedToken = readTokenFields(user.bikeRegistration).tokenNumber;

    if (!storedToken) {
      throw new HttpsError(
        "failed-precondition",
        "No token found on your account. Complete registration first.",
      );
    }
    if (storedToken !== tokenNumber) {
      throw new HttpsError(
        "permission-denied",
        "Token number does not match your registration.",
      );
    }
    if (asString(asMap(user.payment).status) !== "paid") {
      throw new HttpsError(
        "failed-precondition",
        "Payment is required before collecting your MTAG card.",
      );
    }
    if (asMap(user.mtagCard).issued === true) {
      throw new HttpsError(
        "already-exists",
        "Your MTAG card has already been issued.",
      );
    }
    if (!asString(user.facePhotoUrl)) {
      throw new HttpsError(
        "failed-precondition",
        "No registration photo on file. Complete face verification first.",
      );
    }

    tx.set(
      userRef,
      {
        mtagCard: {
          issued: true,
          tokenNumber: storedToken,
          issuedAt: FieldValue.serverTimestamp(),
        },
        bikeRegistration: {
          tokenStatus: COLLECTED_TOKEN_STATUS,
          tokenEstimatedTime: COLLECTED_ESTIMATED_WAIT,
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return { tokenNumber: storedToken };
  });
});
