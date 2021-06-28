import 'package:uuid/uuid.dart';
import 'package:voxcat/geolocator.dart';
import 'package:voxcat/submitted_questionnaire.dart';
import 'package:voxcat/submitted_questionnaires_file_manager.dart';
import 'package:voxcat/question_answer_pair.dart';

class QuestionnaireSubmitter {
  final _fileManager = SubmittedQuestionnairesFileManager();
  GeoLocator geoLocator = GeoLocator();

  void submit(List<QuestionAnswerPair> pairs) async {
    _fileManager.init(); // ensure directories are created
    geoLocator.determinePosition(attempts: 2).then((position) {
      if (position == null) {
        print('Failed to get position');
        return;
      }
      Uuid uuid = Uuid();
      final fileName = uuid.v4();
      print(
          '${uuid.v4()} latitude:${position.latitude}, longitude:${position.longitude}');
      final questionnaire = SubmittedQuestionnaire(
          altitude: position.altitude,
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now().toUtc(),
          questionAnswerPairs: pairs);
      _fileManager.create(questionnaire, fileName);
    }).catchError((error) {
      print(error.error);
    });
  }

  void _handleError() {}
}
