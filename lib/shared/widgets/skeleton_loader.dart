import 'package:flutter/material.dart';

/// A shimmer-animated placeholder skeleton box.
/// Use instead of [CircularProgressIndicator] on data-heavy screens.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF21262D),
                Color(0xFF30363D),
                Color(0xFF21262D),
              ],
              stops: [
                (_shimmer.value + 1.5) / 3 - 0.3,
                (_shimmer.value + 1.5) / 3,
                (_shimmer.value + 1.5) / 3 + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Convenience widget: a column of skeleton rows to simulate a list.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 72,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SkeletonLoader(width: itemHeight * 0.75, height: itemHeight * 0.75, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: double.infinity, height: 14, borderRadius: 6),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: 120, height: 11, borderRadius: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
