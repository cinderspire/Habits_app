import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/services/revenue_cat_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String? featureName;
  const PaywallScreen({super.key, this.featureName});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<Package> _packages = [];
  bool _loading = true;
  bool _purchasing = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final packages = await RevenueCatService().getOfferings();
    if (mounted) {
      setState(() {
        _packages = packages;
        _loading = false;
        // Default to yearly if available
        if (packages.length > 1) _selectedIndex = 1;
      });
    }
  }

  Future<void> _purchase() async {
    if (_packages.isEmpty || _purchasing) return;
    setState(() => _purchasing = true);

    try {
      await ref
          .read(subscriptionProvider.notifier)
          .purchasePackage(_packages[_selectedIndex]);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to Gabby Premium! 🎉',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.secondaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _purchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase cancelled',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      await ref.read(subscriptionProvider.notifier).restorePurchases();
      final isPremium = ref.read(isPremiumProvider);
      if (mounted) {
        setState(() => _purchasing = false);
        if (isPremium) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No previous purchases found',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
              backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),

              // Crown icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),

              Text(
                'Unlock Gabby Premium',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (widget.featureName != null)
                Text(
                  '${widget.featureName} is a Premium feature',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primaryOrange),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),

              // Features list
              _buildFeatureRow(Icons.all_inclusive_rounded,
                  'Unlimited Habits', 'Track as many habits as you want'),
              _buildFeatureRow(Icons.flag_rounded,
                  'Community Challenges', 'Join 30-day challenges & compete'),
              _buildFeatureRow(Icons.auto_awesome_rounded,
                  'AI Insights', 'Smart suggestions based on your patterns'),
              _buildFeatureRow(Icons.analytics_rounded,
                  'Weekly Review', 'Detailed performance analysis'),
              _buildFeatureRow(Icons.link_rounded,
                  'Habit Stacking', 'Chain habits for maximum efficiency'),
              _buildFeatureRow(Icons.ac_unit_rounded,
                  'Streak Freezes', 'Protect your streaks on off days'),

              const SizedBox(height: 28),

              // Package options
              if (_loading)
                const CircularProgressIndicator(color: AppColors.primaryOrange)
              else if (_packages.isEmpty)
                _buildFallbackPackages()
              else
                _buildPackageOptions(),

              const SizedBox(height: 20),

              // Purchase button
              GestureDetector(
                onTap: _purchasing ? null : _purchase,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _purchasing
                        ? null
                        : AppColors.primaryGradient,
                    color: _purchasing
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _purchasing
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primaryOrange.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _purchasing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Start Free Trial',
                            style: AppTextStyles.titleMedium
                                .copyWith(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Restore
              TextButton(
                onPressed: _purchasing ? null : _restore,
                child: Text(
                  'Restore Purchases',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              // Legal
              const SizedBox(height: 8),
              Text(
                'Cancel anytime. Subscription auto-renews.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryOrange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: Theme.of(context).colorScheme.onSurface)),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.secondaryGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildFallbackPackages() {
    // Shown when RevenueCat offerings aren't configured yet
    return Column(
      children: [
        _buildPackageTile(
          index: 0,
          title: 'Monthly',
          price: '\$1.99/mo',
          subtitle: 'Billed monthly',
          isPopular: false,
        ),
        const SizedBox(height: 10),
        _buildPackageTile(
          index: 1,
          title: 'Yearly',
          price: '\$9.99/yr',
          subtitle: 'Save 58% — \$0.83/mo',
          isPopular: true,
        ),
      ],
    );
  }

  Widget _buildPackageOptions() {
    return Column(
      children: _packages.asMap().entries.map((entry) {
        final i = entry.key;
        final pkg = entry.value;
        final product = pkg.storeProduct;
        final isYearly = pkg.packageType == PackageType.annual;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildPackageTile(
            index: i,
            title: isYearly ? 'Yearly' : 'Monthly',
            price: product.priceString,
            subtitle: isYearly
                ? 'Best value'
                : 'Billed monthly',
            isPopular: isYearly,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPackageTile({
    required int index,
    required String title,
    required String price,
    required String subtitle,
    required bool isPopular,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange.withOpacity(0.08)
              : AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: AppTextStyles.titleSmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface)),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('BEST VALUE',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white, fontSize: 9)),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ),
            Text(price,
                style: AppTextStyles.headlineSmall
                    .copyWith(color: AppColors.primaryOrange)),
          ],
        ),
      ),
    );
  }
}

/// Helper to show paywall and optionally gate a feature
Future<bool> showPaywallIfNeeded(
  BuildContext context,
  WidgetRef ref, {
  String? featureName,
}) async {
  final isPremium = ref.read(isPremiumProvider);
  if (isPremium) return true;

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PaywallScreen(featureName: featureName),
    ),
  );
  return result == true;
}
