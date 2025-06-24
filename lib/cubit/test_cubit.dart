import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:plc_demo/clean_code_practice/text_field_dto_model.dart';
import 'package:plc_demo/clean_code_practice/text_field_model.dart';
import 'package:plc_demo/service/app_enums.dart';
import 'package:plc_demo/service/plc_service.dart';

part 'test_state.dart';

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(TestInitial());

  bool isConnected = false;
  Timer? _readTimer;
  bool _shouldKeepReading = false;
  bool _isCurrentlyReading = false;

  final List<TextEditingController> controllers = List.generate(
    80,
    (_) => TextEditingController(),
  );

  @override
  Future<void> close() {
    // Dispose controllers
    for (final controller in controllers) {
      controller.dispose();
    }

    _stopContinuousReading();
    return super.close();
  }

  Future<void> connectToPLC({required List<TextFieldModel> textFields}) async {
    emit(TestConnecting());
    
    try {
      final success = await PLCService.connect("192.168.0.1", 0, 1);
      isConnected = success;
      
      if (success) {
        _startContinuousReading(textFields: textFields);
        log('Connected to PLC successfully');
        emit(TestConnected());
      } else {
        log('Connection failed with PLC');
        emit(TestConnectionFailed('Failed to connect to PLC'));
      }
    } catch (e) {
      log('Connection error: $e');
      emit(TestConnectionFailed(e.toString()));
    }
  }

  void _startContinuousReading({required List<TextFieldModel> textFields}) {
    _shouldKeepReading = true;
    _readTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!_shouldKeepReading || !isConnected || _isCurrentlyReading) {
        if (!_shouldKeepReading || !isConnected) {
          timer.cancel();
        }
        return;
      }
      
      // Use optimized reading with chunking and yielding
      _readAllValuesOptimized(textFields);
    });
  }

  /// Optimized reading that processes data in chunks and yields control
  /// to prevent UI blocking while staying on the main thread
  Future<void> _readAllValuesOptimized(List<TextFieldModel> textFields) async {
    if (!isConnected || _isCurrentlyReading) return;

    _isCurrentlyReading = true;
    
    try {
      // Process in chunks to avoid blocking UI for too long
      const chunkSize = 5; // Adjust based on your PLC response time
      int processedCount = 0;
      
      for (int i = 0; i < textFields.length; i += chunkSize) {
        // Check if we should stop reading
        if (!_shouldKeepReading || !isConnected) break;
        
        final endIndex = (i + chunkSize < textFields.length) 
            ? i + chunkSize 
            : textFields.length;
        
        // Process chunk synchronously (since PLC calls must be synchronous)
        for (int j = i; j < endIndex; j++) {
          try {
            textFields[j].valuesFromPLC = PLCService.read(
              textFields[j].type,
              textFields[j].address,
            );
            
            // Update UI only if user is not editing
            if (!textFields[j].focusNode.hasFocus) {
              controllers[j].text = textFields[j].valuesFromPLC.toString();
            }
            
            processedCount++;
          } catch (e) {
            log('Error reading field $j: $e');
          }
        }
        
        // Yield control to UI thread after each chunk
        // This allows UI to remain responsive
        await Future.delayed(Duration.zero);
      }

      if (processedCount > 0) {
        log('Read $processedCount values from PLC successfully');
        emit(TestDataUpdated());
      }
      
    } catch (e) {
      log('Read error: $e');
      emit(TestError('Read error: $e'));
    } finally {
      _isCurrentlyReading = false;
    }
  }

  /// Alternative: Batch reading with error recovery
  Future<void> _readAllValuesBatched(List<TextFieldModel> textFields) async {
    if (!isConnected || _isCurrentlyReading) return;

    _isCurrentlyReading = true;
    
    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      
      // Group reads by data block for efficiency (if your PLC supports it)
      final Map<String, List<int>> addressGroups = {};
      
      for (int i = 0; i < textFields.length; i++) {
        final address = textFields[i].address;
        // Extract DB number (assuming format like "DB1.DBW0")
        final dbPart = address.split('.')[0];
        
        addressGroups.putIfAbsent(dbPart, () => []).add(i);
      }
      
      int successCount = 0;
      int errorCount = 0;
      
      // Process each group
      for (final group in addressGroups.entries) {
        if (!_shouldKeepReading || !isConnected) break;
        
        for (final index in group.value) {
          try {
            textFields[index].valuesFromPLC = PLCService.read(
              textFields[index].type,
              textFields[index].address,
            );
            
            if (!textFields[index].focusNode.hasFocus) {
              controllers[index].text = textFields[index].valuesFromPLC.toString();
            }
            
            successCount++;
          } catch (e) {
            errorCount++;
            log('Error reading field $index: $e');
          }
        }
        
        // Yield after each DB group
        await Future.delayed(Duration.zero);
      }
      
      stopwatch.stop();
      log('Batch read completed: $successCount success, $errorCount errors, ${stopwatch.elapsedMilliseconds}ms');
      
      if (successCount > 0) {
        emit(TestDataUpdated());
      }
      
    } catch (e) {
      log('Batch read error: $e');
      emit(TestError('Batch read error: $e'));
    } finally {
      _isCurrentlyReading = false;
    }
  }

  Future<void> disconnectFromPLC() async {
    _stopContinuousReading();
    
    try {
      PLCService.disconnect();
      isConnected = false;
      log('Disconnected from PLC');
      emit(TestDisconnected());
    } catch (e) {
      log('Disconnect error: $e');
      emit(TestError('Disconnect error: $e'));
    }
  }

  void _stopContinuousReading() {
    _shouldKeepReading = false;
    _readTimer?.cancel();
  }

  Future<void> writeData({
    required TextEditingController controller,
    required String address,
    required TagType type,
    required dynamic value,
  }) async {
    try {
      emit(TestWriting());
      
      switch (type) {
        case TagType.int:
          value = int.parse(controller.text);
          PLCService.write(TagType.int, address, value);
          break;
        case TagType.dint:
          value = int.parse(controller.text);
          PLCService.write(TagType.dint, address, value);
          break;
        case TagType.real:
          value = double.parse(controller.text);
          PLCService.write(TagType.real, address, value);
          break;
        default:
          throw Exception('Unsupported tag type: $type');
      }
      
      log('Data written successfully');
      emit(TestWriteSuccess());
    } catch (e) {
      log('Write error: $e');
      emit(TestError('Write error: $e'));
    }
  }

  /// Manual trigger for single read operation
  Future<void> performSingleRead({required List<TextFieldModel> textFields}) async {
    if (!isConnected) {
      emit(TestError('Not connected to PLC'));
      return;
    }

    await _readAllValuesOptimized(textFields);
  }

  /// Update reading interval
  void updateReadingInterval(Duration interval) {
    if (_readTimer?.isActive == true) {
      _readTimer?.cancel();
      _readTimer = Timer.periodic(interval, (timer) {
        if (!_shouldKeepReading || !isConnected || _isCurrentlyReading) {
          if (!_shouldKeepReading || !isConnected) {
            timer.cancel();
          }
          return;
        }
        
        _readAllValuesOptimized(_getCurrentTextFields());
      });
    }
  }

  /// Helper to get current text fields (you'll need to implement this)
  List<TextFieldModel> _getCurrentTextFields() {
    // Return your current text fields list
    // This is a placeholder - implement based on your architecture
    return [];
  }
}