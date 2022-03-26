import 'package:anhi/screens/common/action_card.dart';
import 'package:anhi/secret.dart';
import 'package:anhi/secret_storage.dart';
import 'package:flutter/material.dart';

class CreateSecretCardController {
  void Function()? _reset;
  void Function()? _grabFocus;

  void reset() => _reset!();
  void grabFocus() => _grabFocus!();
}

class CreateSecretCard extends StatefulWidget {
  const CreateSecretCard(
      {Key? key,
      required this.controller,
      required this.storage,
      required this.onDone})
      : super(key: key);

  final CreateSecretCardController controller;
  final SecretStorage storage;
  final void Function(Secret?) onDone;

  @override
  State<StatefulWidget> createState() => _CreateSecretCardState();
}

class _CreateSecretCardState extends State<CreateSecretCard> {
  final TextEditingController mnemonicController = TextEditingController();
  final TextEditingController secretController = TextEditingController();
  final FocusNode mnemonicFocusNode = FocusNode();
  String? mnemonicError;
  String mnemonic = '';
  String value = '';

  @override
  void initState() {
    super.initState();
    widget.controller._reset = () {
      // Unfocus textfield
      FocusScope.of(context).unfocus();
      // Reset textfields
      mnemonicController.clear();
      secretController.clear();
    };
    widget.controller._grabFocus = () {
      mnemonicFocusNode.requestFocus();
    };
  }

  @override
  void dispose() {
    mnemonicController.dispose();
    secretController.dispose();
    mnemonicFocusNode.dispose();

    super.dispose();
  }

  void finish({required bool save}) {
    if (!save) {
      widget.onDone(null);
    } else if (checkError()) {
      Secret.newSecret(mnemonic, value).then((secret) => widget.onDone(secret));
    }
  }

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
    return ActionCard(
      header: const Text("Creating new secret"),
      top: TextField(
        focusNode: mnemonicFocusNode,
        controller: mnemonicController,
        autocorrect: true,
        onChanged: updateMnemonic,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          filled: true,
          border: const OutlineInputBorder(),
          labelText: 'Mnemonic',
          hintText: 'Enter a mnemonic',
          errorText: mnemonicError,
        ),
      ),
      bottom: TextField(
        controller: secretController,
        obscureText: true,
        textInputAction: TextInputAction.done,
        onChanged: (newSecret) {
          value = newSecret;
        },
        onSubmitted: (_) => finish(save: true),
        decoration: const InputDecoration(
          filled: true,
          border: OutlineInputBorder(),
          labelText: 'Secret',
          hintText: 'Enter a secret',
        ),
      ),
    );
  }
}
