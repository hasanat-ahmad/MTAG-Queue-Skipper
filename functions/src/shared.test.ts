import assert from "node:assert/strict";
import { test } from "node:test";
import { CallableRequest, HttpsError } from "firebase-functions/https";
import { asMap, asString, requireString, requireUid } from "./shared";

test("requireUid returns the caller's uid", () => {
  const request = { auth: { uid: "rider-1" } } as CallableRequest;
  assert.equal(requireUid(request), "rider-1");
});

test("requireUid rejects signed-out callers", () => {
  assert.throws(
    () => requireUid({} as CallableRequest),
    (error: unknown) =>
      error instanceof HttpsError && error.code === "unauthenticated",
  );
});

test("requireString trims and validates the argument", () => {
  assert.equal(requireString({ token: "  TKN-0001 " }, "token"), "TKN-0001");
  for (const data of [{}, { token: "" }, { token: "   " }, { token: 7 }, null]) {
    assert.throws(
      () => requireString(data, "token"),
      (error: unknown) =>
        error instanceof HttpsError && error.code === "invalid-argument",
    );
  }
  assert.throws(() => requireString({ token: "x".repeat(21) }, "token", 20));
});

test("asMap and asString tolerate unexpected types", () => {
  assert.deepEqual(asMap(null), {});
  assert.deepEqual(asMap([1, 2]), {});
  assert.deepEqual(asMap({ a: 1 }), { a: 1 });
  assert.equal(asString(" paid "), "paid");
  assert.equal(asString(5), "");
});
