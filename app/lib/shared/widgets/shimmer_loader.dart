import 'package:flutter/material.dart';
import 'package:mindpal_app/theme.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    required this.width,
    required this.height,
    super.key,
    this.radius = 16,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: MindPalColors.clay100,
      highlightColor: MindPalColors.sand50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: MindPalColors.clay100,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
