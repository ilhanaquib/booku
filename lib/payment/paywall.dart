import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Paywall extends StatefulWidget {
  const Paywall({Key? key, required this.offer}) : super(key: key);

  final Offering offer;

  @override
  _PaywallState createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  late List<Package> availablePackages;

  @override
  void initState() {
    super.initState();
    availablePackages = widget.offer.availablePackages;
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
                onTap: () {
                  _handleProductSelection(context, package);
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleProductSelection(BuildContext context, Package package) async {
    await Purchases.purchasePackage(package);

    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    if(customerInfo.entitlements == package.identifier){
      print('both customerInfor entitlement and package identifier is the same');
      setState(() {
        availablePackages.remove(package);
      });
    }   
  }
}
