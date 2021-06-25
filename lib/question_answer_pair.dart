import 'package:flutter/cupertino.dart';

@immutable
class QuestionAnswerPair {
  final String _question;
  final dynamic _answer;

  QuestionAnswerPair(this._question, this._answer);

  Map<String, dynamic> toJson() {
    return {'question': _question, 'answer': _answer};
  }

  String get question => _question;
  String get answer => _answer;
}
