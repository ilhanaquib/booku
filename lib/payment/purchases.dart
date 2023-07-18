import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseApi {
  static const _apiKey = 'goog_YnBHrKHEtGrJvUzPFqxKMyoIPmd';

  static Future init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_apiKey));
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
}
