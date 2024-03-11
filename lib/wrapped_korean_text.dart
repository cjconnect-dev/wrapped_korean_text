library wrapped_korean_text;

import 'package:flutter/material.dart';

class WrappedKoreanText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final WrapAlignment wrapAlignment;
  final int maxLines;

  WrappedKoreanText(
    this.text, {
    this.style,
    this.textAlign = TextAlign.left,
    this.wrapAlignment = WrapAlignment.start,
    this.maxLines = 100,
  });

  @override
  State<StatefulWidget> createState() {
    return _WrappedKoreanTextState();
  }
}

class _WrappedKoreanTextState extends State<WrappedKoreanText> {
  /// Special characters to look for, that break original text into paragraphs
  final List _specialCharacters = [
    r'\u000A',
    r'\u000C',
    r'\u000D',
    r'\u0085',
    r'\u2028',
    r'\u2029',
    // r'\n'
  ];

  /// Indexes of special characters in original text
  List<Map<int, dynamic>> _specialCharacterIndexes = [];

  List<List<String>> _prevParagraphsList = [];
  List<List<String>> _paragraphsList = [];
  int _startIndex = 0;

  @override
  void initState() {
    initalizeValues();
    parceText();
    addParagraphs();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant WrappedKoreanText oldWidget) {
    if (oldWidget.text != widget.text) {
      initalizeValues();
      parceText();
      addParagraphs();
      if (_prevParagraphsList != _paragraphsList) {
        setState(() {});
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void initalizeValues() {
    _prevParagraphsList = _paragraphsList;

    _specialCharacterIndexes.clear();
    _paragraphsList.clear();
    _startIndex = 0;
  }

  void parceText() {
    for (var i = 0; i < widget.text.length; i++) {
      for (var ii = 0; ii < _specialCharacters.length; ii++) {
        if (RegExp(_specialCharacters[ii]).hasMatch(widget.text[i])) {
          _specialCharacterIndexes.add({i: _specialCharacters[ii]});
        }
      }
    }

    _specialCharacterIndexes.add({widget.text.length: ''});
  }

  /// Break text into paragraphs, keep line breaks in origianl places and
  /// remove excessive whitespaces
  void addParagraphs() {
    _startIndex = 0;
    for (final index in _specialCharacterIndexes) {
      String tempString = widget.text.substring(_startIndex, index.keys.single).trim();

      if (RegExp(r'\S+').hasMatch(tempString)) {
        List<String> tempList = tempString.replaceAll(RegExp(r'\s+'), ' ').split(' ');
        _paragraphsList.add(tempList.map((e) => '$e ').toList());

        if (index.values.single.isNotEmpty) {
          _paragraphsList.add(['']);
        }
      }

      _startIndex = index.keys.single;
    }
  }

  Widget paragraph(List<String> list) {
    return Wrap(
      alignment: switch (widget.textAlign) {
        TextAlign.start => WrapAlignment.start,
        TextAlign.center => WrapAlignment.center,
        TextAlign.end || TextAlign.right => WrapAlignment.end,
        _ => WrapAlignment.start,
      },
      children: list
          .map(
            (str) => Text(
              str,
              overflow: TextOverflow.ellipsis,
              style: widget.style,
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
            ),
          )
          .toList(),
    );
  }

  Widget wrappedText() {
    return Column(
      crossAxisAlignment: switch (widget.textAlign) {
        TextAlign.start => CrossAxisAlignment.start,
        TextAlign.center => CrossAxisAlignment.center,
        TextAlign.end || TextAlign.right => CrossAxisAlignment.end,
        _ => CrossAxisAlignment.start,
      },
      children: _paragraphsList.map(paragraph).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return wrappedText();
  }
}
