/**
 * Cloud Functions for MTAG Queue Skipper.
 *
 * Everything that involves money, the queue or card issuance runs here
 * instead of in the app, because a rider can modify the app on their own
 * phone but not this code. firestore.rules stops the app from writing the
 * fields these functions own (payment, queue token, mtagCard).
 */
import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/options";
import { REGION } from "./config";

initializeApp();

// maxInstances caps the cost of abusive traffic.
setGlobalOptions({ region: REGION, maxInstances: 10 });

export { createPaymentIntent, confirmPayment } from "./payments";
export { issueMtagCard } from "./cardIssuance";
export { createFaceUploadSignature } from "./faceUpload";
