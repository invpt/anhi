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

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 8.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: Row(
              children: [
                Text("7",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontWeight: FontWeight.w300)),
                const SizedBox(width: 12.0),
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
