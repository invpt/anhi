import 'dart:math';

import 'package:anhi/screens/review/review_card.dart';
import 'package:flutter/material.dart';

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
  late List<StoredSecret> reviews = List.unmodifiable(widget.reviews);

  void onCardDone({required StoredSecret secret, required bool correct}) {
    if (correct) {
      widget.storage.update(secret.localId, secret.atNextStage());
    }

    if (reviews.length == 1) {
      Navigator.pop(context);
    } else {
      setState(() => reviews = reviews.sublist(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review"),
      ),
      body: ListView.custom(
        padding: const EdgeInsets.all(8.0),
        physics: const NeverScrollableScrollPhysics(),
        childrenDelegate: SliverChildBuilderDelegate(
          buildSliverChild,
          childCount: reviews.length,
          findChildIndexCallback: (Key key) => reviews.indexWhere(
              (element) => element.localId == (key as ValueKey<int>).value),
        ),
      ),
    );
  }

  Widget? buildSliverChild(BuildContext context, int index) {
    final secret = reviews[index];

    return AnimatedOpacity(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 400),
      opacity: pow(0.5, index) as double,
      key: ValueKey(secret.localId),
      child: IgnorePointer(
        ignoring: index != 0,
        child: Dismissible(
          onDismissed: (direction) => onCardDone(
            secret: secret,
            correct: false,
          ),
          key: const ValueKey(null),
          child: ReviewCard(
            secret: secret,
            onDone: ({required correct}) => onCardDone(
              secret: secret,
              correct: correct,
            ),
          ),
        ),
      ),
    );
  }
}
