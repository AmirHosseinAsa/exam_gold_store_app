import 'package:exam_gold_store_app/application.dart';
import 'package:exam_gold_store_app/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initialize();
  Intl.defaultLocale = 'fa_IR';
  runApp(const Application());

  doWhenWindowReady(() {
    const initialSize = Size(800, 600);
    appWindow.minSize = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'طلا فروشی';
    appWindow.maximize();
    appWindow.show();
  });
}
