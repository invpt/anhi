import 'package:flutter/material.dart';

import '../../secret.dart';

String _prettyPrintDuration(Duration duration) {
  int modDiff(int a, int b) {
    final mod = a % b;

    if (mod < (mod - b).abs()) {
      return mod;
    } else {
      return mod - b;
    }
  }

  const hoursEpsilon = 10 * Duration.secondsPerMinute;
  const daysEpsilon = 45 * Duration.secondsPerMinute;

  var seconds = duration.inSeconds;

  var diff = 0;
  if ((diff = modDiff(seconds, Duration.secondsPerDay)).abs() < daysEpsilon) {
    seconds -= diff;
  } else if ((diff = modDiff(seconds, Duration.secondsPerHour)).abs() <
      hoursEpsilon) {
    seconds -= diff;
  }

  if (seconds <= 0) {
    return "available now";
  } else if (seconds < Duration.secondsPerMinute) {
    return "in less than 1 minute";
  } else if (seconds == Duration.secondsPerMinute) {
    return "in 1 minute";
  } else if (seconds < Duration.secondsPerHour) {
    return "in ${seconds ~/ Duration.secondsPerMinute} minutes";
  } else if (seconds == Duration.secondsPerHour) {
    return "in 1 hour";
  } else if (seconds < Duration.secondsPerDay) {
    return "in ${seconds ~/ Duration.secondsPerHour} hours";
  } else if (seconds == Duration.secondsPerDay) {
    return "in 1 day";
  } else {
    return "in ${seconds ~/ Duration.secondsPerDay} days";
  }
}

enum _PopupAction {
  edit,
  review,
  delete,
}

class InfoCard extends StatelessWidget {
  const InfoCard(
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

    return Card(
      shape: shape,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
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
            Expanded(
              child: Column(
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
    );
  }
}
