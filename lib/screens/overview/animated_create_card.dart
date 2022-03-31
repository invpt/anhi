import 'package:anhi/screens/overview/create_card.dart';
import 'package:anhi/screens/overview/info_card.dart';
import 'package:anhi/screens/overview/overlay_animator.dart';
import 'package:anhi/secret.dart';
import 'package:anhi/secret_storage.dart';
import 'package:flutter/material.dart';

class AnimatedCreateCardController {
  void Function()? _begin;
  void Function()? _finish;

  void begin() => _begin!();
  void finish() => _finish!();
}

class AnimatedCreateCard extends StatefulWidget {
  const AnimatedCreateCard(
      {required this.storage,
      required this.onFinished,
      required this.controller,
      Key? key})
      : super(key: key);

  final SecretStorage storage;
  final void Function(Secret?) onFinished;
  final AnimatedCreateCardController controller;

  @override
  State<StatefulWidget> createState() => _AnimatedCreateCardState();
}

class _AnimatedCreateCardState extends State<AnimatedCreateCard> {
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
          ? InfoCard(
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
