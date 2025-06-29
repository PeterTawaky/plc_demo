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

  // Add these for better monitoring
  int _consecutiveErrors = 0;
  int _totalReads = 0;
  int _successfulReads = 0;
  DateTime? _lastSuccessfulRead;

  final List<TextEditingController> controllers = List.generate(
    1000,
    (_) => TextEditingController(),
  );

  @override
  Future<void> close() {
    log('Disposing TestCubit resources...');

    // Dispose controllers with error handling
    for (int i = 0; i < controllers.length; i++) {
      try {
        controllers[i].dispose();
      } catch (e) {
        log('Error disposing controller $i: $e');
      }
    }

    _stopContinuousReading();
    return super.close();
  }

  Future<void> connectToPLC({required List<TextFieldModel> textFields}) async {
    emit(TestConnecting());

    try {
      // Add connection retry logic
      final success = await _connectWithRetry();
      isConnected = success;

      if (success) {
        _resetCounters(); // Reset monitoring counters
        _startContinuousReading(textFields: textFields);
        log('Connected to PLC successfully');
        emit(TestConnected());
      } else {
        log('Connection failed with PLC after retries');
        emit(TestConnectionFailed('Failed to connect to PLC after retries'));
      }
    } catch (e) {
      log('Connection error: $e');
      emit(TestConnectionFailed(e.toString()));
    }
  }

  // Add retry logic for better reliability
  Future<bool> _connectWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        log('PLC connection attempt $attempt/$maxRetries');
        final success = await PLCService.connect("192.168.0.1", 0, 1);
        if (success) return true;

        if (attempt < maxRetries) {
          await Future.delayed(
            Duration(seconds: attempt * 2),
          ); // Exponential backoff
        }
      } catch (e) {
        log('Connection attempt $attempt failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
    return false;
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

      _readAllValuesOptimized(textFields);
    });
  }

  /// Enhanced optimized reading with better error handling and monitoring
  Future<void> _readAllValuesOptimized(List<TextFieldModel> textFields) async {
    if (!isConnected || _isCurrentlyReading) return;

    _isCurrentlyReading = true;
    final readStartTime = DateTime.now();

    try {
      const chunkSize = 5; // Your optimal chunk size
      int processedCount = 0;
      int errorCount = 0;

      for (int i = 0; i < textFields.length; i += chunkSize) {
        if (!_shouldKeepReading || !isConnected) break;

        final endIndex = (i + chunkSize < textFields.length)
            ? i + chunkSize
            : textFields.length;

        // Process chunk with individual error handling
        for (int j = i; j < endIndex; j++) {
          try {
            textFields[j].valuesFromPLC = PLCService.read(
              textFields[j].type,
              textFields[j].address,
            );

            if (!textFields[j].focusNode.hasFocus) {
              controllers[j].text = textFields[j].valuesFromPLC.toString();
            }

            processedCount++;
          } catch (e) {
            errorCount++;
            log('Error reading field $j (${textFields[j].address}): $e');
          }
        }

        // Yield control to UI thread after each chunk
        await Future.delayed(Duration.zero);
      }

      // Update monitoring stats
      _totalReads++;
      if (errorCount == 0) {
        _successfulReads++;
        _consecutiveErrors = 0;
        _lastSuccessfulRead = DateTime.now();
      } else {
        _consecutiveErrors++;
      }

      final readDuration = DateTime.now()
          .difference(readStartTime)
          .inMilliseconds;

      if (processedCount > 0) {
        log(
          'Read $processedCount values (${errorCount} errors) in ${readDuration}ms',
        );
        emit(TestDataUpdated());
      }

      // Check for too many consecutive errors
      if (_consecutiveErrors >= 5) {
        log(
          'Too many consecutive errors ($_consecutiveErrors) - may need reconnection',
        );
        emit(TestError('Multiple consecutive read errors detected'));
      }
    } catch (e) {
      _consecutiveErrors++;
      log('Critical read error: $e');
      emit(TestError('Critical read error: $e'));
    } finally {
      _isCurrentlyReading = false;
    }
  }

  /// Your existing batch reading method - enhanced with better monitoring
  Future<void> _readAllValuesBatched(List<TextFieldModel> textFields) async {
    if (!isConnected || _isCurrentlyReading) return;

    _isCurrentlyReading = true;

    try {
      final Stopwatch stopwatch = Stopwatch()..start();

      // Group reads by data block for efficiency
      final Map<String, List<int>> addressGroups = {};

      for (int i = 0; i < textFields.length; i++) {
        final address = textFields[i].address;
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
              controllers[index].text = textFields[index].valuesFromPLC
                  .toString();
            }

            successCount++;
          } catch (e) {
            errorCount++;
            log(
              'Error reading field $index (${textFields[index].address}): $e',
            );
          }
        }

        await Future.delayed(Duration.zero);
      }

      stopwatch.stop();

      // Update monitoring
      _totalReads++;
      if (errorCount == 0) {
        _successfulReads++;
        _consecutiveErrors = 0;
        _lastSuccessfulRead = DateTime.now();
      } else {
        _consecutiveErrors++;
      }

      log(
        'Batch read: $successCount success, $errorCount errors, ${stopwatch.elapsedMilliseconds}ms',
      );

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

      log('Data written successfully to $address');
      emit(TestWriteSuccess());
    } catch (e) {
      log('Write error for $address: $e');
      emit(TestError('Write error: $e'));
    }
  }

  Future<void> performSingleRead({
    required List<TextFieldModel> textFields,
  }) async {
    if (!isConnected) {
      emit(TestError('Not connected to PLC'));
      return;
    }

    await _readAllValuesOptimized(textFields);
  }

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

        // You'll need to pass the actual textFields here
        // _readAllValuesOptimized(_getCurrentTextFields());
      });
    }
  }

  // Add monitoring methods
  void _resetCounters() {
    _consecutiveErrors = 0;
    _totalReads = 0;
    _successfulReads = 0;
    _lastSuccessfulRead = null;
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final successRate = _totalReads > 0
        ? (_successfulReads / _totalReads * 100)
        : 0;

    return {
      'isConnected': isConnected,
      'totalReads': _totalReads,
      'successfulReads': _successfulReads,
      'successRate': successRate.toStringAsFixed(1) + '%',
      'consecutiveErrors': _consecutiveErrors,
      'lastSuccessfulRead': _lastSuccessfulRead?.toIso8601String(),
      'isCurrentlyReading': _isCurrentlyReading,
    };
  }

  /// Log performance summary
  void logPerformanceSummary() {
    final stats = getPerformanceStats();
    log('=== PERFORMANCE SUMMARY ===');
    stats.forEach((key, value) => log('$key: $value'));
  }
}
