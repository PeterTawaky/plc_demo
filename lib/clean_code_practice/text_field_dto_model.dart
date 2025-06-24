import 'package:plc_demo/service/app_enums.dart';

class TextFieldDTO {
  final String address;
  final TagType type;
  final int index;

  TextFieldDTO({
    required this.address,
    required this.type,
    required this.index,
  });
}
