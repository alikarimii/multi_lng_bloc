import 'package:flutter/material.dart';

class PersianText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const PersianText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign ?? TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
