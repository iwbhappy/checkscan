import 'package:flutter/material.dart';

class ScanReticle extends StatefulWidget {
  const ScanReticle({
    required this.width,
    required this.height,
    this.active = true,
    super.key,
  });
  final double width;
  final double height;
  final bool active;
  @override
  State<ScanReticle> createState() => _ScanReticleState();
}

class _ScanReticleState extends State<ScanReticle>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  void _update() {
    if (widget.active &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  @override
  void didUpdateWidget(ScanReticle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ReticlePainter(
            progress: _controller.value,
            active: widget.active,
          ),
        ),
      ),
    ),
  );
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({required this.progress, required this.active});
  final double progress;
  final bool active;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = active ? const Color(0xff87f4d5) : Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    const length = 28.0;
    for (final corner in [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      final dx = corner.dx == 0 ? 1.0 : -1.0;
      final dy = corner.dy == 0 ? 1.0 : -1.0;
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx, corner.dy + length * dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx + length * dx, corner.dy),
        paint,
      );
    }
    if (active) {
      final y = 16 + (size.height - 32) * Curves.easeInOut.transform(progress);
      final line = Paint()
        ..shader = const LinearGradient(
          colors: [Colors.transparent, Color(0xff87f4d5), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, y, size.width, 2));
      canvas.drawRect(Rect.fromLTWH(8, y, size.width - 16, 2), line);
    }
  }

  @override
  bool shouldRepaint(_ReticlePainter old) =>
      progress != old.progress || active != old.active;
}
