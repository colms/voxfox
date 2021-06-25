import 'package:flutter/material.dart';
import 'package:voxcat/vox_question_widget.dart';

class VoxRadioButtons extends VoxQuestionWidget {
  Function resetFunc = () => {};
  Function answerFunc = () => {};
  Function isValidFunc = () => {};
  Function errorMessageFunc = () => {};
  final List<String> answers;
  final bool resetAfterSubmit;
  final String question;
  final bool required;
  String error = '';
  VoxRadioButtons(
      {Key? key,
      required this.question,
      required this.answers,
      required this.required,
      required this.resetAfterSubmit})
      : super(key: key);

  @override
  _VoxRadioButtonsState createState() => _VoxRadioButtonsState();

  @override
  void reset() => resetFunc();

  @override
  String get answer => answerFunc();

  @override
  bool get isValid => (required) ? isValidFunc() : true;
  set errorMessage(String message) => errorMessageFunc(message);

  @override
  bool get shouldResetAfterSubmit => resetAfterSubmit;
}

class _VoxRadioButtonsState extends State<VoxRadioButtons> {
  int _groupValue = -1;

  void reset() {
    setState(() {
      widget.error = '';
      _groupValue = -1;
    });
  }

  List<Widget> buildHeadedRadioButtons() {
    List<Widget> widgets = [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(widget.question),
      ),
    ];
    widgets.addAll(List<Widget>.generate(
        widget.answers.length,
        (int i) => RadioListTile<int>(
            value: i,
            title: Text(widget.answers[i]),
            groupValue: _groupValue,
            dense: true,
            onChanged: (int? value) {
              FocusScope.of(context).unfocus();
              setState(() {
                _groupValue = (value != null) ? value : -1;
                errorMessage('');
              });
            })));
    widgets.add(Align(
      alignment: Alignment.centerLeft,
      child: Text(widget.error, style: TextStyle(color: Colors.red)),
    ));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    widget.resetFunc = reset;
    widget.answerFunc = answer;
    widget.isValidFunc = isValid;
    widget.errorMessageFunc = errorMessage;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: buildHeadedRadioButtons());
  }

  String answer() => (_groupValue != -1) ? widget.answers[_groupValue] : "";
  bool isValid() => _groupValue != -1;
  void errorMessage(String message) => setState(() {
        widget.error = message;
      });
}
