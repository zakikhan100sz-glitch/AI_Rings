import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/enums.dart';
import '../../core/theme/app_colors.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

class RiskScoreRing extends StatefulWidget {
  const RiskScoreRing({
    super.key,
    required this.score,
    required this.level,
    this.size = 200,
  });

  final int score;
  final RiskLevel level;
  final double size;

  @override
  State<RiskScoreRing> createState() => _RiskScoreRingState();
}

class _RiskScoreRingState extends State<RiskScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(RiskScoreRing old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _ringColor {
    final s = widget.score;
    if (s <= 30) return const Color(0xFF00C853); // green
    if (s <= 69) return const Color(0xFFFFC107); // amber
    return const Color(0xFFFF3D00); // red
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = _ringColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Animated arc ────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ArcPainter(
                  progress: (widget.score / 100) * _animation.value,
                  trackColor: context.appSurfaceElevated,
                  arcColor: ringColor,
                  strokeWidth: 14,
                ),
              );
            },
          ),

          // ── Centre content ───────────────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score number
              AnimatedBuilder(
                animation: _animation,
                builder: (_, __) {
                  final displayed =
                      (widget.score * _animation.value).round();
                  return Text(
                    '$displayed',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.appTextPrimary,
                          letterSpacing: -1,
                        ),
                  );
                },
              ),
              Text(
                'Risk Score',
                style: TextStyle(
                  color: context.appTextSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // ── Status badge ─────────────────────────────────────────────
              _StatusBadge(level: widget.level, color: ringColor),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatefulWidget {
  const _StatusBadge({required this.level, required this.color});
  final RiskLevel level;
  final Color color;

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final opacity = 0.10 + 0.08 * _pulse.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(opacity + 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.color.withOpacity(0.45 + 0.15 * _pulse.value),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.level.label,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Custom painter ───────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    const startAngle = -math.pi * 0.75; // start at ~220° (bottom-left)
    const sweepTotal = math.pi * 1.5;   // 270° arc

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepTotal,
        colors: [arcColor.withOpacity(0.7), arcColor],
        tileMode: TileMode.clamp,
        transform: const GradientRotation(startAngle),
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);

    // Filled arc
    if (progress > 0) {
      canvas.drawArc(rect, startAngle, sweepTotal * progress, false, arcPaint);
    }

    // Glow dot at arc tip
    if (progress > 0.01) {
      final tipAngle = startAngle + sweepTotal * progress;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);

      final glowPaint = Paint()
        ..color = arcColor.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(tipX, tipY), strokeWidth * 0.7, glowPaint);

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(
          Offset(tipX, tipY), strokeWidth * 0.38, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress ||
      old.arcColor != arcColor ||
      old.trackColor != trackColor;
}
