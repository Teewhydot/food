import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/services/file_upload_service.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/utils/app_utils.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../domain/failures/failures.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../../file_upload/presentation/manager/file_upload_bloc/file_upload_bloc.dart';
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
  String? profileImageUrl = "";
  String id = "";
  late Stream<Either<Failure, UserProfileEntity>> _userProfileStream;

  void getUserProfile() async {
    final user = await (await db.database).userProfileDao.getUserProfile();
    if (user.first.id != null) {
      email = user.first.email;
      id = user.first.id!;
      Logger.logBasic("User ID: $id, Email: $email");
    }
  }

  void _initializeStream() {
    _userProfileStream =
        context
            .read<UserProfileCubit>()
            .watchUserProfile(context.readCurrentUserId ?? "")
            .distinct();
  }

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.userProfile.firstName;
    lastNameController.text = widget.userProfile.lastName;
    phoneController.text = widget.userProfile.phoneNumber;
    bioController.text = widget.userProfile.bio ?? "";
    getUserProfile();
    _initializeStream();
  }

  Widget _buildProfileImage(Either<Failure, UserProfileEntity>? data) {
    return CircleWidget(
      radius: 70,
      color: kPrimaryColor,
      onTap: null,
      child: FImage(
        assetPath:
            data?.fold(
              (l) => widget.userProfile.profileImageUrl ?? "",
              (r) => r.profileImageUrl ?? "",
            ) ??
            widget.userProfile.profileImageUrl ??
            "",
        assetType: FoodAssetType.network,
        borderRadius: 70,
        width: 140,
        height: 140,
      ),
    );
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
    return BlocManager<UserProfileCubit, BaseState<UserProfileEntity>>(
      bloc: context.read<UserProfileCubit>(),
      showLoadingIndicator: true,
      onError: (context, state) {
        if (state is ErrorState) {
          DFoodUtils.showSnackBar(state.errorMessage ?? "", kErrorColor);
        }
      },
      onSuccess: (context, state) {
        nav.goBack();
        Logger.logSuccess("User profile updated successfully");
      },
      builder: (context, state) {
        return FScaffold(
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
                    StreamBuilder<Either<Failure, UserProfileEntity>>(
                      stream: _userProfileStream,
                      builder: (context, snapshot) {
                        return _buildProfileImage(snapshot.data);
                      },
                    ),
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
                            profileImageUrl = await context
                                .read<FileUploadCubit>()
                                .uploadFile(context.readCurrentUserId!, result);
                          } else {
                            DFoodUtils.showSnackBar(
                              "Error picking selected file",
                              kErrorColor,
                            );
                          }
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
                  hintText: widget.userProfile.phoneNumber,
                  action: TextInputAction.next,
                  label: "Phone",
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  isReadOnly: true,
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
                  enabled:
                      firstNameController.text.isNotEmpty &&
                      lastNameController.text.isNotEmpty,
                  onPressed: () async {
                    final updatedProfile = UserProfileEntity(
                      id: id,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: email,
                      phoneNumber: phoneController.text,
                      bio: bioController.text,
                      firstTimeLogin: false,
                    );
                    context.read<UserProfileCubit>().updateUserProfile(
                      updatedProfile,
                    );
                  },
                ),
                32.verticalSpace,
              ],
            ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
