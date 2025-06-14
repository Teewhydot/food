import 'package:flutter/material.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/generated/assets.dart';

const List<String> imageAssets = [
  Assets.assetsLogo,
  Assets.assetsSplashFoodLogo,
  Assets.assetsSplashLogo,
];

const List<String> svgAssets = [
  Assets.svgsAddress,
  Assets.svgsArrowDown,
  Assets.svgsArrowRight,
  Assets.svgsAuthBg,
  Assets.svgsCart,
  Assets.svgsCartIcon,
  Assets.svgsCash,
  Assets.svgsClock,
  Assets.svgsCloseIcon,
  Assets.svgsDeleteAddress,
  Assets.svgsDelivery,
  Assets.svgsEditAddress,
  Assets.svgsEmail,
  Assets.svgsEmptyCard,
  Assets.svgsFacebook,
  Assets.svgsFaq,
  Assets.svgsFavourite,
  Assets.svgsFilter,
  Assets.svgsHomeAddress,
  Assets.svgsLineDesign,
  Assets.svgsLocationIcon,
  Assets.svgsLogo,
  Assets.svgsLogout,
  Assets.svgsMastercard,
  Assets.svgsNotifications,
  Assets.svgsOfferBg,
  Assets.svgsPaymentMethod,
  Assets.svgsPaypal,
  Assets.svgsPencil,
  Assets.svgsPersonalInfo,
  Assets.svgsPhoneNum,
  Assets.svgsRating,
  Assets.svgsSend,
  Assets.svgsSettings,
  Assets.svgsSpiralDesign,
  Assets.svgsSplashDesign,
  Assets.svgsSuccessful,
  Assets.svgsTrapezoidContainer,
  Assets.svgsTruck,
  Assets.svgsUserReview,
  Assets.svgsVisa,
  Assets.svgsWorkAddress,
];

Future<void> precacheAllAssets(BuildContext context) async {
  for (final asset in imageAssets) {
    await precacheImage(AssetImage(asset), context);
  }
  for (final asset in svgAssets) {
    await precacheImage(AssetImage(asset), context);
  }
  Logger.logSuccess("Assets precached");
}
