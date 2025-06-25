// lib/main.dart
import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plc_demo/clean_code_practice/text_field_model.dart';
import 'package:plc_demo/cubit/test_cubit.dart';
import 'package:plc_demo/service/app_enums.dart';
import 'package:plc_demo/widgets/layout/custom_vertical_list.dart';

void main() {
  //detect GPU stalls
  Timer.periodic(Duration(seconds: 10), (_) {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      debugPrint("⚠️ App appears to have paused or lost context.");
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<TextFieldModel> textFields = [];
    for (
      var i = 0, numberForDataBase = 0;
      i < 1000;
      i++, numberForDataBase += 4
    ) {
      textFields.add(
        TextFieldModel(
          address: 'DB1.DBD$numberForDataBase',
          type: TagType.real,
        ),
      );
    }

    debugPrint(textFields.length.toString());

    return MaterialApp(
      title: 'PLC Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => TestCubit()..connectToPLC(textFields: textFields),
        child: Scaffold(
          body: Expanded(child: CustomVerticalList(textFields: textFields)),
        ),
      ),
      // const PLCDemoPage(),
    );
  }
}
