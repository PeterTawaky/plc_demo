import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plc_demo/clean_code_practice/text_field_model.dart';
import 'package:plc_demo/cubit/test_cubit.dart';
import 'package:plc_demo/widgets/components/custom_text_field.dart';

class CustomVerticalList extends StatelessWidget {
  final List<TextFieldModel> textFields;
  const CustomVerticalList({super.key, required this.textFields});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TestCubit>();

    return Wrap(
      direction: Axis.horizontal,
      spacing: 10,
      runSpacing: 10,
      children: List.generate(cubit.controllers.length, (index) {
        return SizedBox(
          width: 100,
          child: CoolTextField(
            type: textFields[index].type,
            controller: cubit.controllers[index],
            focusNode: textFields[index].focusNode,
            address: textFields[index].address,
          ),
        );
      }),
    );
    // return ListView.builder(
    //   itemCount: cubit.controllers.length,
    //   itemBuilder: (context, index) => CoolTextField(
    //     type: textFields[index].type,
    //     controller: cubit.controllers[index],
    //     focusNode: textFields[index].focusNode,
    //     address: textFields[index].address,
    //   ),
    // );
  }
}
