import 'package:excel/excel.dart';

class TagModel {
  final String tagName;
  final String type;
  final String address;
  final String access;
  final int acquistion;
  final bool value;
  final String description;

  TagModel({
    required this.tagName,
    required this.type,
    required this.address,
    required this.access,
    required this.acquistion,
    required this.value,
    required this.description,
  });

  factory TagModel.fromList(List<Data?> data) {
    return TagModel(
      tagName: data[0]?.value.toString() ?? '',
      type: data[1]?.value.toString() ?? '',
      address: data[2]?.value.toString() ?? '',
      access: data[3]?.value.toString() ?? '',
      acquistion: _parseInt(data[4]?.value.toString() ?? ''),
      value: _parseBool(data[5]?.value.toString() ?? ''),
      description: data[6]?.value.toString() ?? '',
    );
  }
  // helper method to convert string
  static bool _parseBool(String value) {
    if (value == '1') {
      return true;
    } else {
      return false;
    }
  }

  static int _parseInt(acquistion) {
    //split number from the unit
    RegExp regex = RegExp(r'^(\d+)([a-zA-Z]+)$');
    Match? match = regex.firstMatch(acquistion);
    String number = '';
    if (match != null) {
      number = match.group(1)!; // "100"
      String unit = match.group(2)!; // "ms"
    }
    return int.parse(number);
  }
}
