import 'dart:async';

import 'package:momo_pins/dto/ussd_result_state.dart';
import 'package:momo_pins/helpers/pin_request_result_formatter.dart';
import 'package:momo_pins/main.dart';
import 'package:flutter/services.dart';
import 'package:momo_pins/dto/ussd_result.dart';
import 'package:permission_handler/permission_handler.dart';

class TelephonyService {
  static const MethodChannel _channel = MethodChannel(channelTag);
  static const EventChannel _stream = EventChannel(streamTag);
  StreamSubscription? _ussdServiceSubscription;

  Future<bool> _ussdServicePermissionIsGranted() async {
    // Requests for phone permission
    await Permission.phone.request();

    // checks accessibility options
    await openAccessibilitySettings();

    return await Permission.phone.isGranted;
  }

  void runMomoPinRequestUssd({
    required String dialCode,
    required int slotIndex,
    required Function ussdResultCallback,
  }) async {
    try {
      // Gets call permission
      await startUssdService();
      // Sends Pin request ussd request
      await _dialUssdCodeAndReturnResult(
        dialCode: dialCode,
        slotIndex: slotIndex,
        ussdCallBack: (ussdResponse) {
          _stopListeningForResult();
          _stopUssdService();
          ussdResultCallback(locator<PinRequestResultFormatter>()
              .decodePinRequestResponse(ussdResponse));
        },
      );
    } on PlatformException {
      rethrow;
    }
  }

  Future runMomoBalanceUssd({
    required String dialCode,
    required int slotIndex,
    required Function ussdResultCallback,
  }) async {
    try {
      // Gets call permission
      if (await _ussdServicePermissionIsGranted()) {
        // Starts the USSD service
        await startUssdService();
        // initiates the single step ussd call
        await _dialUssdCodeAndReturnResult(
            dialCode: dialCode,
            slotIndex: slotIndex,
            ussdCallBack: (momoBalanceResponse) {
              _stopListeningForResult();
              _stopUssdService();
              ussdResultCallback(UssdResult(
                ussdState: UssdResultState.success,
                message: momoBalanceResponse,
              ));
            });
      } else {
        ussdResultCallback(UssdResult(
          ussdState: UssdResultState.error,
          message: 'Call and Accessibility permissions are required!',
        ));
      }
    } on PlatformException {
      rethrow;
    }
  }

  Future startUssdService() async {
    try {
      await _channel.invokeMethod(connectTag);
    } on PlatformException {
      rethrow;
    }
  }

  Future _stopUssdService() async {
    try {
      await _channel.invokeMethod(disconnectTag);
    } on PlatformException {
      rethrow;
    }
  }

  Future<void> _invokePlatformFunction({
    required String methodName,
    required Function(String response) ussdCallback,
    required Map<String, dynamic> data,
  }) async {
    try {
      var result = await _channel.invokeMethod(methodName, data);
      if (result == 'success') {
        _startListeningForResult(ussdCallback);
      }
    } on PlatformException {
      await _stopListeningForResult();
      rethrow;
    }
  }

  void _startListeningForResult(Function(String response) callback) {
    _ussdServiceSubscription ??= _stream
        .receiveBroadcastStream()
        .listen((response) => callback(response.toString()));
  }

  Future<void> _stopListeningForResult() async {
    if (_ussdServiceSubscription != null) {
      _ussdServiceSubscription?.cancel();
      _ussdServiceSubscription = null;
    }
  }

  Future openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod(openAccessibilityTag);
    } on PlatformException {
      rethrow;
    }
  }

  Future<void> _dialUssdCodeAndReturnResult({
    required String dialCode,
    required int slotIndex,
    required Function(String response) ussdCallBack,
  }) async {
    Map<String, dynamic> data = {
      simIdArg: slotIndex,
      dialCodeArg: dialCode,
    };
    await _invokePlatformFunction(
      ussdCallback: ussdCallBack,
      methodName: dialSingleUssdTag,
      data: data,
    );
  }
}
