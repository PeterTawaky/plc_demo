import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:plc_demo/clean_code_practice/text_field_model.dart';
import 'package:plc_demo/service/app_enums.dart';
import 'package:plc_demo/service/plc_consumer.dart';

part 'test_state.dart';

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(TestInitial());

  bool isConnected = false;
  Timer? _readTimer;
  bool _shouldKeepReading = false;

  final List<TextEditingController> controllers = List.generate(
    30,
    (_) => TextEditingController(),
  );

  // @override
  // Future<void> close() {
  //   for (final controller in [
  //     ...intControllers,
  //     ...doubleControllers,
  //     ...realControllers,
  //   ]) {
  //     controller.dispose();
  //   }

  //   for (final focusNode in [
  //     ...intFocusNodes,
  //     ...doubleFocusNodes,
  //     ...realFocusNodes,
  //   ]) {
  //     focusNode.dispose();
  //   }

  //   _readTimer?.cancel();
  //   return super.close();
  // }

  Future<void> connectToPLC({required List<TextFieldModel> textFields}) async {
    final success = await PLCService.connect("192.168.0.1", 0, 1);
    isConnected = success;
    //TODO
    if (success) {
      _startContinuousReading(textFields: textFields);
      log('connected to PLC successfully');
    } else {
      log('Connection failed with PLC');
    }
  }

  void _startContinuousReading({required List<TextFieldModel> textFields}) {
    _shouldKeepReading = true;
    _readTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_shouldKeepReading || !isConnected) {
        timer.cancel();
        return;
      }
      // log('again reading');
      readAllValues(textFields: textFields);
    });
  }

  Future<void> readAllValues({required List<TextFieldModel> textFields}) async {
    if (!isConnected) return;

    try {
      //initialize controllers with value on server
      for (var i = 0; i < textFields.length; i++) {
        textFields[i].valuesFromPLC = await PLCService.read(
          textFields[i].type,
          textFields[i].address,
        );
        if (!textFields[i].focusNode.hasFocus) {
          controllers[i].text = textFields[i].valuesFromPLC.toString();
        }
      }

      log('read from plc successfully');
    } catch (e) {
      log('Read error: $e');
    }
  }

  Future<void> disconnectFromPLC() async {
    _stopContinuousReading();
    PLCService.disconnect();
    isConnected = false;
    log('Disconnected');
  }

  void _stopContinuousReading() {
    _shouldKeepReading = false;
    _readTimer?.cancel();
  }

  void writeData({
    required TextEditingController controller,
    required String address,
    required TagType type,
    required dynamic value,
  }) {
    try {
      switch (type) {
        case TagType.int:
          value = int.parse(controller.text);
          PLCService.write(TagType.int, address, value);
          break;
        case TagType.dint:
          //?which parse type int or double
          value = int.parse(controller.text);
          PLCService.write(TagType.dint, address, value);
          break;
        case TagType.real:
          value = double.parse(controller.text);
          PLCService.write(TagType.real, address, value);
          break;
        default:
          break;
      }
      log('data added successfully');
    } on Exception catch (e) {
      log('Write error: $e');
    }
  }
}
