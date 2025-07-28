import 'package:flutter/material.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/services/permission_service/permission_repository.dart';
import 'package:food/food/core/services/permission_service/permission_service.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'buttons.dart';

/// A reusable dialog to request various app permissions
class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final Permission permission;
  final Function() onGranted;
  final Function()? onDenied;
  final bool isMandatory;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.permission,
    required this.onGranted,
    this.onDenied,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Image.asset(icon, height: 60, width: 60),
          const SizedBox(height: 16),

          // Title
          FText(text: title, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),

          // Description
          FText(text: description),
          const SizedBox(height: 24),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isMandatory)
                Expanded(
                  child: FButton(
                    buttonText: "Reject",
                    onPressed: () {
                      Navigator.pop(context);
                      if (onDenied != null) {
                        onDenied!();
                      }
                    },
                    color: kWhiteColor,
                    textColor: kPrimaryColor,
                    borderColor: kPrimaryColor,
                  ),
                ),
              if (!isMandatory) const SizedBox(width: 16),
              Expanded(
                child: FButton(
                  buttonText: 'Grant',
                  onPressed: () async {
                    final permissionService = PermissionService();
                    final permissionRepository = PermissionRepository();
                    bool isGranted = false;

                    // Handle different permission types
                    if (permission == Permission.location) {
                      isGranted =
                          await permissionService.requestLocationPermission();
                    } else {
                      final status = await permission.request();
                      isGranted = status.isGranted;
                      // Save the permission status
                      await permissionRepository.savePermissionStatus(
                        permission,
                        isGranted,
                      );
                    }

                    if (isGranted) {
                      Logger.logSuccess(
                        'Permission granted: ${permission.toString()}',
                      );
                      Navigator.pop(context, true);
                      onGranted();
                    } else if (isMandatory) {
                      // If permission is mandatory but denied, show a message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This permission is required to use this feature.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      Navigator.pop(context, false);
                      if (onDenied != null) {
                        onDenied!();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            '$title permission is required for this feature. Please enable it in app settings.',
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
                if (onDenied != null) {
                  onDenied!();
                }
              },
            ),
            TextButton(
              child: Text('Settings'),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show permission dialog static method
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    required String icon,
    required Permission permission,
    required Function() onGranted,
    Function()? onDenied,
    bool isMandatory = false,
  }) async {
    // Check if permission is already granted from database
    final permissionRepository = PermissionRepository();
    final savedStatus = await permissionRepository.getPermissionStatus(
      permission,
    );

    if (savedStatus == true) {
      // Permission already granted
      onGranted();
      return true;
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (BuildContext context) {
        return PermissionDialog(
          title: title,
          description: description,
          icon: icon,
          permission: permission,
          onGranted: onGranted,
          onDenied: onDenied,
          isMandatory: isMandatory,
        );
      },
    );
  }
}
