import 'package:flutter/cupertino.dart';

abstract class VoxQuestionWidget extends StatefulWidget {
  String get question;
  String get answer;
  bool get isValid;
  bool get shouldResetAfterSubmit;
  void reset();

  VoxQuestionWidget({Key? key}) : super(key: key);
}
