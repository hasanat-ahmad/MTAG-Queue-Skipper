import { CallableRequest, HttpsError } from "firebase-functions/https";

/** The caller's uid. Rejects calls from signed-out clients. */
export function requireUid(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Please sign in again.");
  }
  return uid;
}

/** Reads a required, trimmed string argument from the call data. */
export function requireString(
  data: unknown,
  field: string,
  maxLength = 100,
): string {
  const value = asMap(data)[field];
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `"${field}" is required.`);
  }
  const trimmed = value.trim();
  if (trimmed === "" || trimmed.length > maxLength) {
    throw new HttpsError("invalid-argument", `"${field}" is invalid.`);
  }
  return trimmed;
}

/** Treats anything that is not a plain object as an empty map. */
export function asMap(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : {};
}

/** Trimmed string value, or "" for anything that is not a string. */
export function asString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}
