import 'package:flutter/material.dart';
import 'package:momo_pins/screens/backup_collection.dart';
import 'package:momo_pins/screens/home.dart';
import 'package:momo_pins/screens/momo_balance.dart';
import 'package:momo_pins/screens/pin_collection.dart';
import 'package:momo_pins/screens/settings.dart';

class MyRouter {
  static pageRoute(Widget widget) {
    return MaterialPageRoute(
      builder: (_) => widget,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        return pageRoute(const MyHome(title: "Momo PIN Downloader"));
      case '/pin_collections':
        return pageRoute(const PinCollection(title: "PIN(s) Collections"));
      case '/backup_collection':
        return pageRoute(const BackupCollection(title: 'Backup Collection'));
      case '/settings':
        return pageRoute(const Settings(title: 'Settings'));
      case '/balance':
        return pageRoute(const MomoBalance(title: 'Momo Balance'));
      default:
        return MaterialPageRoute(builder: (context) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            )
          );
        });
    }
  }
}