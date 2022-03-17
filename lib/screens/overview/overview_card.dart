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
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      "Review $available",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(fontWeight: FontWeight.w300),
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
