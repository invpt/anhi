/*import 'package:flutter/material.dart';

import '../secret.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage(this.reviews, {Key? key}) : super(key: key);

  final List<Secret> reviews;

  @override
  State<StatefulWidget> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int currentReview = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              autocorrect: true,
              onChanged: (newMnemonic) {
                mnemonic = newMnemonic;
                checkMnemonic();
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Mnemonic',
                hintText: 'Enter a mnemonic',
                errorText: mnemonicError,
              ),
            ),
            const Padding(padding: EdgeInsets.all(8.0)),
            TextField(
              obscureText: true,
              textInputAction: TextInputAction.done,
              onChanged: (newSecret) {
                value = newSecret;
              },
              onSubmitted: (_) {
                done(context);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Secret',
                hintText: 'Enter the secret value',
              ),
            ),
          ],
        ),
      ),
    );
  }

}*/