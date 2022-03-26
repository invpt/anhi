import 'package:anhi/screens/create_secret.dart';
import 'package:anhi/screens/details.dart';
import 'package:anhi/screens/overview/create_card.dart';
import 'package:anhi/screens/review.dart';
import 'package:anhi/secret.dart';
import 'package:anhi/secret_storage.dart';
import 'package:flutter/material.dart';

import 'overview/overlay_animator.dart';
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

  final _AnimatedCreateSecretController createSecretController =
      _AnimatedCreateSecretController();

  bool creatingSecret = false;
  int? editingSecretId;

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

  void pushEditSecretPage(StoredSecret secret) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SecretDetailsPage(
        secret: secret,
        storage: _storage,
      );
    })).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final items = _storage.storedSecrets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anhi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(4.0),
        itemCount: items.length,
        itemBuilder: itemBuilder,
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              final reviewable = reviewableSecrets();

              if (reviewable.isNotEmpty) {
                pushReviewPage(reviewableSecrets());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nothing to review")));
              }
            },
            tooltip: 'Review secrets',
            child: const Icon(Icons.book),
          ),
          const Padding(padding: EdgeInsets.all(4.0)),
          if (creatingSecret)
            FloatingActionButton(
              heroTag: null,
              onPressed: () => setState(() {
                createSecretController.finish();
              }),
              tooltip: 'Cancel creation',
              child: const Icon(Icons.close),
            ),
          if (!creatingSecret)
            FloatingActionButton(
              heroTag: null,
              onPressed: () => setState(() {
                creatingSecret = true;
                createSecretController.begin();
              }),
              tooltip: 'Create a secret',
              child: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (index == 0) {
      return SizedBox(
        height: creatingSecret ? null : 0,
        child: _AnimatedCreateSecret(
          storage: _storage,
          controller: createSecretController,
          onFinished: (secret) => setState(() {
            if (secret != null) {
              _storage.add(secret);
            }

            creatingSecret = false;
          }),
        ),
      );
    } else {
      index -= 1;
    }

    final secret = _storage.storedSecrets[index];

    if (editingSecretId == secret.localId) {
      throw Exception();
    } else {
      return OverviewCard(
        secret: secret,
        onRequestEdit: () => pushEditSecretPage(secret),
        onRequestReview: () => secret.reviewTime.isBefore(DateTime.now())
            ? pushReviewPage([secret])
            : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("You must wait until a review is available"))),
        onRequestDelete: () => setState(() => _storage.remove(secret.localId)),
        key: ValueKey(secret.localId),
      );
    }
  }
}

class _AnimatedCreateSecretController {
  void Function()? _begin;
  void Function()? _finish;

  void begin() => _begin!();
  void finish() => _finish!();
}

class _AnimatedCreateSecret extends StatefulWidget {
  const _AnimatedCreateSecret(
      {required this.storage,
      required this.onFinished,
      required this.controller,
      Key? key})
      : super(key: key);

  final SecretStorage storage;
  final void Function(Secret?) onFinished;
  final _AnimatedCreateSecretController controller;

  @override
  State<StatefulWidget> createState() => _AnimatedCreateSecretState();
}

class _AnimatedCreateSecretState extends State<_AnimatedCreateSecret> {
  final OverlayAnimatorController overlayAnimatorController =
      OverlayAnimatorController();
  final CreateSecretCardController createSecretCardController =
      CreateSecretCardController();

  Secret? createdSecret;

  @override
  void initState() {
    super.initState();
    widget.controller._begin = () {
      overlayAnimatorController.open();
      createSecretCardController.grabFocus();
    };
    widget.controller._finish = () {
      createdSecret = null;
      overlayAnimatorController.close();
    };
  }

  @override
  Widget build(BuildContext context) {
    return OverlayAnimator(
      controller: overlayAnimatorController,
      onLoaded: () {},
      onOpenDone: () {},
      onCloseDone: () {
        createSecretCardController.reset();
        widget.onFinished(createdSecret);
      },
      base: createdSecret != null
          ? OverviewCard(
              secret: createdSecret!,
              onRequestEdit: () {},
              onRequestReview: () {},
              onRequestDelete: () {})
          : null,
      overlay: CreateSecretCard(
        controller: createSecretCardController,
        storage: widget.storage,
        onDone: (secret) {
          if (secret != null) {
            setState(() => createdSecret = secret);
          }

          overlayAnimatorController.close();
        },
      ),
    );
  }
}
