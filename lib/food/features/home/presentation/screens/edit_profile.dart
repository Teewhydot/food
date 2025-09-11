import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/services/file_upload_service.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/utils/app_utils.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../../file_upload/presentation/manager/file_upload_bloc/file_upload_bloc.dart';
import '../../../file_upload/presentation/manager/file_upload_bloc/file_upload_event.dart';
import '../../manager/user_profile/enhanced_user_profile_cubit.dart';

class EditProfile extends StatefulWidget {
  final UserProfileEntity userProfile;
  const EditProfile({super.key, required this.userProfile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final nav = GetIt.instance<NavigationService>();
  final fileUploadService = FileUploadService();
  //controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final db = UserProfileDatabaseService();
  String email = "";
  String id = "";
  void getUserProfile() async {
    final user = await (await db.database).userProfileDao.getUserProfile();
    if (user.first.id != null) {
      email = user.first.email;
      id = user.first.id!;
      Logger.logBasic("User ID: $id, Email: $email");
    }
  }

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.userProfile.firstName;
    lastNameController.text = widget.userProfile.lastName;
    phoneController.text = widget.userProfile.phoneNumber;
    bioController.text = widget.userProfile.bio ?? "";
    getUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<EnhancedUserProfileCubit, BaseState<UserProfileEntity>>(
      bloc: context.read<EnhancedUserProfileCubit>(),
      showLoadingIndicator: true,
      onSuccess: (context, state) {
        Logger.logBasic("User profile updated successfully");
      },
      builder: (context, state) {
        return CustomOverlay(
          isLoading: state is LoadingState,
          child: FScaffold(
            appBarWidget: Row(
              children: [
                BackWidget(color: kGreyColor),
                20.horizontalSpace,
                FText(
                  text: "Edit profile",
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                  color: kBlackColor,
                ),
              ],
            ),
            customScroll: true,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  20.verticalSpace,
                  Stack(
                    children: [
                      CircleWidget(radius: 70, color: kPrimaryColor),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleWidget(
                          radius: 20,
                          color: kBlackColor,
                          onTap: () async {
                            final result =
                                await fileUploadService.pickImageFromGallery();
                            if (result != null && context.mounted) {
                              context.read<FileUploadBloc>().add(
                                UploadFileEvent(file: result),
                              );
                            }
                            DFoodUtils.showSnackBar(
                              "Error uploading selected file",
                              kErrorColor,
                            );
                          },
                          child: FImage(
                            assetPath: Assets.svgsPencil,
                            assetType: FoodAssetType.svg,
                            width: 16,
                            height: 16,
                            svgAssetColor: kWhiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  30.verticalSpace,
                  FTextField(
                    hintText: "First Name",
                    action: TextInputAction.next,
                    label: "First Name",
                    controller: firstNameController,
                  ),
                  24.verticalSpace,
                  FTextField(
                    hintText: "Last Name",
                    action: TextInputAction.next,
                    label: "Last Name",
                    controller: lastNameController,
                  ),

                  24.verticalSpace,
                  FTextField(
                    hintText: "Phone",
                    action: TextInputAction.next,
                    label: "Phone",
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                  ),
                  24.verticalSpace,
                  FTextField(
                    hintText: "",
                    action: TextInputAction.next,
                    label: "Bio",
                    height: 103,
                    maxLine: 5,
                    controller: bioController,
                  ),
                  32.verticalSpace,
                  FButton(
                    buttonText: "Save",
                    width: 1.sw,
                    onPressed: () {
                      final updatedProfile = UserProfileEntity(
                        id: id,
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        email: email,
                        phoneNumber: phoneController.text,
                        bio: bioController.text,
                        firstTimeLogin: widget.userProfile.firstTimeLogin,
                      );
                      context
                          .read<EnhancedUserProfileCubit>()
                          .updateUserProfile(updatedProfile);
                      nav.goBack();
                    },
                  ),
                  32.verticalSpace,
                ],
              ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
