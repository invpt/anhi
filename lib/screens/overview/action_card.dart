import 'package:flutter/material.dart';

import '../../secret_storage.dart';

class ActionCard extends StatefulWidget {
  const ActionCard({this.secret, required this.onDone, Key? key})
      : super(key: key);

  /// Set this value if this card is for a preexisiting secret.
  final StoredSecret? secret;
  final void Function({required bool correct}) onDone;

  @override
  State<StatefulWidget> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                topWidget(),
                const SizedBox(height: 16.0),
                bottomWidget(),
                Center(
                  child: Text(
                    widget.secret.mnemonic,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w300),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                TextField(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topWidget() {
    if (widget.secret == null) {
      return TextField(
        autofocus: true,
        autocorrect: true,
        onChanged: (_) {},
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          filled: true,
          border: const OutlineInputBorder(),
          labelText: 'Mnemonic',
          hintText: 'Enter a mnemonic',
          errorText: mnemonicError,
        ),
      );
    } else {
      final secret = widget.secret!;
    }
  }

  Widget bottomWidget() {}
}

class _SecretField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SecretFieldState();
}

class _SecretFieldState extends State<_SecretField> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _MnemonicFieldController {
  String? Function()? _validMnemonic;

  /// Returns the current mnemonic if it is valid.
  String? validMnemonic() => _validMnemonic!();
}

class _MnemonicField extends StatefulWidget {
  const _MnemonicField(
      {required this.storage, required this.controller, Key? key})
      : super(key: key);

  final SecretStorage storage;
  final _MnemonicFieldController controller;

  @override
  State<StatefulWidget> createState() => _MnemonicFieldState();
}

class _MnemonicFieldState extends State<_MnemonicField> {
  String mnemonic = '';
  String? mnemonicError;

  bool checkError() {
    final isValid = mnemonic.isNotEmpty && !widget.storage.exists(mnemonic);

    // set the error message
    setState(() {
      if (isValid) {
        mnemonicError = null;
      } else if (mnemonic.isEmpty) {
        mnemonicError = 'You must enter a mnemonic.';
      } else {
        mnemonicError = 'Another secret with that mnemonic already exists.';
      }
    });

    return isValid;
  }

  void updateMnemonic(String mnemonic) {
    setState(() => this.mnemonic = mnemonic);
    checkError();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}
