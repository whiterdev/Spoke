import 'package:flutter/material.dart';

class SpokeBrandMark extends StatelessWidget {
  const SpokeBrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * 0.34),
    child: Image.asset(
      'assets/brand/app_icon.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    ),
  );
}
