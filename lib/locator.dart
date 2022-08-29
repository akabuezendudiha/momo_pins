import 'package:momo_pins/helpers/pin_request_result_formatter.dart';
import 'package:momo_pins/services/file_ops_service.dart';
import 'package:momo_pins/helpers/shared_pref.dart';
import 'package:momo_pins/services/sms_service.dart';
import 'package:momo_pins/services/telephony_service.dart';

import 'main.dart';

void setupLocator() {
  locator.registerLazySingleton<TelephonyService>(() => TelephonyService());
  locator.registerLazySingleton<AppSharedPreference>(() => AppSharedPreference());
  locator.registerLazySingleton<SmsService>(() => SmsService());
  locator.registerLazySingleton<FileOpsService>(() => FileOpsService());
  locator.registerLazySingleton<PinRequestResultFormatter>(() => PinRequestResultFormatter());
}