import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:momo_pins/dto/ussd_result.dart';
import 'package:momo_pins/dto/ussd_result_state.dart';
import 'package:momo_pins/services/telephony_service.dart';
import 'package:momo_pins/main.dart';
import 'package:momo_pins/helpers/shared_pref.dart';

import '../dto/sim_card.dart';

class MomoBalance extends StatefulWidget {
  const MomoBalance({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MomoBalance> createState() => _MomoBalanceState();
}

enum RequestState { ongoing, success, error }

class _MomoBalanceState extends State<MomoBalance> {
  RequestState? requestState;
  String? balanceSnapshot;
  String defaultSnapshot = 'Tap the refresh button to view current Momo Balance';

  @override
  void initState() {
    super.initState();
    getMomoBalanceSnapshot();
  }

  // Gets the stored momo balance from shared preference
  void getMomoBalanceSnapshot() async {
    String? snapshot = await locator<AppSharedPreference>().getBalance();
    setState(() => balanceSnapshot = snapshot);
  }

  void resetUI() {
    setState(() {
      balanceSnapshot = defaultSnapshot;
      requestState = RequestState.error;
    });
  }

  Future<void> refreshMomoBalanceSnapshot() async {
    // Updates ongoing ussd request
    setState(() {
      requestState = RequestState.ongoing;
      balanceSnapshot = 'Fetching Momo Balance..';
    });

    try {
      // Connects to the USSD Service
      await locator<TelephonyService>().startUssdService();

      // Gets MoMo user pin
      String userPin = await locator<AppSharedPreference>().getVendPIN();
      if (userPin == 'Not Set') {
        await showOkAlertDialog(
            'Missing PIN',
            'MoMo User PIN is not configured!',
            'Go to settings and configure MoMo User PIN to proceed.');
        // Resets the UI
        resetUI();
      } else {
        SimCardData? simCardData =
            await locator<AppSharedPreference>().getSimCardData();
        if (simCardData == null) {
          await showOkAlertDialog(
              'Missing Sim Configuration',
              'Vend SIM Card not configured!',
              'Go to settings and configure Vend SIM Card to proceed.');
          // Resets the UI
          resetUI();
        } else {
          // Gets the Check balance ussd code string
          String checkBalanceCode =
              await locator<AppSharedPreference>().getBalanceUssdCode();
          // Updates the PIN placeholder with user pin
          checkBalanceCode = checkBalanceCode.replaceAll('PIN', userPin);
          await locator<TelephonyService>().runMomoBalanceUssd(
              dialCode: checkBalanceCode,
              slotIndex: simCardData.slotIndex,
              ussdResultCallback: (UssdResult ussdResult) {
                if (mounted) {
                  if (ussdResult.ussdState == UssdResultState.error) {
                    // Shows dialog
                    showOkAlertDialog(
                        'Missing Sim Configuration',
                        'Vend SIM Card not configured!',
                        'Go to settings and configure Vend SIM Card to proceed.');
                    // Updates UI State
                    setState(() {
                      requestState = RequestState.error;
                      balanceSnapshot = 'Unable to retrieve balance';
                    });
                  } else {
                    // Saves balance snapshot
                    locator<AppSharedPreference>()
                        .setBalance(ussdResult.message);
                    // Update UI State
                    setState(() {
                      requestState = RequestState.success;
                      balanceSnapshot = ussdResult.message;
                    });
                  }
                }
              });
        }
      }
    } on PlatformException catch (e) {
      showErrorDialog(e);
      // Resets the UI
      resetUI();
    }
  }

  void showErrorDialog(PlatformException e) async {
    if (mounted) {
      if (e.code == 'accessibilityServiceError' ||
          e.code == 'serviceConnectionError') {
        // Shows the error dialog
        await showOkAlertDialog(
          'Error',
          '${e.message}',
          '${e.details}',
        );
        // Opens the Accessibility settings
        await locator<TelephonyService>().openAccessibilitySettings();
      } else {
        await showOkAlertDialog(
          'Warning',
          '${e.message}',
          '${e.details}',
        );
      }
    }
  }

  Future<void> showOkAlertDialog(String title, String message,
      [String extraMessage = '']) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                Text(extraMessage),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 18.0, left: 18.0),
        child: Center(
          child: Text(
            balanceSnapshot ??
                defaultSnapshot,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 36,
              color: Colors.green[900],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // refreshes momo balance
          if (requestState != RequestState.ongoing) {
            refreshMomoBalanceSnapshot();
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
