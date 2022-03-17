import 'package:anhi/screens/review/review_card.dart';
import 'package:flutter/material.dart';

import '../secret.dart';
import '../secret_storage.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({required this.reviews, required this.storage, Key? key})
      : super(key: key);

  final SecretStorage storage;
  final List<StoredSecret> reviews;

  @override
  State<StatefulWidget> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int currentReview = 0;

  void onCardDone({required StoredSecret secret, required bool correct}) {
    if (correct) {
      widget.storage.update(secret.localId, secret.atNextStage());
      setState(() => currentReview++);
    } else {
      setState(() => currentReview++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: widget.reviews.length - currentReview,
          itemBuilder: (context, index) {
            return ReviewCard(
              secret: widget.reviews[currentReview + index],
              onDone: ({required correct}) => onCardDone(
                secret: widget.reviews[currentReview + index],
                correct: correct,
              ),
            );
          },
        ),
      ),
    );
  }
}
