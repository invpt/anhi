import 'dart:async';

import 'package:anhi/screens/overview/create_secret_card.dart';
import 'package:anhi/secret_storage.dart';
import 'package:flutter/material.dart';

import '../secret.dart';
import 'overview/overview_card.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late final _storage = SecretStorage(
    onUpdate: onStorageUpdate,
    onError: onStorageError,
  );

  final createSecretController = CreateSecretCardController();
  bool isNewSecretVisible = false;

  void onStorageUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void onStorageError(StorageException error) {
    throw error;
  }

  void onCreateSecretDone(Secret? secret) {
    if (secret != null) {
      setState(() => _storage.add(secret));
    }

    setState(() => isNewSecretVisible = false);
  }

  void hideNewSecret({required bool save}) {
    createSecretController.trySubmit(save: save);
  }

  void showNewSecret() {
    setState(() => isNewSecretVisible = true);
  }

  // This handles back button presses on Android
  Future<bool> _onWillPop() async {
    if (isNewSecretVisible) {
      hideNewSecret(save: false);

      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Anhi'),
        ),
        body: Column(
          children: [
            Visibility(
              visible: isNewSecretVisible,
              child: CreateSecretCard(
                onDone: onCreateSecretDone,
                controller: createSecretController,
                secretExists: _storage.exists,
              ),
            ),
            OverviewList(
              isAside: isNewSecretVisible,
              secrets: _storage.storedSecrets,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (isNewSecretVisible) {
              hideNewSecret(save: true);
            } else {
              showNewSecret();
            }
          },
          tooltip: 'Add secret',
          child: isNewSecretVisible
              ? const Icon(Icons.done)
              : const Icon(Icons.add),
        ),
      ),
    );
  }
}

class OverviewList extends StatelessWidget {
  const OverviewList({
    Key? key,
    required this.isAside,
    required this.secrets,
  }) : super(key: key);

  final bool isAside;
  final List<Secret> secrets;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: isAside ? 0.5 : 1.0,
        child: IgnorePointer(
          ignoring: isAside,
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              left: 4.0,
              right: 4.0,
              bottom: 4.0,
              top: isAside ? 0.0 : 4.0,
            ),
            itemCount: secrets.length,
            itemBuilder: (context, index) => OverviewCard(
              secrets[index],
              key: ValueKey(secrets[index].mnemonic),
            ),
          ),
        ),
      ),
    );
  }
}
