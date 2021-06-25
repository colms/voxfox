import 'package:flutter/material.dart';
import 'package:voxcat/vox_question_widget.dart';

class VoxTextField extends VoxQuestionWidget {
  final String question;
  final bool required;
  final bool resetAfterSubmit;
  Function resetFunc = () => {};
  Function answerFunc = () => {};
  VoxTextField(
      {Key? key,
      required this.question,
      required this.required,
      required this.resetAfterSubmit})
      : super(key: key);

  @override
  _VoxTextFieldState createState() => _VoxTextFieldState();

  @override
  void reset() => resetFunc();

  @override
  String get answer => answerFunc();

  @override
  bool get isValid => (required) ? answer.isNotEmpty : true;

  @override
  bool get shouldResetAfterSubmit => resetAfterSubmit;
}

class _VoxTextFieldState extends State<VoxTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextFormField buildField(bool required) {
    var field = TextFormField(
      controller: _controller,
      validator: (String? value) {
        if (required && (value == null || value.isEmpty)) {
          return 'This field cannot be blank';
        }
      },
    );
    return field;
  }

  void reset() => _controller.clear();
  String answer() => _controller.text;

  List<Widget> buildHeadedField(String question, bool required) {
    List<Widget> widgets = [
      Align(
          alignment: Alignment.centerLeft,
          child: Text(
            question,
          )),
      buildField(required)
    ];
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    widget.answerFunc = answer;
    widget.resetFunc = reset;
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: buildHeadedField(widget.question, widget.required));
  }
}
