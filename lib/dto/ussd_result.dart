
import 'package:momo_pins/dto/ussd_result_state.dart';

class UssdResult {
  UssdResultState ussdState;
  String message;
  UssdResult({required this.ussdState, required this.message});
}