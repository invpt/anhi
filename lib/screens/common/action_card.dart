import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  const ActionCard(
      {this.header, required this.top, required this.bottom, Key? key})
      : super(key: key);

  final Widget? header;
  final Widget top;
  final Widget bottom;

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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  if (header != null)
                    Column(
                      children: <Widget>[
                        header!,
                        const Divider(thickness: 2.0),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        top,
                        const SizedBox(height: 16.0),
                        bottom,
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
