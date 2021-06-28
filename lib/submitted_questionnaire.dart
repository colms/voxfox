import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid_util.dart';
import 'package:voxcat/question_answer_pair.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

@immutable
class SubmittedQuestionnaire {
  late final double altitude;
  late final double latitude;
  late final double longitude;
  late final DateTime timestamp; // UTC
  late final List<QuestionAnswerPair> questionAnswerPairs;
  late final String id;

  SubmittedQuestionnaire(
      {required this.altitude,
      required this.latitude,
      required this.longitude,
      required this.timestamp,
      required this.questionAnswerPairs}) {
    id = Uuid().v4();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'altitude': altitude,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'questionnaire': questionAnswerPairs
    };
  }

  SubmittedQuestionnaire.fromJson(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    List<dynamic> qas = jsonMap['questionnaire'];
    this.id = jsonMap['id'];
    this.altitude = jsonMap['altitude'];
    this.latitude = jsonMap['latitude'];
    this.longitude = jsonMap['longitude'];
    this.timestamp = DateTime.parse(jsonMap['timestamp']);
    this.questionAnswerPairs = qas
        .map((entry) => QuestionAnswerPair(entry['question'], entry['answer']))
        .toList();
  }
}
