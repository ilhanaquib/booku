import 'package:booku/themes/themes.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:booku/themes/theme_provider.dart';

class PurchaseApi {
  static const _apiKey = 'goog_YnBHrKHEtGrJvUzPFqxKMyoIPmd';
  static String? _appUserId;

  static Future init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
        PurchasesConfiguration(_apiKey)..appUserID = _appUserId);
  }

  static void setAppUserId(String appUserId) {
    _appUserId = appUserId;
    init();
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return [];
    }
  }

  static Future<void> restorePurchases() async {
    try {
     final restoredInfo =  await Purchases.restorePurchases();
     final entitlementInfo = await Purchases.getCustomerInfo();

     if(restoredInfo.entitlements.active.containsKey(entitlementInfo.entitlements.active)){

        ThemeProvider().addPurchasedTheme(purpleTheme);
     } 
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
