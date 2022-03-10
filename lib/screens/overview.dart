import 'dart:async';

import 'package:anhi/db.dart';
import 'package:anhi/screens/overview/new_card.dart';
import 'package:flutter/material.dart';

import '../secret.dart';
import 'overview/overview_card.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final StreamController<bool> submitNotifier = StreamController.broadcast();
  bool isNewSecretVisible = false;
  bool isLoading = true;
  List<Secret> secrets = [];

  @override
  void dispose() {
    submitNotifier.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    AnhiDatabase.instance.getAllSecrets().then((loadedSecrets) => setState(() {
          secrets.addAll(loadedSecrets);
          isLoading = false;
        }));
  }

  void _onNewSecretDone(Secret? secret) {
    if (secret != null) {
      AnhiDatabase.instance.addSecret(secret);
    }
    
    setState(() => isNewSecretVisible = false);
  }

  void _hideNewSecret() {
    submitNotifier.sink.add(false);
  }

  Future<bool> _onWillPop() async {
    if (isNewSecretVisible) {
      _hideNewSecret();

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
        body: Column(children: [
          Visibility(
              visible: isNewSecretVisible,
              child: NewCard(onDone: _onNewSecretDone, submitNotifier: submitNotifier.stream)),
          OverviewList(isAside: isNewSecretVisible, secrets: secrets)
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              setState(() => isNewSecretVisible = !isNewSecretVisible),
          tooltip: 'Add secret',
          child:
              isNewSecretVisible ? const Icon(Icons.done) : const Icon(Icons.add),
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
                  left: 4.0, right: 4.0, bottom: 4.0, top: isAside ? 0.0 : 4.0),
              itemCount: secrets.length,
              itemBuilder: (context, index) => OverviewCard(secrets[index],
                  key: ValueKey(secrets[index].mnemonic))),
        ),
      ),
    );
  }
}
