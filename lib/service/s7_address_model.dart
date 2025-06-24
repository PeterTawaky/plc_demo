class S7Address {
  final int db;
  final int byteOffset;
  final int bitOffset; // 0-7; −1 when not a bit address
  final bool isBit;

  const S7Address({
    required this.db,
    required this.byteOffset,
    required this.bitOffset,
    required this.isBit,
  });

  factory S7Address.parse(String raw) {
    final addr = raw.toLowerCase();
    if (!addr.startsWith('db')) {
      throw ArgumentError('Address must start with DBx…');
    }
    final dbMatch = RegExp(r'db(\d+)\.').firstMatch(addr);
    if (dbMatch == null) throw ArgumentError('Couldn’t find DB number');
    final dbNumber = int.parse(dbMatch.group(1)!);
    final rest = addr.substring(dbMatch.end);

    if (rest.startsWith('dbx')) {
      final m = RegExp(r'dbx(\d+)\.(\d+)').firstMatch(rest);
      if (m == null) throw ArgumentError('Use DBX<byte>.<bit> for bools');
      return S7Address(
        db: dbNumber,
        byteOffset: int.parse(m.group(1)!),
        bitOffset: int.parse(m.group(2)!),
        isBit: true,
      );
    } else if (rest.startsWith('dbw')) {
      return S7Address(
        db: dbNumber,
        byteOffset: int.parse(rest.substring(3)),
        bitOffset: -1,
        isBit: false,
      );
    } else if (rest.startsWith('dbd')) {
      return S7Address(
        db: dbNumber,
        byteOffset: int.parse(rest.substring(3)),
        bitOffset: -1,
        isBit: false,
      );
    }
    throw ArgumentError('Address must contain DBX / DBW / DBD');
  }
}
