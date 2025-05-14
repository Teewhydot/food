import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

enum FoodImageType { asset, network, svg }

class FImage extends StatelessWidget {
  final String assetPath;
  final double width, height, borderRadius;
  final BoxFit fit;
  final FoodImageType imageType;
  final Color? svgAssetColor;
  final MainAxisAlignment imageAlignment = MainAxisAlignment.center;

  const FImage({
    super.key,
    required this.assetPath,
    this.width = 100.0,
    this.height = 100.0,
    this.borderRadius = 0.0,
    this.svgAssetColor,
    this.fit = BoxFit.cover,
    this.imageType = FoodImageType.asset,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: switch (imageType) {
        FoodImageType.asset => Image.asset(
          assetPath,
          width: width.w,
          height: height.h,
          fit: fit,
        ),
        FoodImageType.network => CachedNetworkImage(
          imageUrl: assetPath,
          width: width.w,
          height: height.h,
          fit: fit,
          filterQuality: FilterQuality.high,
          placeholder:
              (context, url) =>
                  const Center(child: CircularProgressIndicator.adaptive()),
        ),
        FoodImageType.svg => SvgPicture.asset(
          assetPath,
          width: width.w,
          height: height.h,
          fit: fit,
          color: svgAssetColor,
        ),
      },
    );
  }
}
