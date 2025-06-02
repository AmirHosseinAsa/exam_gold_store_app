import 'dart:ui';
import 'package:exam_gold_store_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppTheme.dark(),
      scrollBehavior: MyCustomScrollBehavior(),
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
