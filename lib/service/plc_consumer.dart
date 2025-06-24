// lib/plc_service.dart

import 'package:dart_snap7/dart_snap7.dart';

import 'package:plc_demo/service/app_enums.dart';
import 'package:plc_demo/service/app_helpers.dart';
import 'package:plc_demo/service/s7_address_model.dart';

class PLCService {
  static final Client _client = Client();

  static Future<bool> connect(String ip, int rack, int slot) async {
    final result = _client.connect(ip, rack, slot);
    return _client.isConnected();
  }

  /// Disconnect from PLC.
  static void disconnect() {
    if (_client.isConnected()) {
      _client.disconnect();
    }
  }

  bool get isConnected => _client.isConnected();

  // /* ─────────────── READ ─────────────── */
  static dynamic read(TagType type, String address) {
    final a = S7Address.parse(address);
    if (type == TagType.bool && !a.isBit) {
      throw ArgumentError('Bool tag requires DBX address');
    }
    if (type != TagType.bool && a.isBit) {
      throw ArgumentError('Only bool tags may use DBX.bit');
    }
    if (!_client.isConnected()) {
      throw S7Error(-1, 'Client not connected');
    }
    final data = _client.readDataBlock(
      a.db,
      a.byteOffset,
      AppHelpers.lengthFor(type),
    );
    return AppHelpers.parse(type, data, a.bitOffset);
  }

  /* ─────────────── WRITE ─────────────── */
  static void write(TagType type, String address, dynamic value) {
    final a = S7Address.parse(address);
    if (type == TagType.bool && !a.isBit) {
      throw ArgumentError('Bool tag requires DBX address');
    }
    if (type != TagType.bool && a.isBit) {
      throw ArgumentError('Only bool tags may use DBX.bit');
    }
    if (!_client.isConnected()) {
      throw S7Error(-1, 'Client not connected');
    }
    final bytes = AppHelpers.bytesFor(type, value);
    if (type == TagType.bool) {
      _client.writeDataBlockBit(a.db, a.byteOffset, a.bitOffset, value as bool);
    } else {
      _client.writeDataBlock(a.db, a.byteOffset, bytes);
    }
  }

  // Future<void> disconnectFromPLC() async {
  //   _stopContinuousReading();
  //   plcService.disconnect();
  //   setState(() => isConnected = false);
  //   showSuccess('Disconnected');
  // }
}
