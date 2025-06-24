import 'package:flutter/widgets.dart';
import 'package:plc_demo/service/app_enums.dart';

class TextFieldModel {
  final String address;
  final TagType type;
  final FocusNode focusNode = FocusNode();
  dynamic valuesFromPLC;
  TextFieldModel({
    required this.address,
    required this.type,
    this.valuesFromPLC,
  });
}

// class TextFieldModel {
//   TextEditingController controller;
//   String address;
//   dynamic serverValue;
//   void Function(String)? onSubmitted;
//   TextFieldModel({
//     required this.controller,
//     required this.address,
//     required this.serverValue,
//     required onSubmitted,
//   });
// }
