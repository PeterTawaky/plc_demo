import 'package:plc_demo/service/app_enums.dart';
import 'dart:typed_data';

class AppHelpers {
  static int lengthFor(TagType type) {
    switch (type) {
      case TagType.bool:
        return 1;
      case TagType.int:
        return 2;
      case TagType.dint:
      case TagType.real:
        return 4;
    }
  }

  static dynamic parse(TagType type, List<int> d, int bitOffset) {
    switch (type) {
      case TagType.bool:
        return (d[0] & (1 << bitOffset)) != 0;
      case TagType.int:
        final v = (d[0] << 8) | d[1];
        return v > 0x7FFF ? v - 0x10000 : v;
      case TagType.dint:
        final v = (d[0] << 24) | (d[1] << 16) | (d[2] << 8) | d[3];
        return v > 0x7FFFFFFF ? v - 0x100000000 : v;
      case TagType.real:
        final b = ByteData(4)
          ..setUint8(0, d[0])
          ..setUint8(1, d[1])
          ..setUint8(2, d[2])
          ..setUint8(3, d[3]);
        return b.getFloat32(0, Endian.big);
    }
  }

  static Uint8List bytesFor(TagType type, dynamic value) {
    switch (type) {
      case TagType.int:
        final v = value as int;
        final u = v < 0 ? v + 0x10000 : v;
        return Uint8List.fromList([(u >> 8) & 0xFF, u & 0xFF]);
      case TagType.dint:
        final v = value as int;
        final u = v < 0 ? v + 0x100000000 : v;
        return Uint8List.fromList([
          (u >> 24) & 0xFF,
          (u >> 16) & 0xFF,
          (u >> 8) & 0xFF,
          u & 0xFF,
        ]);
      case TagType.real:
        final dVal = (value is int) ? (value).toDouble() : value as double;
        final b = ByteData(4)..setFloat32(0, dVal, Endian.big);
        return Uint8List.fromList([
          b.getUint8(0),
          b.getUint8(1),
          b.getUint8(2),
          b.getUint8(3),
        ]);
      default:
        return Uint8List(0);
    }
  }
}
