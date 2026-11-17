import 'package:flutter/material.dart';

class AnimatedPress extends StatefulWidget {
  const AnimatedPress({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.scale = 0.96,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double scale;
  final BorderRadius? borderRadius;

  @override
  State<AnimatedPress> createState() => _AnimatedPressState();
}

class _AnimatedPressState extends State<AnimatedPress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: widget.scale,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _interactive => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final content = ScaleTransition(scale: _scale, child: widget.child);
    if (!_interactive) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: content,
    );
  }
}
