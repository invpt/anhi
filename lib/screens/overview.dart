import 'package:anhi/screens/create_secret.dart';
import 'package:anhi/screens/review.dart';
import 'package:anhi/secret.dart';
import 'package:anhi/secret_storage.dart';
import 'package:flutter/material.dart';

import 'overview/overview_card.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late final _storage = SecretStorage(
    onUpdate: () => mounted ? setState(() {}) : {},
    onError: (e) => throw e,
  );

  void pushReviewPage() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return ReviewPage(
        reviews: reviewableSecrets(),
        storage: _storage,
      );
    })).then((_) => setState(() {}));
  }

  List<StoredSecret> reviewableSecrets() {
    return _storage.storedSecrets
        .where((secret) => secret.reviewTime.isBefore(DateTime.now()))
        .toList();
  }

  void pushCreateSecretPage() {
    Navigator.push(context, MaterialPageRoute<Secret?>(builder: (context) {
      return CreateSecretPage(
        storage: _storage,
      );
    })).then((secret) {
      if (secret != null) {
        setState(() => _storage.add(secret));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anhi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(4.0),
        itemCount: _storage.storedSecrets.length,
        itemBuilder: (context, index) => OverviewCard(
          _storage.storedSecrets[index],
          key: ValueKey(_storage.storedSecrets[index].localId),
        ),
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: pushReviewPage,
            tooltip: 'Review secrets',
            child: const Icon(Icons.book),
          ),
          const Padding(padding: EdgeInsets.all(4.0)),
          FloatingActionButton(
            heroTag: null,
            onPressed: pushCreateSecretPage,
            tooltip: 'Create a secret',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
