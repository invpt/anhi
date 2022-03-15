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
  String value = "";

  void trySubmit() {
    widget.secret.verify(value).then((isValid) => widget.onDone(correct: true));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    widget.secret.mnemonic,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w300),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                TextField(
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (newSecret) => value = newSecret,
                  onSubmitted: (_) => trySubmit(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Secret',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
