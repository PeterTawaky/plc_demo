import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plc_demo/cubit/test_cubit.dart';
import 'package:plc_demo/service/app_enums.dart';

class CoolTextField extends StatefulWidget {
  final String address;
  // final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TagType type;

  const CoolTextField({
    super.key,
    // required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.address,
    required this.type,
  });

  @override
  State<CoolTextField> createState() => _CoolTextFieldState();
}

class _CoolTextFieldState extends State<CoolTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (_isFocused)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: TextField(
          onSubmitted: (val) {
            BlocProvider.of<TestCubit>(context).writeData(
              controller: widget.controller,
              address: widget.address,
              type: widget.type,
              value: val,
            );
          },
          focusNode: widget.focusNode,
          controller: widget.controller,
          decoration: InputDecoration(
            // hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w300,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            suffixIcon: _isFocused
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
