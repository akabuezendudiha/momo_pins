import 'package:momo_pins/dto/ussd_result_state.dart';
import 'package:momo_pins/dto/pin_request_ussd_result.dart';
import 'package:momo_pins/dto/vend_type.dart';
import 'package:momo_pins/helpers/shared_pref.dart';
import 'package:momo_pins/main.dart';

class PinRequestResultFormatter {
  /// Function to decode PIN request result message
  /// Returns PinRequestUssdResult object contain
  /// [Pin]
  /// [Serial]
  /// [Amount]
  /// [UssdResultState]
  PinRequestUssdResult decodePinRequestResponse(String ussdResponse) {
    if (ussdResponse.startsWith('Successful')) {
      // Splits the message by carriage return
      List<String> lines = ussdResponse.split('\n');

      // Returns PinRequest object
      return PinRequestUssdResult(
        ussdState: UssdResultState.success,
        pin: getPin(lines[1]),
        serial: getSerial(lines[2]),
        amount: getAmount(lines[4]),
      );
    } else {
      return PinRequestUssdResult(
        ussdState: UssdResultState.error,
        error: ussdResponse,
      );
    }
  }

  String getPin(String line) {
    return line.replaceAll('Sale: ', '');
  }

  String getSerial(String line) {
    return line.replaceAll('Serial: ', '');
  }

  int getAmount(String line) {
    return int.parse(line.replaceAll('Amount: N', '').replaceAll('.00', ''));
  }

  /// Returns the PIN Request Dial Code with
  /// all placeholders set i.e.:
  /// [cellNumber]
  /// [vendOption] - for amount
  /// [vendPin]
  Future<String> getPinRequestDialCode() async {
    // Get Cell Number
    String cellNumber = await locator<AppSharedPreference>().getVendNumber();
    // Get VendType option
    VendType? vendType = await locator<AppSharedPreference>().getVendType();
    int? vendOption = vendType?.option;
    // Get Vend Pin
    String vendPin = await locator<AppSharedPreference>().getVendPIN();
    // Get PIN Request Ussd Code
    String pinRequestCode =
        await locator<AppSharedPreference>().getPinRequestUssdCode();

    // Return Pin request code with all placeholder values
    return pinRequestCode
        .replaceAll('NUMBER', cellNumber)
        .replaceAll('AMOUNT', '$vendOption')
        .replaceAll('PIN', vendPin);
  }
}
