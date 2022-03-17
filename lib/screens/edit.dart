import 'package:anhi/secret.dart';
import 'package:anhi/secret_storage.dart';
import 'package:flutter/material.dart';

class EditSecretPage extends StatefulWidget {
  const EditSecretPage({Key? key, required this.secret, required this.storage})
      : super(key: key);

  final StoredSecret secret;
  final SecretStorage storage;

  @override
  State<StatefulWidget> createState() => _EditSecretPageState();
}

class _EditSecretPageState extends State<EditSecretPage> {
  String? mnemonicError;
  String mnemonic = '';
  String value = '';

  void finish(BuildContext context, {required bool save}) {
    if (!save) {
      Navigator.pop(context);
    } else if (checkError()) {
      Secret.newSecret(mnemonic, value)
          .then((secret) => Navigator.pop(context, secret));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit secret'),
      ),
      body: Padding(
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
                filled: true,
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
              onSubmitted: (_) => finish(context, save: true),
              decoration: const InputDecoration(
                filled: true,
                border: OutlineInputBorder(),
                labelText: 'Secret',
                hintText: 'Enter a secret',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => finish(context, save: true),
        tooltip: 'Done',
        child: const Icon(Icons.done),
      ),
    );
  }
}
