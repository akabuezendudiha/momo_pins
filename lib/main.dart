import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:momo_pins/router.dart';

import 'locator.dart';

GetIt locator = GetIt.instance;
const channelTag = 'com.mguardsolutions.momo_pins/service';
const streamTag = 'com.mguardsolutions.momo_pins/stream';

// Method Channel Event Args names'
const simIdArg = 'sim_id';
const dialCodeArg = 'dial_code';

// Method Channel Names
const connectTag = 'connect';
const disconnectTag = 'disconnect';
const openAccessibilityTag = 'open_accessibility_settings';
const dialSingleUssdTag = 'dial_single_step_ussd_code';
const dialMultipleUssdTag = 'dial_multi_step_ussd_code';

void main() {
  setupLocator();
  // Ensure initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momo PIN(s)',
      theme: ThemeData(
        primarySwatch: Colors.amber,               
        appBarTheme: AppBarTheme(
          toolbarTextStyle: Theme.of(context).textTheme.headlineSmall,
          titleTextStyle: Theme.of(context).textTheme.titleMedium, 
        ),
      ),       
      initialRoute: '/',
      onGenerateRoute: MyRouter.generateRoute,
    );
  }
}
