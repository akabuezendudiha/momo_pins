import 'package:flutter/material.dart';
import 'package:momo_pins/dto/sim_card.dart';
import 'package:momo_pins/helpers/shared_pref.dart';
import 'package:momo_pins/main.dart';
import 'package:settings_ui/settings_ui.dart';

import '../dto/vend_type.dart';
import '../widgets/multi_entry_select_dialogs.dart';
import '../widgets/single_entry_text_dialog.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  String simSlotIndex = '';
  String cellPhone = '';
  String vendPin = '';
  String vendType = '';
  int? vendDelay;
  int? vendRetries;
  String checkBalanceCode = '';
  String changePinCode = '';
  String pinRequestCode = '';

  void fetchSettings() async {
    // Gets all save settings params
    SimCardData? simCardData =
        await locator<AppSharedPreference>().getSimCardData();
    String cell = await locator<AppSharedPreference>().getVendNumber();
    String pin = await locator<AppSharedPreference>().getVendPIN();
    VendType? vendOption = await locator<AppSharedPreference>().getVendType();
    int delayDuration = await locator<AppSharedPreference>().getVendDelay();
    int retries = await locator<AppSharedPreference>().getVendRetries();
    String balanceCode =
        await locator<AppSharedPreference>().getBalanceUssdCode();
    String pinCode =
        await locator<AppSharedPreference>().getChangePinUssdCode();
    String requestCode =
        await locator<AppSharedPreference>().getPinRequestUssdCode();

    // Updates UI State
    setState(() {
      simSlotIndex =
          simCardData != null ? 'SIM 0${simCardData.slotIndex + 1}' : 'Not Set';
      cellPhone = cell;
      vendPin = pin;
      vendType = vendOption?.text ?? 'Not Set';
      vendDelay = delayDuration;
      vendRetries = retries;
      checkBalanceCode = balanceCode;
      changePinCode = pinCode;
      pinRequestCode = requestCode;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SettingsList(
          sections: [
            SettingsSection(
              title: const Text('SIM Vend Options',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  onPressed: (context) async {
                    // Get user selected SIM
                    var simCardData = await showSelectSimDialog(context);
                    if (simCardData != null) {
                      // Saves SIM Slot
                      await locator<AppSharedPreference>()
                          .setSimCardData(simCardData);
                      // Updates UI state
                      setState(() {
                        simSlotIndex = 'SIM 0${simCardData.slotIndex + 1}';
                      });
                    }
                  },
                  leading: const Icon(Icons.sim_card),
                  title: const Text('Vend SIM Card Slot'),
                  value: Text(simSlotIndex),
                ),
                SettingsTile.navigation(
                  onPressed: (context) async {
                    // Gets cell number
                    var cell = await showSingleEntryTextDialog(
                      context: context,
                      title: 'Vend Cell Number',
                      hint: 'Enter Number Here..',
                      prevValue: cellPhone != 'Not Available' ? cellPhone : '',
                    );
                    // Saves the cell number
                    if (cell != null) {
                      // Saves SIM Slot
                      await locator<AppSharedPreference>().setVendNumber(cell);
                      // Updates UI state
                      setState(() {
                        cellPhone = cell;
                      });
                    }
                  },
                  leading: const Icon(Icons.phone),
                  title: const Text('Vend Cell Number'),
                  value: Text(cellPhone),
                ),
                SettingsTile.navigation(
                  onPressed: (context) async {
                    // Gets vend pin
                    var pin = await showSingleEntryTextDialog(
                      context: context,
                      title: 'Vend PIN',
                      hint: 'Enter Vend PIN Here..',
                      prevValue: vendPin != 'Not Set' ? vendPin : '',
                    );
                    // Saves the cell number
                    if (pin != null) {
                      // Saves SIM Slot
                      await locator<AppSharedPreference>().setVendPIN(pin);
                      // Updates UI state
                      setState(() {
                        vendPin = pin;
                      });
                    }
                  },
                  leading: const Icon(Icons.password),
                  title: const Text('Momo PIN'),
                  value: Text(vendPin),
                ),
              ],
            ),
            SettingsSection(
              title: const Text(
                'Vend Variables',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (context) async {
                    // Get user selected SIM
                    var vendOption = await showSelectVendTypeDialog(context);
                    if (vendOption != null) {
                      // Saves SIM Slot
                      await locator<AppSharedPreference>()
                          .setVendType(vendOption);
                      // Updates UI state
                      setState(() {
                        vendType = vendOption.text;
                      });
                    }
                  },
                  leading: const Icon(Icons.unfold_more_outlined),
                  title: const Text('Logical PIN Type'),
                  value: Text(vendType),
                ),
                SettingsTile.navigation(
                  onPressed: (context) async {
                    var duration = await showSelectVendDisplayDialog(context);
                    if (duration != null) {
                      // Saves vend delay
                      await locator<AppSharedPreference>()
                          .setVendDelay(duration);
                      // Updates UI state
                      setState(() {
                        vendDelay = duration;
                      });
                    }
                  },
                  leading: const Icon(Icons.refresh),
                  title: const Text('Vend Delay'),
                  value: Text(
                      '$vendDelay ${vendDelay == 1 ? 'Second' : 'Seconds'}'),
                ),
                SettingsTile.navigation(
                    onPressed: (context) async {
                      var retries = await showSelectVendRetryDialog(context);
                      if (retries != null) {
                        // Saves vend retries
                        await locator<AppSharedPreference>()
                            .setVendRetries(retries);
                        // Updates UI state
                        setState(() {
                          vendRetries = retries;
                        });
                      }
                    },
                    leading: const Icon(Icons.numbers),
                    title: const Text('Vend Retry Count'),
                    value: Text('$vendRetries times'))
              ],
            ),
            SettingsSection(
              title: const Text(
                'USSD Endpoint Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.phone_android),
                  title: const Text('MoMo Menu USSD Code'),
                  description: const Text('E.g. 502'),
                  value: const Text('502'),
                ),
                SettingsTile.navigation(
                  onPressed: (context) async {
                    // Gets check balance code
                    var balanceCode = await showSingleEntryTextDialog(
                      context: context,
                      title: 'Momo Balance USSD Code',
                      hint: 'Enter USSD Here..',
                      prevValue: checkBalanceCode,
                      keyboardType: TextInputType.text,
                    );
                    // Saves the check balance ussd code
                    if (balanceCode != null) {
                      // Saves SIM Slot
                      await locator<AppSharedPreference>()
                          .setCheckBalanceCode(balanceCode);
                      // Updates UI state
                      setState(() {
                        checkBalanceCode = balanceCode;
                      });
                    }
                  },
                  leading: const Icon(Icons.balance),
                  title: const Text('MoMo Balance USSD Code'),
                  description: const Text('E.g. *502*5*PIN#'),
                  value: Text(checkBalanceCode),
                ),
                SettingsTile.navigation(
                  onPressed: (context) async {
                    // Gets check balance code
                    var pinCode = await showSingleEntryTextDialog(
                      context: context,
                      title: 'Momo PIN Request USSD Code',
                      hint: 'Enter USSD Here..',
                      prevValue: pinRequestCode,
                      keyboardType: TextInputType.phone,
                    );
                    // Saves Pin request USSD
                    if (pinCode != null) {
                      await locator<AppSharedPreference>()
                          .setPinRequestUssdCode(pinCode);
                      // Updates UI state
                      setState(() {
                        pinRequestCode = pinCode;
                      });
                    }
                  },
                  leading: const Icon(Icons.code_sharp),
                  title: const Text('MoMo PIN Request USSD Code'),
                  description: const Text('E.g. *502*1*3*NUMBER*AMOUNT*PIN#'),
                  value: Text(pinRequestCode),
                ),
                SettingsTile.navigation(
                  onPressed: (context) async {
                    // Gets check balance code
                    var pinCode = await showSingleEntryTextDialog(
                      context: context,
                      title: 'Momo Change PIN USSD Code',
                      hint: 'Enter USSD Here..',
                      prevValue: changePinCode,
                      keyboardType: TextInputType.text,
                    );
                    // Saves the cell number
                    if (pinCode != null) {
                      // Saves Change pin USSD
                      await locator<AppSharedPreference>()
                          .setChangePinUssdCode(pinCode);
                      // Updates UI state
                      setState(() {
                        changePinCode = pinCode;
                      });
                    }
                  },
                  leading: const Icon(Icons.pin),
                  title: const Text('MoMo PIN Change USSD Code'),
                  description:
                      const Text('E.g. *502*5*OLD_PIN*NEW_PIN*NEW_PIN#'),
                  value: Text(changePinCode),
                ),
              ],
            ),
            SettingsSection(
              title: const Text(
                'About',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              tiles: [
                SettingsTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Version'),
                  description: const Padding(
                    padding: EdgeInsets.only(bottom: 22.0),
                    child: Text('1.00'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
