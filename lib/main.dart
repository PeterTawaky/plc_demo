// lib/main.dart
import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plc_demo/clean_code_practice/text_field_model.dart';
import 'package:plc_demo/cubit/test_cubit.dart';
import 'package:plc_demo/model/tag_model.dart';
import 'package:plc_demo/service/app_enums.dart';
import 'package:plc_demo/service/excel_service.dart';
import 'package:plc_demo/widgets/layout/custom_vertical_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //detect GPU stalls
  Timer.periodic(Duration(seconds: 10), (_) {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      debugPrint("⚠️ App appears to have paused or lost context.");
    }
  });
  List<TagModel> tags = await fetchExcelTags();
  List<TagModel> tags100 = [];
  List<TagModel> tags250 = [];
  List<TagModel> tags500 = [];
  for (var tag in tags) {
    if (tag.acquistion == 100) {
      tags100.add(tag);
    } else if (tag.acquistion == 250) {
      tags250.add(tag);
    } else if (tag.acquistion == 500) {
      tags500.add(tag);
    }
  }
  print(tags.length);
  runApp(MyApp(tags: tags));
}

Future<List<TagModel>> fetchExcelTags() async {
  List<TagModel> tags = await ExcelService.readExcelData(
    localExcelPath: 'assets/tags.xlsx',
  );

  return tags;
}

class MyApp extends StatelessWidget {
  final List<TagModel> tags;

  const MyApp({Key? key, required this.tags}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<TextFieldModel> textFields = [];

    for (var tag in tags) {
      textFields.add(
        TextFieldModel(
          address: tag.address,
          type: TagType.bool,
          acquistion: tag.acquistion,
        ),
      );
    }
    // for (
    //   var i = 0, numberForDataBase = 0;
    //   i < 1000;
    //   i++, numberForDataBase += 4
    // ) {
    //   textFields.add(
    //     TextFieldModel(
    //       address: 'DB1.DBD$numberForDataBase',
    //       type: TagType.real,
    //     ),
    //   );
    // }

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
