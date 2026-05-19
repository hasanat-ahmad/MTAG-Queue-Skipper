/// Shared display rules for queue token status and estimated wait time.
class TokenDisplay {
  TokenDisplay._();

  static const String collectedStatus = 'Card Issued';
  static const String collectedEstimatedTime = '—';

  static bool isCollected({
    String? status,
    bool mtagCardIssued = false,
  }) {
    if (mtagCardIssued) return true;
    final normalized = status?.trim().toLowerCase() ?? '';
    return normalized == 'card issued' ||
        normalized == 'collected' ||
        normalized == 'issued';
  }

  static String statusLabel({
    String? status,
    bool mtagCardIssued = false,
  }) {
    if (isCollected(status: status, mtagCardIssued: mtagCardIssued)) {
      return collectedStatus;
    }
    final value = status?.trim();
    if (value == null || value.isEmpty) return 'Pending';
    return value;
  }

  static String estimatedTimeLabel({
    String? estimatedTime,
    String? status,
    bool mtagCardIssued = false,
  }) {
    if (isCollected(status: status, mtagCardIssued: mtagCardIssued)) {
      return collectedEstimatedTime;
    }
    final value = estimatedTime?.trim();
    if (value == null || value.isEmpty) return 'N/A';
    return value;
  }
}
