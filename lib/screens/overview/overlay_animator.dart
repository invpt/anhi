import 'package:flutter/material.dart';

class OverlayAnimatorController {
  void Function()? _open;
  void Function()? _close;

  void open() => _open!();
  void close() => _close!();
}

class OverlayAnimator extends StatefulWidget {
  const OverlayAnimator(
      {required this.controller,
      required this.onLoaded,
      required this.onOpenDone,
      required this.onCloseDone,
      required this.base,
      required this.overlay,
      Key? key})
      : super(key: key);

  final OverlayAnimatorController controller;
  final void Function() onLoaded;
  final void Function() onCloseDone;
  final void Function() onOpenDone;
  final Widget? base;
  final Widget? overlay;

  @override
  State<OverlayAnimator> createState() => _OverlayAnimatorState();
}

class _OverlayAnimatorState extends State<OverlayAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.ease,
  )..addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          return widget.onCloseDone();
        case AnimationStatus.completed:
          return widget.onOpenDone();
        default:
      }
    });

  @override
  void initState() {
    super.initState();
    widget.controller._open = () => _controller.forward();
    widget.controller._close = () => _controller.reverse();
    widget.onLoaded();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.base != null) widget.base!,
        if (widget.overlay != null)
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.vertical,
            axisAlignment: -1,
            child: widget.overlay!,
          ),
      ],
    );
  }
}
