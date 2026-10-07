import { createHash } from "node:crypto";
import { onCall } from "firebase-functions/https";
import {
  CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET,
  CLOUDINARY_CLOUD_NAME,
} from "./config";
import { requireUid } from "./shared";

/**
 * Cloudinary request signature: SHA-1 of the parameters sorted by name as
 * `key=value` pairs joined with `&`, immediately followed by the API
 * secret. See https://cloudinary.com/documentation/authentication_signatures
 */
export function signCloudinaryParams(
  params: Record<string, string>,
  apiSecret: string,
): string {
  const toSign = Object.keys(params)
    .sort()
    .map((key) => `${key}=${params[key]}`)
    .join("&");
  return createHash("sha1").update(toSign + apiSecret).digest("hex");
}

/**
 * Authorises one upload: the caller's own reference selfie at
 * `mtag/users/{uid}/face`, images only. The app sends `params`, `apiKey`
 * and `signature` with the file. Because the API secret stays here, the
 * unsigned upload preset the app used before can be deleted.
 */
export const createFaceUploadSignature = onCall(
  { secrets: [CLOUDINARY_API_SECRET] },
  (request) => {
    const uid = requireUid(request);
    const params: Record<string, string> = {
      allowed_formats: "jpg,jpeg,png",
      invalidate: "true",
      overwrite: "true",
      public_id: `mtag/users/${uid}/face`,
      timestamp: String(Math.floor(Date.now() / 1000)),
    };
    return {
      cloudName: CLOUDINARY_CLOUD_NAME.value(),
      apiKey: CLOUDINARY_API_KEY.value(),
      params,
      signature: signCloudinaryParams(params, CLOUDINARY_API_SECRET.value()),
    };
  },
);
