import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:booku/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:booku/themes/themes.dart';
import 'package:flutter/foundation.dart';

class Paywall extends StatefulWidget {
  const Paywall({Key? key, required this.offer, required this.selectedIndex})
      : super(key: key);

  final Offering offer;
  final int selectedIndex;

  @override
  _PaywallState createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  late List<Package> availablePackages;
  late List<ThemeData> themes = allThemes;

  @override
  void initState() {
    super.initState();
    availablePackages = _getAvailablePackages();
  }

  List<Package> _getAvailablePackages() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return widget.offer.availablePackages
        .where((package) =>
            !themeProvider.isThemePurchased(getThemeForPackage(package)))
        .toList();
  }

  Map<String, ThemeData> packageThemeMap = {
    'purple_theme': purpleTheme,
    'teal_theme': tealTheme,
    'orange_theme': orangeTheme,
    'green_theme': greenTheme
    // Add more mappings for other themes
  };

  ThemeData getThemeForPackage(Package package) {
    // Get the theme based on the package identifier
    ThemeData? theme = packageThemeMap[package.identifier];
    // Return the theme if found, or a default theme otherwise
    return theme ?? redTheme;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'Buy A Theme',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          for (Package package in availablePackages)
            Card(
              child: ListTile(
                title: Text(package.storeProduct.title),
                subtitle: Text(package.storeProduct.description),
                trailing: Text(package.storeProduct.priceString),
                onTap: () async {
                  _handleProductSelection(context, package);
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleProductSelection(
      BuildContext context, Package package) async {
    await Purchases.purchasePackage(package);

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.all.containsKey(package.identifier)) {
      final ThemeData purchasedTheme = getThemeForPackage(package);
      Provider.of<ThemeProvider>(context, listen: false)
          .addPurchasedTheme(purchasedTheme);

      setState(() {
        availablePackages = _getAvailablePackages();
      });

      Navigator.pop(
          context, true); // Return true to indicate a successful purchase
    }
  }

  // Future<void> restorePurchases(Package package) async {
  //   CustomerInfo customerInfo = await Purchases.restorePurchases();
  //   print('customer id: ${customerInfo.originalAppUserId}');
  //   print('customer entitlements : ${customerInfo.entitlements.all.length}');
    
  //   for(String entitlementId in customerInfo.entitlements.all.keys){
  //     if(packageThemeMap.containsKey(entitlementId)){
  //       ThemeData? theme = packageThemeMap[entitlementId];
  //       print('entitlement id : $entitlementId');
  //       print('Mathcing theme found : $theme');

  //       if(entitlementId.contains(package.identifier)){
  //         // final ThemeData restoredThemes = Paywall();
  //       }
  //     }
  //   }
  // }
}
