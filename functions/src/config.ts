import { defineSecret, defineString } from "firebase-functions/params";

/** Must match `BackendConfig.functionsRegion` in lib/config/backend_config.dart. */
export const REGION = "us-central1";

/**
 * Registration fee in the smallest currency unit (500 = $5.00).
 * The app only displays the fee (lib/config/stripe_config.dart); this value
 * is what riders are actually charged.
 */
export const REGISTRATION_FEE = { amount: 500, currency: "usd" } as const;

/** Queue token values written when a token is first assigned. */
export const NEW_TOKEN_STATUS = "Pending Verification";
export const NEW_TOKEN_ESTIMATED_WAIT = "15-20 minutes";

/** Queue token values written once the MTAG card has been handed over. */
export const COLLECTED_TOKEN_STATUS = "Card Issued";
export const COLLECTED_ESTIMATED_WAIT = "—";

/** Stripe secret key (sk_...). Set with `firebase functions:secrets:set`. */
export const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");

/** Cloudinary API secret. Set with `firebase functions:secrets:set`. */
export const CLOUDINARY_API_SECRET = defineSecret("CLOUDINARY_API_SECRET");

/** Non-secret Cloudinary settings, read from functions/.env.<project-id>. */
export const CLOUDINARY_CLOUD_NAME = defineString("CLOUDINARY_CLOUD_NAME");
export const CLOUDINARY_API_KEY = defineString("CLOUDINARY_API_KEY");
