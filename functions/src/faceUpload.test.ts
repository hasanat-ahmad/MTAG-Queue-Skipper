import assert from "node:assert/strict";
import { test } from "node:test";
import { signCloudinaryParams } from "./faceUpload";

test("matches the example in Cloudinary's signature documentation", () => {
  const signature = signCloudinaryParams(
    {
      timestamp: "1315060510",
      public_id: "sample_image",
      eager: "w_400,h_300,c_pad|w_260,h_200,c_crop",
    },
    "abcd",
  );
  assert.equal(signature, "bfd09f95f331f558cbd1320e67aa8d488770583e");
});

test("signs parameters in alphabetical order regardless of input order", () => {
  const a = signCloudinaryParams({ b: "2", a: "1" }, "secret");
  const b = signCloudinaryParams({ a: "1", b: "2" }, "secret");
  assert.equal(a, b);
});

test("a different secret gives a different signature", () => {
  const params = { public_id: "mtag/users/abc/face", timestamp: "1" };
  assert.notEqual(
    signCloudinaryParams(params, "one"),
    signCloudinaryParams(params, "two"),
  );
});
