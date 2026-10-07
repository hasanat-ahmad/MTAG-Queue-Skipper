import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';

/// Motorcycle icon with a scan line sweeping up and down across it.
class ScanningBikeLogo extends StatefulWidget {
  const ScanningBikeLogo({super.key});

  @override
  State<ScanningBikeLogo> createState() => _ScanningBikeLogoState();
}

class _ScanningBikeLogoState extends State<ScanningBikeLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scanOffset = Tween<double>(
      begin: -60.0,
      end: 60.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.two_wheeler_rounded, size: 70),
          AnimatedBuilder(
            animation: _scanOffset,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _scanOffset.value),
                child: child,
              );
            },
            child: Container(
              width: 100,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
