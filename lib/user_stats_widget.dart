import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voxcat/submitted_questionnaires_file_manager.dart';

class UserStats {
  int numQuestionnairesToSend = 0;
  int numQuestionnairesSent = 0;
  int numDigestsSent = 0;
}

class UserStatsWidget extends StatelessWidget {
  final UserStats stats = UserStats();
  final SubmittedQuestionnairesFileManager _fileManager =
      SubmittedQuestionnairesFileManager();

  @override
  Widget build(context) {
    return FutureBuilder<UserStats>(
        future: getUpdatedStats(),
        builder: (context, AsyncSnapshot<UserStats> snapshot) {
          if (snapshot.hasData) {
            return Column(children: [
              ListTile(
                title: Text("Questionnaires unsent"),
                subtitle:
                    Text(snapshot.data!.numQuestionnairesToSend.toString()),
              ),
              ListTile(
                title: Text("Questionnaires sent"),
                subtitle: Text(snapshot.data!.numQuestionnairesSent.toString()),
              ),
              ListTile(
                title: Text("Digests sent"),
                subtitle: Text(snapshot.data!.numDigestsSent.toString()),
              )
            ]);
            // return Text(snapshot.data);
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Future<UserStats> getUpdatedStats() async {
    final outboxNum = getNumFilesInDir(QuestionnaireDirectory.outbox);
    final sentNum = getNumFilesInDir(QuestionnaireDirectory.sent);
    final digestsNum = getNumFilesInDir(QuestionnaireDirectory.reports);
    final stats = UserStats();
    stats.numQuestionnairesSent = await sentNum;
    stats.numQuestionnairesToSend = await outboxNum;
    stats.numDigestsSent = await digestsNum;
    return stats;
  }

  Future<int> getNumFilesInDir(QuestionnaireDirectory directory) {
    return _fileManager
        .mapDirectoryToPath(directory)
        .then((dirPath) => _fileManager.getNumFilesInDirectory(dirPath));
  }
}
