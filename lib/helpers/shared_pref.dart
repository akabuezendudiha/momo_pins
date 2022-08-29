import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../dto/sim_card.dart';
import '../dto/vend_type.dart';

class AppSharedPreference {
  Future<SharedPreferences> get sharedPref async {
    return await SharedPreferences.getInstance();
  }

  // Getter and Setter for Vend Cell Number
  Future<String> getVendNumber() async {
    final pref = await sharedPref;
    return pref.getString('cell') ?? 'Not Available';
  }

  Future<bool> setVendNumber(String msisdn) async {
    final pref = await sharedPref;
    return await pref.setString('cell', msisdn);
  }

  // Getter and Setter for Vend Type
  Future<VendType?> getVendType() async {
    final pref = await sharedPref;
    String? vendOption = pref.getString('vendType');
    if (vendOption != null) {
      Map<String, dynamic> map = jsonDecode(vendOption);
      return VendType.fromJson(map);
    } else {
      return null;
    }
  }

  Future<bool> setVendType(VendType vendType) async {
    final pref = await sharedPref;
    return await pref.setString('vendType', jsonEncode(vendType));
  }

  // Getter and Setter for Vend PIN
  Future<String> getVendPIN() async {
    final pref = await sharedPref;
    return pref.getString('vendPin') ?? 'Not Set';
  }

  Future<bool> setVendPIN(String vendPin) async {
    final pref = await sharedPref;
    return await pref.setString('vendPin', vendPin);
  }

  // Getter and Setter for SimCard
  Future<SimCardData?> getSimCardData() async {
    final pref = await sharedPref;
    String? simCard = pref.getString('sim');
    if (simCard != null) {
      Map<String, dynamic> map = jsonDecode(simCard);
      return SimCardData.fromJson(map);
    } else {
      return null;
    }
  }

  Future<bool> setSimCardData(SimCardData data) async {
    final pref = await sharedPref;
    return await pref.setString('sim', jsonEncode(data));
  }

  // Getter and Setter for vending balance snapshot
  Future<String?> getBalance() async {
    final pref = await sharedPref;
    return pref.getString('balance');
  }

  Future<bool> setBalance(String balance) async {
    final pref = await sharedPref;
    return await pref.setString('balance', balance);
  }

  // Getter and Setter for Balance UssdCode
  Future<String> getBalanceUssdCode() async {
    final pref = await sharedPref;
    return pref.getString('checkBalanceCode') ?? '*502*5*PIN#';
  }

  Future<bool> setCheckBalanceCode(String checkBalanceCode) async {
    final pref = await sharedPref;
    return await pref.setString('checkBalanceCode', checkBalanceCode);
  }

  // Getter and setter for PIN change UssdCode
  Future<String> getPinRequestUssdCode() async {
    final pref = await sharedPref;
    return pref.getString('pinRequestCode') ?? '*502*1*3*NUMBER*AMOUNT*PIN#';
  }
  Future<bool> setPinRequestUssdCode(String pinRequestCode) async {
    final pref = await sharedPref;
    return await pref.setString('pinRequestCode', pinRequestCode);
  }

  // Getter and setter for PIN change UssdCode
  Future<String> getChangePinUssdCode() async {
    final pref = await sharedPref;
    return pref.getString('changePinCode') ?? '*505*00*9*2*PIN*NEW_PIN*NEW_PIN#';
  }
  Future<bool> setChangePinUssdCode(String changePinCode) async {
    final pref = await sharedPref;
    return await pref.setString('changePinCode', changePinCode);
  }

  // Getter and Setter for vending delay duration
  Future<int> getVendDelay() async {
    final pref = await sharedPref;
    return pref.getInt('vendDelay') ?? 3;
  }

  Future<bool> setVendDelay(int vendDelay) async {
    final pref = await sharedPref;
    return await pref.setInt('vendDelay', vendDelay);
  }

  // Getter and Setter for vending retry count
  Future<int> getVendRetries() async {
    final pref = await sharedPref;
    return pref.getInt('vendRetries') ?? 3;
  }

  Future<bool> setVendRetries(int vendRetries) async {
    final pref = await sharedPref;
    return await pref.setInt('vendRetries', vendRetries);
  }  
}
