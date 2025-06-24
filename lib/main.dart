// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plc_demo/clean_code_practice/text_field_model.dart';
import 'package:plc_demo/cubit/test_cubit.dart';
import 'package:plc_demo/service/app_enums.dart';
import 'package:plc_demo/widgets/layout/custom_vertical_list.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<TextFieldModel> textFields = [
      TextFieldModel(address: 'DB1.DBW0', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW2', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW4', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW6', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW8', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW10', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW12', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW14', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW16', type: TagType.int),
      TextFieldModel(address: 'DB1.DBW18', type: TagType.int),
      TextFieldModel(address: 'DB1.DBD20', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD24', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD28', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD32', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD36', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD40', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD44', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD48', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD52', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD56', type: TagType.dint),
      TextFieldModel(address: 'DB1.DBD60', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD64', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD68', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD72', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD76', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD80', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD84', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD88', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD92', type: TagType.real),
      TextFieldModel(address: 'DB1.DBD96', type: TagType.real),
    ];
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
