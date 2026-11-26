import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

const _skeletonBase = Color(0xFFE6E4DE);
const _skeletonHighlight = Color(0xFFF6F5F1);

/// Sweeps a soft highlight across every [SkeletonBox] inside it.
/// Respects the device's "reduce motion" setting (shows still boxes instead).
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});
  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('loading'),
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _ctrl,
          child: widget.child,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                colors: const [
                  _skeletonBase,
                  _skeletonHighlight,
                  _skeletonBase,
                ],
                stops: const [0.25, 0.5, 0.75],
                transform: _SlideTransform(-1 + 2 * _ctrl.value),
              ).createShader(bounds),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.percent);
  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}

/// A grey rounded placeholder. Put inside a [SkeletonShimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}