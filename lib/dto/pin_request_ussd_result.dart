import 'package:momo_pins/dto/ussd_result_state.dart';

class PinRequestUssdResult {
  UssdResultState ussdState;
  String? error;
  String? pin;
  String? serial;
  int? amount;
  PinRequestUssdResult({
    required this.ussdState,
    this.error,
    this.pin,
    this.serial,
    this.amount,    
  });
}
