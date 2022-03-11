import 'dart:async';

import 'package:anhi/secret.dart';
import 'package:flutter/material.dart';

class NewCard extends StatefulWidget {
  const NewCard({Key? key, required this.onDone, required this.submitNotifier, required this.secretExists})
      : super(key: key);

  final void Function(Secret?) onDone;
  final bool Function(String) secretExists;
  final Stream<bool> submitNotifier;

  @override
  State<StatefulWidget> createState() => _NewCardState();
}

class _NewCardState extends State<NewCard> {
  late final StreamSubscription<bool> streamSubscription;

  String? mnemonicError;
  String mnemonic = '';
  String value = '';

  @override
  initState() {
    super.initState();
    streamSubscription = widget.submitNotifier.listen((save) => trySubmit(save: save));
  }

  void finish({required bool save}) {
    if (save) {
      Secret.newSecret(mnemonic, value).then((secret) => widget.onDone(secret));
    } else {
      widget.onDone(null);
    }
  }

  Future<void> trySubmit({required bool save}) async {
    if (!save) {
      finish(save: false);
    } else if (await isMnemonicValid()) {
      finish(save: true);
    }
  }

  Future<bool> isMnemonicValid() async {
    return mnemonic.isNotEmpty && !await widget.secretExists(mnemonic);
  }

  void updateMnemonic(String mnemonic) {
    setState(() => this.mnemonic = mnemonic);

    // set the error message
    isMnemonicValid().then((valid) {
      setState(() {
        if (valid) {
          mnemonicError = null;
        } else if (mnemonic.isEmpty) {
          mnemonicError = 'You must enter a mnemonic.';
        } else {
          mnemonicError = 'Another secret with that mnemonic already exists.';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                autocorrect: true,
                onChanged: updateMnemonic,
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
                onSubmitted: (_) => trySubmit(save: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Secret',
                  hintText: 'Enter the secret value',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
