import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons.dart';
import '../../../../components/scaffold.dart';
import '../../../../components/textfields.dart';
import '../../../../components/texts.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../../home/manager/selected_address/selected_address_cubit.dart';
import '../../../home/manager/user_profile/enhanced_user_profile_cubit.dart';
import '../manager/flutterwave_bloc/flutterwave_payment_bloc.dart';
import '../manager/flutterwave_bloc/flutterwave_payment_event.dart';
import '../manager/flutterwave_bloc/flutterwave_payment_state.dart';
import 'status.dart';

class FlutterwaveCardFormScreen extends StatefulWidget {
  final double amount;
  final String orderId;

  const FlutterwaveCardFormScreen({
    super.key,
    required this.amount,
    required this.orderId,
  });

  @override
  State<FlutterwaveCardFormScreen> createState() =>
      _FlutterwaveCardFormScreenState();
}

class _FlutterwaveCardFormScreenState extends State<FlutterwaveCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nav = GetIt.instance<NavigationService>();

  // Text controllers
  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // Focus nodes
  final _cardHolderNameFocus = FocusNode();
  final _cardNumberFocus = FocusNode();
  final _expiryDateFocus = FocusNode();
  final _cvvFocus = FocusNode();

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameFocus.dispose();
    _cardNumberFocus.dispose();
    _expiryDateFocus.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlutterwavePaymentBloc, FlutterwavePaymentState>(
      listener: (context, state) {
        if (state is FlutterwavePaymentInitialized) {
          setState(() => _isProcessing = false);
          if (state.transaction.isSuccess) {
            nav.navigateAndReplace(
              '/status',
              arguments: PaymentStatusEnum.success,
            );
          } else {
            DFoodUtils.showSnackBar(
              "Payment failed. Please try again.",
              kErrorColor,
            );
          }
        } else if (state is FlutterwavePaymentError) {
          setState(() => _isProcessing = false);
          DFoodUtils.showSnackBar(state.message, kErrorColor);
        } else if (state is FlutterwavePaymentLoading) {
          setState(() => _isProcessing = true);
        }
      },
      child: FScaffold(
        appBarWidget: Row(
          children: [
            BackWidget(color: kGreyColor),
            20.horizontalSpace,
            const FText(
              text: "Card Payment",
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAmountSection(),
                30.verticalSpace,
                _buildCardForm(),
                30.verticalSpace,
                _buildPayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kGreyColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kContainerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FText(
            text: "Amount to Pay",
            fontSize: 14,
            color: kTextColorDark,
          ),
          10.verticalSpace,
          FText(
            text: "\$${widget.amount.toStringAsFixed(2)}",
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FText(
              text: "Card Information",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            20.verticalSpace,
            FTextField(
              label: "Cardholder Name",
              hintText: "Enter cardholder name",
              controller: _cardHolderNameController,
              node: _cardHolderNameFocus,
              action: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validate: (value) => validateCardHolderName(value ?? ''),
              onEditingComplete: () => _cardNumberFocus.requestFocus(),
            ),
            16.verticalSpace,
            FTextField(
              label: "Card Number",
              hintText: "1234 5678 9012 3456",
              controller: _cardNumberController,
              node: _cardNumberFocus,
              action: TextInputAction.next,
              keyboardType: TextInputType.number,
              validate: (value) => validateCardNumber(value ?? ''),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CardNumberInputFormatter(),
              ],
              onEditingComplete: () => _expiryDateFocus.requestFocus(),
            ),
            16.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: FTextField(
                    label: "Expiry Date",
                    hintText: "MM/YY",
                    controller: _expiryDateController,
                    node: _expiryDateFocus,
                    action: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validate: (value) => validateExpiryDate(value ?? ''),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ExpiryDateInputFormatter(),
                    ],
                    onEditingComplete: () => _cvvFocus.requestFocus(),
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: FTextField(
                    label: "CVV",
                    hintText: "123",
                    controller: _cvvController,
                    node: _cvvFocus,
                    action: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    validate: (value) => validateCVV(value ?? ''),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
              ],
            ),
            20.verticalSpace,
            _buildSecurityNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: kPrimaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: kPrimaryColor, size: 16.sp),
          8.horizontalSpace,
          const Expanded(
            child: FText(
              text: "Your payment information is encrypted and secure",
              fontSize: 12,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: FButton(
        onPressed: _isProcessing ? null : _processPayment,
        buttonText:
            _isProcessing
                ? "Processing..."
                : "Pay \$${widget.amount.toStringAsFixed(2)}",
      ),
    );
  }

  void _processPayment() {
    if (!_formKey.currentState!.validate()) {
      DFoodUtils.showSnackBar(
        "Please fill in all card details correctly",
        kErrorColor,
      );
      return;
    }

    final user = context.read<EnhancedUserProfileCubit>().state.data;
    final selectedAddress =
        context.read<SelectedAddressCubit>().selectedAddress;

    if (user == null) {
      DFoodUtils.showSnackBar(
        "Please log in to continue with payment.",
        kErrorColor,
      );
      return;
    }

    if (selectedAddress == null) {
      DFoodUtils.showSnackBar("Please select a delivery address.", kErrorColor);
      return;
    }

    setState(() => _isProcessing = true);

    // Prepare metadata with user and address information
    final metadata = {
      'userId': user.id,
      'userName': '${user.firstName} ${user.lastName}',
      'phoneNumber': "8068787087",
      'address': {
        'street': selectedAddress.street,
        'city': selectedAddress.city,
        'state': selectedAddress.state,
        'postal_code': selectedAddress.zipCode,
        'country': 'NG', // Default to Nigeria
        'line1': selectedAddress.address,
        'line2': selectedAddress.apartment,
      },
      'cardDetails': {
        'cardHolderName': _cardHolderNameController.text.trim(),
        'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
        'expiryMonth': _expiryDateController.text.split('/')[0],
        'expiryYear': '20${_expiryDateController.text.split('/')[1]}',
        'cvv': _cvvController.text.trim(),
      },
    };
    Logger.logBasic(user.phoneNumber);
    // Initialize Flutterwave payment
    context.read<FlutterwavePaymentBloc>().add(
      InitializeFlutterwavePaymentEvent(
        orderId: widget.orderId,
        amount: widget.amount,
        email: user.email,
        metadata: metadata,
      ),
    );
  }
}

// Custom formatters for card input
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
