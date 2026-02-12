import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat configuration
class RevenueCatConfig {
  // TODO: Replace with your actual RevenueCat API keys
  static const String appleApiKey = 'appl_YOUR_REVENUECAT_APPLE_API_KEY';
  static const String googleApiKey = 'goog_YOUR_REVENUECAT_GOOGLE_API_KEY';

  static const String entitlementId = 'premium';
  static const String monthlyProductId = 'gabby_premium_monthly';
  static const String yearlyProductId = 'gabby_premium_yearly';
}

/// Subscription status model
class SubscriptionStatus {
  final bool isPremium;
  final String? activeProductId;
  final DateTime? expirationDate;
  final bool isTrialing;

  const SubscriptionStatus({
    this.isPremium = false,
    this.activeProductId,
    this.expirationDate,
    this.isTrialing = false,
  });

  static const free = SubscriptionStatus();
}

/// RevenueCat service singleton
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._();
  factory RevenueCatService() => _instance;
  RevenueCatService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final apiKey = Platform.isIOS
          ? RevenueCatConfig.appleApiKey
          : RevenueCatConfig.googleApiKey;

      if (apiKey.contains('YOUR_') || apiKey.contains('REPLACE') || apiKey.isEmpty) {
        debugPrint('[RevenueCat] Skipping — placeholder API key');
        return;
      }

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);

      // Enable debug logs in development
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      _initialized = true;
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat initialization failed: $e');
      // App continues to work in free mode if RC fails
    }
  }

  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (!_initialized) return SubscriptionStatus.free;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _parseCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('Error getting subscription status: $e');
      return SubscriptionStatus.free;
    }
  }

  Future<List<Package>> getOfferings() async {
    if (!_initialized) return [];

    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting offerings: $e');
      return [];
    }
  }

  Future<SubscriptionStatus> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return _parseCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('Purchase failed: $e');
      rethrow;
    }
  }

  Future<SubscriptionStatus> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _parseCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('Restore failed: $e');
      rethrow;
    }
  }

  SubscriptionStatus _parseCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[RevenueCatConfig.entitlementId];
    if (entitlement != null && entitlement.isActive) {
      return SubscriptionStatus(
        isPremium: true,
        activeProductId: entitlement.productIdentifier,
        expirationDate: entitlement.expirationDate != null
            ? DateTime.tryParse(entitlement.expirationDate!)
            : null,
        isTrialing: entitlement.periodType == PeriodType.trial,
      );
    }
    return SubscriptionStatus.free;
  }
}

/// Riverpod providers for subscription state
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionNotifier() : super(kDebugMode ? const SubscriptionStatus(isPremium: true) : SubscriptionStatus.free) {
    _init();
  }

  Future<void> _init() async {
    final status = await RevenueCatService().getSubscriptionStatus();
    state = status;
  }

  Future<void> refresh() async {
    final status = await RevenueCatService().getSubscriptionStatus();
    state = status;
  }

  Future<void> purchasePackage(Package package) async {
    final status = await RevenueCatService().purchasePackage(package);
    state = status;
  }

  Future<void> restorePurchases() async {
    final status = await RevenueCatService().restorePurchases();
    state = status;
  }
}

/// Convenience provider: is the user premium?
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPremium;
});

/// Free tier limits
class FreeTierLimits {
  static const int maxHabits = 3;
  static const bool challengesEnabled = false;
  static const bool aiInsightsEnabled = false;
  static const bool weeklyReviewEnabled = false;
  static const bool habitStackingEnabled = false;
}
