import 'dart:async';

import 'package:anhi/secret.dart';
import 'package:flutter/material.dart';

class CreateSecretCardController {
  void Function({required bool save})? _trySubmit;

  void trySubmit({required bool save}) {
    if (_trySubmit != null) {
      return _trySubmit!(save: save);
    } else {
      throw Exception("Controller used before being given to a widget");
    }
  }
}

class CreateSecretCard extends StatefulWidget {
  const CreateSecretCard(
      {Key? key,
      required this.onDone,
      required this.controller,
      required this.secretExists})
      : super(key: key);

  final void Function(Secret?) onDone;
  final bool Function(String) secretExists;
  final CreateSecretCardController controller;

  @override
  State<StatefulWidget> createState() => _CreateSecretCardState();
}

class _CreateSecretCardState extends State<CreateSecretCard> {
  String? mnemonicError;
  String mnemonic = '';
  String value = '';

  @override
  initState() {
    super.initState();
    widget.controller._trySubmit = trySubmit;
  }

  void finish({required bool save}) {
    if (save) {
      Secret.newSecret(mnemonic, value).then((secret) => widget.onDone(secret));
    } else {
      widget.onDone(null);
    }
  }

  void trySubmit({required bool save}) {
    if (!save) {
      finish(save: false);
    } else if (isMnemonicValid()) {
      finish(save: true);
    }
  }

  bool isMnemonicValid() {
    return mnemonic.isNotEmpty && !widget.secretExists(mnemonic);
  }

  void updateMnemonic(String mnemonic) {
    setState(() => this.mnemonic = mnemonic);

    final valid = isMnemonicValid();

    // set the error message
    setState(() {
      if (valid) {
        mnemonicError = null;
      } else if (mnemonic.isEmpty) {
        mnemonicError = 'You must enter a mnemonic.';
      } else {
        mnemonicError = 'Another secret with that mnemonic already exists.';
      }
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
                  hintText: 'Enter a secret',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
