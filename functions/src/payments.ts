import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import Stripe from "stripe";
import {
  NEW_TOKEN_ESTIMATED_WAIT,
  NEW_TOKEN_STATUS,
  REGISTRATION_FEE,
  STRIPE_SECRET_KEY,
} from "./config";
import {
  formatTokenNumber,
  QueueTokenFields,
  readTokenFields,
} from "./queueToken";
import { asMap, asString, requireString, requireUid } from "./shared";

function stripeClient(): Stripe {
  return new Stripe(STRIPE_SECRET_KEY.value());
}

/**
 * Starts a registration-fee payment for the caller and returns the client
 * secret the app needs for the Stripe Payment Sheet.
 *
 * The amount is fixed here, never sent by the app, and the payment is
 * tagged with the caller's uid so confirmPayment can check who paid.
 */
export const createPaymentIntent = onCall(
  { secrets: [STRIPE_SECRET_KEY] },
  async (request) => {
    const uid = requireUid(request);
    const snapshot = await getFirestore().doc(`users/${uid}`).get();
    const user = asMap(snapshot.data());

    if (asString(asMap(user.payment).status) === "paid") {
      throw new HttpsError(
        "already-exists",
        "Your registration fee is already paid.",
      );
    }
    const bikeDetails = asMap(asMap(user.bikeRegistration).bikeDetails);
    if (Object.keys(bikeDetails).length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Register your bike before paying the fee.",
      );
    }

    const intent = await stripeClient().paymentIntents.create({
      amount: REGISTRATION_FEE.amount,
      currency: REGISTRATION_FEE.currency,
      allowed_payment_method_types: ["card"],
      description: "MTAG bike registration fee",
      metadata: { uid },
    });
    if (!intent.client_secret) {
      throw new HttpsError("internal", "Stripe did not return a client secret.");
    }
    return { paymentIntentId: intent.id, clientSecret: intent.client_secret };
  },
);

/**
 * Called by the app after the Payment Sheet closes successfully. Checks
 * the payment with Stripe, records it and assigns the rider's queue token.
 *
 * Calling it again for the same payment returns the same token.
 */
export const confirmPayment = onCall(
  { secrets: [STRIPE_SECRET_KEY] },
  async (request): Promise<QueueTokenFields> => {
    const uid = requireUid(request);
    const paymentIntentId = requireString(request.data, "paymentIntentId");
    const intent = await retrievePaymentIntent(paymentIntentId);

    if (intent.metadata?.uid !== uid) {
      throw new HttpsError(
        "permission-denied",
        "This payment belongs to a different account.",
      );
    }
    if (intent.status !== "succeeded") {
      throw new HttpsError(
        "failed-precondition",
        "The payment has not completed yet.",
      );
    }
    if (
      intent.amount !== REGISTRATION_FEE.amount ||
      intent.currency !== REGISTRATION_FEE.currency
    ) {
      logger.error("Payment does not match the registration fee", {
        uid,
        paymentIntentId,
        amount: intent.amount,
        currency: intent.currency,
      });
      throw new HttpsError(
        "failed-precondition",
        "The payment amount does not match the registration fee.",
      );
    }

    const db = getFirestore();
    const userRef = db.doc(`users/${uid}`);
    const counterRef = db.doc("counters/queueTokens");

    return db.runTransaction(async (tx) => {
      const userSnap = await tx.get(userRef);
      const counterSnap = await tx.get(counterRef);
      const user = asMap(userSnap.data());
      const payment = asMap(user.payment);
      const token = readTokenFields(user.bikeRegistration);

      const alreadyRecorded =
        asString(payment.stripePaymentIntentId) === paymentIntentId;
      if (alreadyRecorded && token.tokenNumber) {
        return token;
      }
      if (asString(payment.status) === "paid" && !alreadyRecorded) {
        logger.warn("Rider paid the registration fee twice; refund one", {
          uid,
          previous: payment.stripePaymentIntentId,
          current: paymentIntentId,
        });
      }

      const update: Record<string, unknown> = {
        payment: {
          status: "paid",
          amountCents: intent.amount,
          currency: intent.currency,
          stripePaymentIntentId: intent.id,
          paidAt: FieldValue.serverTimestamp(),
        },
        updatedAt: FieldValue.serverTimestamp(),
      };

      if (token.tokenNumber) {
        tx.set(userRef, update, { merge: true });
        return token;
      }

      const last = counterSnap.get("last");
      const sequence = (typeof last === "number" ? last : 0) + 1;
      const newToken: QueueTokenFields = {
        tokenNumber: formatTokenNumber(sequence),
        tokenStatus: NEW_TOKEN_STATUS,
        tokenEstimatedTime: NEW_TOKEN_ESTIMATED_WAIT,
        tokenGeneratedAt: new Date().toISOString(),
      };
      tx.set(counterRef, { last: sequence }, { merge: true });
      tx.set(
        userRef,
        { ...update, bikeRegistration: newToken },
        { merge: true },
      );
      return newToken;
    });
  },
);

async function retrievePaymentIntent(
  paymentIntentId: string,
): Promise<Stripe.PaymentIntent> {
  try {
    return await stripeClient().paymentIntents.retrieve(paymentIntentId);
  } catch (error) {
    logger.warn("Could not retrieve payment intent", {
      paymentIntentId,
      error: String(error),
    });
    throw new HttpsError("not-found", "Payment not found.");
  }
}
