import 'package:anhi/screens/common/action_card.dart';
import 'package:flutter/material.dart';

import '../../secret.dart';

class ReviewCard extends StatefulWidget {
  const ReviewCard({required this.secret, required this.onDone, Key? key})
      : super(key: key);

  final Secret secret;
  final void Function({required bool correct}) onDone;

  @override
  State<StatefulWidget> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool isHashing = false;
  String value = "";
  String? error;

  void finish({required bool save}) {
    if (!save) {
      widget.onDone(correct: false);
    } else {
      setState(() => isHashing = true);
      widget.secret.verify(value).then((correct) {
        if (correct) {
          widget.onDone(correct: true);
        } else {
          setState(() {
            error = "Secret does not match.";
            isHashing = false;
          });
        }
      });
    }
  }

  void onSecretChanged(String newValue) {
    if (isHashing) {
      return;
    }

    setState(() {
      value = newValue;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActionCard(
      top: Center(
        child: Text(
          widget.secret.mnemonic,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w300),
        ),
      ),
      bottom: TextField(
        autofocus: true,
        obscureText: true,
        textInputAction: TextInputAction.done,
        onChanged: onSecretChanged,
        onEditingComplete: () {},
        onSubmitted: (_) => finish(save: true),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Secret',
          helperText: isHashing ? 'Hashing...' : null,
          errorText: error,
        ),
      ),
    );
  }
}
