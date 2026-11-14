import 'package:flutter/material.dart';

Duration motionDuration(BuildContext context, [int milliseconds = 240]) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: milliseconds);

/// One entrance per identity, without replaying whenever a database stream emits.
class MotionReveal extends StatelessWidget {
  const MotionReveal({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: motionDuration(context, 280),
    curve: Curves.easeOutCubic,
    child: child,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: child,
      ),
    ),
  );
}

class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    required this.value,
    required this.format,
    this.style,
    super.key,
  });
  final int value;
  final String Function(int) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Semantics(
    label: format(value),
    excludeSemantics: true,
    child: TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value.toDouble(), end: value.toDouble()),
      duration: motionDuration(context, 350),
      curve: Curves.easeOutCubic,
      builder: (_, current, _) => Text(format(current.round()), style: style),
    ),
  );
}
