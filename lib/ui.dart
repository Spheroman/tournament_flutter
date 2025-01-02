import 'package:flutter/material.dart';

class UICard extends StatelessWidget {
  final String name;
  final Widget child;
  final int color;
  final bool clickable;
  final InkWell? inkWell;

  const UICard(this.name, this.child,
      {super.key, this.color = 0, this.clickable = false, this.inkWell});

  @override
  Widget build(BuildContext context) {
    Widget inside = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            child
          ]),
    );
    if (clickable) {
      inside = InkWell(
        onTap: inkWell!.onTap,
        child: inside,
      );
    }
    return Card(
        color: color == 1 ? Theme.of(context).colorScheme.onSecondary : null,
        clipBehavior: clickable ? Clip.hardEdge : null,
        child: inside);
  }
}
