import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/services/firebase_seed_service.dart';
import 'package:food/food/core/theme/colors.dart';

/// Admin widget to seed Firebase with initial data
/// Only visible in debug mode
class FirebaseSeedButton extends StatefulWidget {
  const FirebaseSeedButton({super.key});

  @override
  State<FirebaseSeedButton> createState() => _FirebaseSeedButtonState();
}

class _FirebaseSeedButtonState extends State<FirebaseSeedButton> {
  bool _isSeeding = false;
  bool _isClearing = false;
  final _seedService = FirebaseSeedService();

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSeed() async {
    if (_isSeeding) return;

    setState(() => _isSeeding = true);

    try {
      _showSnackBar('Starting database seed...', kPrimaryColor);
      await _seedService.seedAll();
      if (mounted) {
        _showSnackBar('Database seeded successfully!', kSuccessColor);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error seeding database: $e', kErrorColor);
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  Future<void> _handleClear() async {
    if (_isClearing) return;

    // Confirm before clearing
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Database?'),
        content: const Text(
          'This will delete all restaurants and foods from Firebase. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: kErrorColor),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isClearing = true);

    try {
      _showSnackBar('Clearing database...', kPrimaryColor);
      await _seedService.clearRestaurants();
      await _seedService.clearFoods();
      if (mounted) {
        _showSnackBar('Database cleared successfully!', kSuccessColor);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error clearing database: $e', kErrorColor);
      }
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    assert(!_isSeeding, 'Seeding in progress');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kGreyColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FText(
            text: 'Admin Tools',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kTextColorDark,
          ),
          8.verticalSpace,
          Row(
            children: [
              Expanded(
                child: FButton(
                  buttonText: _isSeeding ? 'Seeding...' : 'Seed Database',
                  onPressed: _isSeeding ? null : _handleSeed,
                  fontSize: 12,
                  color: kPrimaryColor,
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: FButton(
                  buttonText: _isClearing ? 'Clearing...' : 'Clear Data',
                  onPressed: _isClearing ? null : _handleClear,
                  fontSize: 12,
                  color: kErrorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
