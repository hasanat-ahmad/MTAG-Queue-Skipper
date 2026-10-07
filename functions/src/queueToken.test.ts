import assert from "node:assert/strict";
import { test } from "node:test";
import { formatTokenNumber, readTokenFields } from "./queueToken";

test("formats sequences as zero-padded TKN numbers", () => {
  assert.equal(formatTokenNumber(1), "TKN-0001");
  assert.equal(formatTokenNumber(42), "TKN-0042");
  assert.equal(formatTokenNumber(12345), "TKN-12345");
});

test("rejects sequences that are not positive integers", () => {
  assert.throws(() => formatTokenNumber(0), RangeError);
  assert.throws(() => formatTokenNumber(-3), RangeError);
  assert.throws(() => formatTokenNumber(1.5), RangeError);
});

test("reads token fields and ignores the wrong types", () => {
  assert.deepEqual(
    readTokenFields({
      tokenNumber: " TKN-0007 ",
      tokenStatus: "Pending Verification",
      tokenEstimatedTime: 15,
      bikeDetails: { plateNumber: "ABC-123" },
    }),
    {
      tokenNumber: "TKN-0007",
      tokenStatus: "Pending Verification",
      tokenEstimatedTime: "",
      tokenGeneratedAt: "",
    },
  );
  assert.equal(readTokenFields(undefined).tokenNumber, "");
});
