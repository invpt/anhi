import 'package:flutter/material.dart';

import '../../secret.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard(this.secret, {Key? key}) : super(key: key);

  final Secret secret;

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var durationUntil = secret.reviewTime.difference(now);
    var available = durationUntil.isNegative
        ? "available now"
        : "in ${durationUntil.inDays} day${durationUntil.inDays != 1 ? "s" : ""}";

    return SizedBox(
        width: double.infinity,
        child: Card(
          child: InkWell(
            onTap: () {},
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(secret.mnemonic,
                        style: Theme.of(context).textTheme.subtitle1),
                    Text("Review $available",
                        style: Theme.of(context).textTheme.subtitle2)
                  ],
                )),
          ),
        ));
  }
}
