import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/services/firebase_dummy_data_service.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get/get.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final FirebaseDummyDataService _dummyDataService = FirebaseDummyDataService();
  bool _isSeeding = false;
  bool _isClearing = false;
  bool _isGettingStats = false;
  String _statusMessage = '';
  Map<String, int> _databaseStats = {};

  @override
  void initState() {
    super.initState();
    _getDatabaseStats();
  }

  Future<void> _seedDatabase() async {
    setState(() {
      _isSeeding = true;
      _statusMessage = 'Seeding database with dummy data...';
    });

    try {
      await _dummyDataService.seedDatabase();
      setState(() {
        _statusMessage = 'Database seeded successfully!';
      });
      await _getDatabaseStats();
      
      Get.snackbar(
        'Success',
        'Database seeded with dummy data successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error seeding database: $e';
      });
      
      Get.snackbar(
        'Error',
        'Failed to seed database: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  Future<void> _clearDatabase() async {
    final confirmed = await _showConfirmationDialog(
      'Clear Database',
      'Are you sure you want to clear all data from Firebase? This action cannot be undone.',
    );
    
    if (!confirmed) return;

    setState(() {
      _isClearing = true;
      _statusMessage = 'Clearing database...';
    });

    try {
      await _dummyDataService.clearDatabase();
      setState(() {
        _statusMessage = 'Database cleared successfully!';
      });
      await _getDatabaseStats();
      
      Get.snackbar(
        'Success',
        'Database cleared successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Error clearing database: $e';
      });
      
      Get.snackbar(
        'Error',
        'Failed to clear database: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  Future<void> _getDatabaseStats() async {
    setState(() {
      _isGettingStats = true;
    });

    try {
      final stats = await _dummyDataService.getDatabaseStats();
      setState(() {
        _databaseStats = stats;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting database stats: $e';
      });
    } finally {
      setState(() {
        _isGettingStats = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      appBarWidget: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: kGreyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20.r,
                color: kBlackColor,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          FText(
            text: 'Firebase Test Screen',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: kBlackColor,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FText(
              text: 'Firebase Dummy Data Manager',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: kBlackColor,
            ),
            SizedBox(height: 8.h),
            FText(
              text: 'Use this screen to populate Firebase with test data or clear existing data.',
              fontSize: 14.sp,
              color: kGreyColor,
            ),
            SizedBox(height: 32.h),
            
            // Database Stats Section
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: kGreyColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FText(
                        text: 'Database Statistics',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: kBlackColor,
                      ),
                      GestureDetector(
                        onTap: _isGettingStats ? null : _getDatabaseStats,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 16.r,
                                color: kPrimaryColor,
                              ),
                              SizedBox(width: 4.w),
                              FText(
                                text: 'Refresh',
                                fontSize: 12.sp,
                                color: kPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (_isGettingStats)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: _databaseStats.entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FText(
                                text: '${entry.key.capitalize}:',
                                fontSize: 14.sp,
                                color: kBlackColor,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: entry.value > 0 
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: FText(
                                  text: '${entry.value}',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: entry.value > 0 
                                      ? Colors.green
                                      : kGreyColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Action Buttons
            FButton(
              buttonText: _isSeeding ? 'Seeding Database...' : 'Seed Database',
              onPressed: _isSeeding || _isClearing ? null : _seedDatabase,
              width: double.infinity,
              color: _isSeeding || _isClearing ? kGreyColor : kPrimaryColor,
            ),
            
            SizedBox(height: 16.h),
            
            FButton(
              buttonText: _isClearing ? 'Clearing Database...' : 'Clear Database',
              onPressed: _isSeeding || _isClearing ? null : _clearDatabase,
              width: double.infinity,
              color: _isSeeding || _isClearing ? kGreyColor : Colors.red,
              borderColor: _isSeeding || _isClearing ? kGreyColor : Colors.red,
            ),
            
            SizedBox(height: 32.h),
            
            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: kGreyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FText(
                      text: 'Status:',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: kBlackColor,
                    ),
                    SizedBox(height: 8.h),
                    FText(
                      text: _statusMessage,
                      fontSize: 14.sp,
                      color: kGreyColor,
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // Warning Message
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.orange,
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FText(
                          text: 'Warning',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 4.h),
                        FText(
                          text: 'This screen is for testing purposes only. Use carefully in production environments.',
                          fontSize: 12.sp,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}