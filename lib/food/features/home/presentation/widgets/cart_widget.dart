import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../components/texts/texts.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../payments/presentation/manager/cart/cart_cubit.dart';
import 'circle_widget.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key});

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return Stack(
      children: [
        CircleWidget(
          radius: 22.5,
          color: kAuthBgColor,
          onTap: () {
            nav.navigateTo(Routes.cart);
          },
          child: FImage(
            assetPath: Assets.svgsCartIcon,
            assetType: FoodAssetType.svg,
            svgAssetColor: kWhiteColor,
            width: 18,
            height: 20,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: CircleWidget(
            radius: 10,
            color: kPrimaryColor,
            onTap: null,
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state is CartLoaded) {
                  return FText(
                    text: "${state.itemCount}",
                    fontSize: 10,
                    color: kWhiteColor,
                  );
                }
                return CupertinoActivityIndicator(
                  radius: 5,
                  color: kWhiteColor,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
