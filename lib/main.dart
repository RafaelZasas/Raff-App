import 'dart:async';

import 'package:Raffs_App/pages/note_page.dart';
import 'package:Raffs_App/utils/colors.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

//this app is based on https://github.com/urmilshroff/dashboard_reborn

FirebaseAnalytics analytics;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // future added for async modifier
  await Firebase.initializeApp(); // initialize firebase
  analytics = FirebaseAnalytics(); // initialize analytics
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  // Create the initialization Future outside of `build`:

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => ThemeData(
        fontFamily: 'Quicksand',
        primaryColor: MyColors.primary,
        accentColor: MyColors.accent,
        brightness: brightness, // default is dark
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'Raff\s App',
          theme: theme,
          home: MyNotePage(),
        );
      },
    );
  }
}
