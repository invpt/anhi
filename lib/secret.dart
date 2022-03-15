import 'dart:math';

import 'package:anhi/native.dart';

class Secret {
  const Secret.fromRaw(
      {required this.mnemonic,
      required this.hash,
      required this.reviewStage,
      required this.reviewTime});

  static Future<Secret> newSecret(String mnemonic, String secret) async {
    return Secret.fromRaw(
        mnemonic: mnemonic,
        hash: await native.hashSecret(secret: secret),
        reviewStage: 0,
        reviewTime: DateTime.now());
  }

  final String mnemonic;
  final String hash;
  final int reviewStage;
  final DateTime reviewTime;

  Future<bool> verify(String value) async {
    return await native.verifySecret(secret: value, hash: hash);
  }

  Secret atNextStage() {
    return atStage(reviewStage + 1);
  }

  Secret atStage(int newStage) {
    return Secret.fromRaw(
      mnemonic: mnemonic,
      hash: hash,
      reviewStage: newStage,
      reviewTime: calculateReviewTime(newStage),
    );
  }

  static DateTime calculateReviewTime(int reviewStage) {
    const reviewStageDeltas = <Duration>[
      Duration.zero,
      Duration(hours: 4),
      Duration(hours: 8),
      Duration(days: 1),
      Duration(days: 2),
      Duration(days: 7),
      Duration(days: 14),
      Duration(days: 112),
    ];

    return DateTime.now().add(reviewStageDeltas[min(reviewStage, reviewStageDeltas.length)]);
  }
}
