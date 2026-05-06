import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:air_control/src/app.dart';
import 'package:air_control/src/core/utils/http_overrides.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up Http Overrides
  HttpOverrides.global = MyHttpOverrides();
  
  // Configure System UI
  await _configureSystemUI();

  runApp(const AirControlApp());
}

Future<void> _configureSystemUI() async {
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}
