import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stacy_frontend/src/services/logger.dart';

class LottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;

  const LottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      fit: BoxFit.contain,
      frameRate: FrameRate.max,
      errorBuilder: (context, error, stackTrace) {
        log.severe('Lottie animation error: $error');
        return Center(
          child: Text(
            'Animation Error',
            style: TextStyle(color: Colors.red.shade700),
          ),
        );
      },
    );
  }
}
