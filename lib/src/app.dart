import 'package:air_control/src/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:air_control/src/core/theme/app_theme.dart';

class AirControlApp extends StatelessWidget {
  const AirControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Air Control',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AirControlHomeScreen(),
      ),
    );
  }
}
