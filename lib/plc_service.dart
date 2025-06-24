// // lib/plc_service.dart
// library plc_service;

// import 'package:dart_snap7/dart_snap7.dart';
// import 'dart:typed_data';

// /// Supported Siemens tag types.
// enum TagType { bool, int, dint, real }

// /// Helper that turns the “DB1.DBX0.1” style address into (dbNumber, byteOffset, bitOffset, …).
// class S7Address {
//   final int db;
//   final int byteOffset;
//   final int bitOffset;   // 0-7; −1 when not a bit address
//   final bool isBit;

//   const S7Address({required this.db, required this.byteOffset, required this.bitOffset, required this.isBit});

//   factory S7Address.parse(String raw) {
//     final addr = raw.toLowerCase();
//     if (!addr.startsWith('db')) {
//       throw ArgumentError('Address must start with DBx…');
//     }
//     final dbMatch = RegExp(r'db(\d+)\.').firstMatch(addr);
//     if (dbMatch == null) throw ArgumentError('Couldn’t find DB number');
//     final dbNumber = int.parse(dbMatch.group(1)!);
//     final rest = addr.substring(dbMatch.end);

//     if (rest.startsWith('dbx')) {
//       final m = RegExp(r'dbx(\d+)\.(\d+)').firstMatch(rest);
//       if (m == null) throw ArgumentError('Use DBX<byte>.<bit> for bools');
//       return S7Address(db: dbNumber, byteOffset: int.parse(m.group(1)!), bitOffset: int.parse(m.group(2)!), isBit: true);
//     } else if (rest.startsWith('dbw')) {
//       return S7Address(db: dbNumber, byteOffset: int.parse(rest.substring(3)), bitOffset: -1, isBit: false);
//     } else if (rest.startsWith('dbd')) {
//       return S7Address(db: dbNumber, byteOffset: int.parse(rest.substring(3)), bitOffset: -1, isBit: false);
//     }
//     throw ArgumentError('Address must contain DBX / DBW / DBD');
//   }
// }

// /// Stateless helper for Snap7 client, now including connect/disconnect.
// class PLCService {
//   final Client _client;
//   PLCService() : _client = Client();

//   /// Connect to PLC. Returns true on success.
//   Future<bool> connect(String ip, int rack, int slot) async {
//     final result = _client.connect(ip, rack, slot);
//     return _client.isConnected();
//   }

//   /// Disconnect from PLC.
//   void disconnect() {
//     if (_client.isConnected()) {
//       _client.disconnect();
//     }
//   }

//   bool get isConnected => _client.isConnected();

//   // /* ─────────────── READ ─────────────── */
//   dynamic read(TagType type, String address) {
//     final a = S7Address.parse(address);
//     if (type == TagType.bool && !a.isBit) {
//       throw ArgumentError('Bool tag requires DBX address');
//     }
//     if (type != TagType.bool && a.isBit) {
//       throw ArgumentError('Only bool tags may use DBX.bit');
//     }
//     if (!_client.isConnected()) {
//       throw S7Error(-1, 'Client not connected');
//     }
//     final data = _client.readDataBlock(a.db, a.byteOffset, _lengthFor(type));
//     return _parse(type, data, a.bitOffset);
//   }

//   /* ─────────────── WRITE ─────────────── */
//   void write(TagType type, String address, dynamic value) {
//     final a = S7Address.parse(address);
//     if (type == TagType.bool && !a.isBit) {
//       throw ArgumentError('Bool tag requires DBX address');
//     }
//     if (type != TagType.bool && a.isBit) {
//       throw ArgumentError('Only bool tags may use DBX.bit');
//     }
//     if (!_client.isConnected()) {
//       throw S7Error(-1, 'Client not connected');
//     }
//     final bytes = _bytesFor(type, value);
//     if (type == TagType.bool) {
//       _client.writeDataBlockBit(a.db, a.byteOffset, a.bitOffset, value as bool);
//     } else {
//       _client.writeDataBlock(a.db, a.byteOffset, bytes);
//     }
//   }

//   int _lengthFor(TagType type) {
//     switch (type) {
//       case TagType.bool:
//         return 1;
//       case TagType.int:
//         return 2;
//       case TagType.dint:
//       case TagType.real:
//         return 4;
//     }
//   }

//   dynamic _parse(TagType type, List<int> d, int bitOffset) {
//     switch (type) {
//       case TagType.bool:
//         return (d[0] & (1 << bitOffset)) != 0;
//       case TagType.int:
//         final v = (d[0] << 8) | d[1];
//         return v > 0x7FFF ? v - 0x10000 : v;
//       case TagType.dint:
//         final v = (d[0] << 24) | (d[1] << 16) | (d[2] << 8) | d[3];
//         return v > 0x7FFFFFFF ? v - 0x100000000 : v;
//       case TagType.real:
//         final b = ByteData(4)
//           ..setUint8(0, d[0])
//           ..setUint8(1, d[1])
//           ..setUint8(2, d[2])
//           ..setUint8(3, d[3]);
//         return b.getFloat32(0, Endian.big);
//     }
//   }

//   Uint8List _bytesFor(TagType type, dynamic value) {
//     switch (type) {
//       case TagType.int:
//         final v = value as int;
//         final u = v < 0 ? v + 0x10000 : v;
//         return Uint8List.fromList([(u >> 8) & 0xFF, u & 0xFF]);
//       case TagType.dint:
//         final v = value as int;
//         final u = v < 0 ? v + 0x100000000 : v;
//         return Uint8List.fromList([ (u >> 24) & 0xFF, (u >> 16) & 0xFF, (u >> 8) & 0xFF, u & 0xFF ]);
//       case TagType.real:
//         final dVal = (value is int) ? (value as int).toDouble() : value as double;
//         final b = ByteData(4)..setFloat32(0, dVal, Endian.big);
//         return Uint8List.fromList([b.getUint8(0), b.getUint8(1), b.getUint8(2), b.getUint8(3)]);
//       default:
//         return Uint8List(0);
//     }
//   }
// }
