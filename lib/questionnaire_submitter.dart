import 'package:uuid/uuid.dart';
import 'package:voxcat/geolocator.dart';
import 'package:voxcat/submitted_questionnaire.dart';
import 'package:voxcat/submitted_questionnaires_file_manager.dart';
import 'package:voxcat/question_answer_pair.dart';

class QuestionnaireSubmitter {
  final _fileManager = SubmittedQuestionnairesFileManager();

  void submit(List<QuestionAnswerPair> pairs) async {
    _fileManager.init(); // ensure directories are created
    pairs.forEach((element) {
      print(element);
    });
    GeoLocator geoLocator = GeoLocator();
    final position = await geoLocator.determinePosition();
    print('${position.latitude}, ${position.longitude}');
    final questionnaire = SubmittedQuestionnaire(
        altitude: position.altitude,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now().toUtc(),
        questionAnswerPairs: pairs);
    Uuid uuid = Uuid();
    final fileName = uuid.v4();
    _fileManager.create(questionnaire, fileName);
  }
}
