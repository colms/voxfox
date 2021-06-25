import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:voxcat/submitted_questionnaire.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

enum QuestionnaireDirectory { outbox, sent, reports }

class SubmittedQuestionnairesFileManager {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final allFiles = directory.listSync(recursive: true);
    allFiles.forEach((fileName) {
      print(fileName);
    });

    // final fileNames = Directory('/data/user/0/com.example.voxcat/app_flutter/questionnaires/outbox/').listSync();
    // fileNames.forEach((fileName) {
    //   print(fileName);
    //   fileName.deleteSync();
    // });

    createDir(await _outboxDirPath);
    createDir(await _sentDirPath);
    createDir(await _reportDirPath);
  }

  void createDir(String path) {
    final directory = Directory(path);
    if (directory.existsSync()) {
    } else {
      directory.createSync(recursive: true);
    }
  }

  Future<String> get _appDirPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _questionnairesDirPath async {
    return '${await _appDirPath}/questionnaires';
  }

  Future<String> get _outboxDirPath async {
    return '${await _questionnairesDirPath}/outbox';
  }

  Future<String> get _sentDirPath async {
    return '${await _questionnairesDirPath}/sent';
  }

  Future<String> get _reportDirPath async {
    return '${await _questionnairesDirPath}/report';
  }

  Future<String> create(SubmittedQuestionnaire questionnaire,
      [String fileName = '']) async {
    final outboxPath = await _outboxDirPath;
    if (fileName.isEmpty) {
      Uuid uuid = Uuid();
      fileName = uuid.v4();
    }
    final file = File('$outboxPath/$fileName.json');
    file.writeAsString(jsonEncode(questionnaire));
    return path.absolute('$outboxPath/$fileName.json');
  }

  Future<int> getNumFilesInDirectory(String dirPath) async {
    final files = Directory(dirPath).list();
    return files.length;
  }

  Future<String> mapDirectoryToPath(QuestionnaireDirectory directory) async {
    switch (directory) {
      case QuestionnaireDirectory.sent:
        return (await _sentDirPath);
      case QuestionnaireDirectory.outbox:
        return (await _outboxDirPath);
      case QuestionnaireDirectory.reports:
        return (await _reportDirPath);
      default:
        return '';
    }
  }

  Future<List<SubmittedQuestionnaire>> buildOutboxQuestionnaireList() async {
    final dir = await _outboxDirPath;
    List<FileSystemEntity> files = Directory(dir).listSync();
    List<Future<String>> jsonFutures =
        files.map((e) => File(e.path).readAsString()).toList();
    List<String> jsonFiles = await Future.wait(jsonFutures);
    List<SubmittedQuestionnaire> qs = jsonFiles
        .map((fileJson) => SubmittedQuestionnaire.fromJson(fileJson))
        .toList();
    qs.forEach((q) => print(jsonEncode(q)));
    return qs;
  }

  Future<SubmittedQuestionnaire> readFromOutbox(String fileName) async {
    final outboxDirPath = await _outboxDirPath;
    final file = File('$outboxDirPath/$fileName.json');
    final contents = await file.readAsString();
    return SubmittedQuestionnaire.fromJson(contents);
  }

  Future<File> createReport(List<SubmittedQuestionnaire> questionnaires) async {
    String jsonString = jsonEncode(questionnaires);
    final DateTime now = DateTime.now().toUtc();
    final DateFormat formatter = DateFormat('yyyy-MM-dd-HH-mm-ss');
    final String formatted = formatter.format(now);
    final file = File('${await _reportDirPath}/$formatted.json');
    file.writeAsString(jsonString);
    return file;
  }

  void moveOutboxQuestionnaires() async {
    final files = Directory(await _outboxDirPath).listSync();
    files.forEach((file) {
      String newPath = file.path.replaceFirst('outbox', 'sent');
      file.rename(newPath);
    });
  }
}
