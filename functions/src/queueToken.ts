import { asMap, asString } from "./shared";

/** Token fields stored under `users/{uid}.bikeRegistration`. */
export interface QueueTokenFields {
  tokenNumber: string;
  tokenStatus: string;
  tokenEstimatedTime: string;
  tokenGeneratedAt: string;
}

/** Formats the n-th token handed out, e.g. 42 -> "TKN-0042". */
export function formatTokenNumber(sequence: number): string {
  if (!Number.isInteger(sequence) || sequence < 1) {
    throw new RangeError(`Token sequence must be a positive integer: ${sequence}`);
  }
  return `TKN-${String(sequence).padStart(4, "0")}`;
}

/** Reads the token fields from a `bikeRegistration` map. */
export function readTokenFields(bikeRegistration: unknown): QueueTokenFields {
  const map = asMap(bikeRegistration);
  return {
    tokenNumber: asString(map.tokenNumber),
    tokenStatus: asString(map.tokenStatus),
    tokenEstimatedTime: asString(map.tokenEstimatedTime),
    tokenGeneratedAt: asString(map.tokenGeneratedAt),
  };
}
