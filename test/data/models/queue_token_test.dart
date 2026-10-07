import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';

void main() {
  group('labels', () {
    test('fall back when nothing is stored', () {
      const token = QueueToken(number: 'TKN-0001');
      expect(token.statusLabel, 'Pending');
      expect(token.estimatedWaitLabel, 'N/A');
      expect(token.generatedAtLabel, 'N/A');
      expect(token.isCollected, isFalse);
    });

    test('show the stored values while waiting', () {
      const token = QueueToken(
        number: 'TKN-0001',
        status: ' Pending Verification ',
        estimatedWait: '15-20 minutes',
      );
      expect(token.statusLabel, 'Pending Verification');
      expect(token.estimatedWaitLabel, '15-20 minutes');
    });

    test('switch to "Card Issued" once collected', () {
      for (final status in ['Card Issued', 'collected', ' ISSUED ']) {
        final token = QueueToken(number: 'TKN-1', status: status);
        expect(token.isCollected, isTrue, reason: status);
        expect(token.statusLabel, QueueToken.collectedStatus);
        expect(token.estimatedWaitLabel, QueueToken.collectedEstimatedWait);
      }
    });
  });

  group('generatedAtLabel', () {
    test('formats timestamps in local time', () {
      const raw = '2026-10-07T09:05:03.000Z';
      final local = DateTime.parse(raw).toLocal();
      String two(int value) => value.toString().padLeft(2, '0');
      expect(
        const QueueToken(number: 'TKN-1', generatedAt: raw).generatedAtLabel,
        '${two(local.day)}-${two(local.month)}-${local.year} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}',
      );
    });

    test('keeps values that are not timestamps', () {
      const token = QueueToken(number: 'TKN-1', generatedAt: 'yesterday');
      expect(token.generatedAtLabel, 'yesterday');
    });
  });

  test('asCollected keeps the number and timestamp', () {
    const token = QueueToken(
      number: 'TKN-0042',
      status: 'Pending Verification',
      generatedAt: '2026-10-07T10:00:00.000Z',
    );
    final collected = token.asCollected();
    expect(collected.number, 'TKN-0042');
    expect(collected.generatedAt, token.generatedAt);
    expect(collected.isCollected, isTrue);
  });

  group('fromRegistrationMap', () {
    test('reads the stored token fields', () {
      final token = QueueToken.fromRegistrationMap({
        'tokenNumber': 'TKN-0007',
        'tokenStatus': 'Pending Verification',
        'tokenEstimatedTime': '15-20 minutes',
        'tokenGeneratedAt': '2026-10-07T10:00:00.000Z',
      });
      expect(token, isNotNull);
      expect(token!.number, 'TKN-0007');
      expect(token.status, 'Pending Verification');
    });

    test('returns null before a token is assigned', () {
      expect(QueueToken.fromRegistrationMap({}), isNull);
      expect(QueueToken.fromRegistrationMap({'tokenNumber': ''}), isNull);
    });
  });
}
