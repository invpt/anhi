import 'package:flutter/material.dart';

import '../../secret.dart';

String _prettyPrintDuration(Duration duration) {
  final inMinutes = duration.inMinutes;
  final inHours = duration.inHours;
  final inDays = duration.inDays;

  if (duration.isNegative) {
    return "available now";
  } else if (inMinutes < 1) {
    return "in less than 1 minute";
  } else if (inMinutes == 1) {
    return "in 1 minute";
  } else if (inMinutes < 60) {
    return "in $inMinutes minutes";
  } else if (inHours == 1) {
    return "in 1 hour";
  } else if (inHours < 24) {
    return "in $inHours hours";
  } else if (inDays == 1) {
    return "in 1 day";
  } else {
    return "in $inDays days";
  }
}

enum _PopupAction {
  edit,
  review,
  delete,
}

class OverviewCard extends StatelessWidget {
  const OverviewCard(
      {required this.secret,
      required this.onRequestEdit,
      required this.onRequestReview,
      required this.onRequestDelete,
      Key? key})
      : super(key: key);

  final Secret secret;
  final void Function() onRequestEdit;
  final void Function() onRequestReview;
  final void Function() onRequestDelete;

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var durationUntil = secret.reviewTime.difference(now);

    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0));

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: shape,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.0,
                    child: Center(
                      child: Text('${secret.reviewStage}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w300)),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        secret.mnemonic,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Review ${_prettyPrintDuration(durationUntil)}",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton(
                shape: shape,
                onSelected: (action) {
                  switch (action) {
                    case _PopupAction.edit:
                      return onRequestEdit();
                    case _PopupAction.review:
                      return onRequestReview();
                    case _PopupAction.delete:
                      return onRequestDelete();
                  }
                },
                itemBuilder: (context) {
                  return <PopupMenuItem>[
                    PopupMenuItem(
                      value: _PopupAction.edit,
                      child: Row(
                        children: const <Widget>[
                          Icon(Icons.details),
                          SizedBox(width: 16.0),
                          Text("Details"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _PopupAction.review,
                      child: Row(
                        children: const <Widget>[
                          Icon(Icons.book),
                          SizedBox(width: 16.0),
                          Text("Review"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _PopupAction.delete,
                      child: Row(
                        children: const <Widget>[
                          Icon(Icons.delete),
                          SizedBox(width: 16.0),
                          Text("Delete"),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
