import 'package:flutter/material.dart';

import '../../secret.dart';

String prettyPrintDuration(Duration duration) {
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

class OverviewCard extends StatelessWidget {
  const OverviewCard(this.secret, {Key? key}) : super(key: key);

  final Secret secret;

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
        child: InkWell(
          onTap: () {},
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
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
                      "Review ${prettyPrintDuration(durationUntil)}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
