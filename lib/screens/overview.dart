import 'package:anhi/screens/create_secret.dart';
import 'package:anhi/screens/edit.dart';
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

  void pushReviewPage(reviews) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return ReviewPage(
        reviews: reviews,
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

  void pushEditSecretPage(StoredSecret secret) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return EditSecretPage(
        secret: secret,
        storage: _storage,
      );
    })).then((_) => setState(() {}));
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
        itemBuilder: (context, index) {
          final secret = _storage.storedSecrets[index];

          return OverviewCard(
            secret: secret,
            onRequestEdit: () => pushEditSecretPage(secret),
            onRequestReview: () => pushReviewPage([secret]),
            onRequestDelete: () =>
                setState(() => _storage.remove(secret.localId)),
            key: ValueKey(secret.localId),
          );
        },
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () => pushReviewPage(reviewableSecrets()),
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
