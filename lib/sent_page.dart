import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:voxcat/submitted_questionnaires_file_manager.dart';
import 'package:voxcat/user_stats_widget.dart';

class SentPage extends StatefulWidget {
  SentPage({Key? key}) : super(key: key);

  @override
  _SentPageState createState() => _SentPageState();
}

class _SentPageState extends State<SentPage> {
  final _fileManager = SubmittedQuestionnairesFileManager();
  void _submit() async {
    await _fileManager.init(); // ensure directories are created
    final qs = await _fileManager.buildOutboxQuestionnaireList();
    if (qs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Nothing to send')));
      return;
    }
    final reportFile = _fileManager.createReport(qs);
    final body = 'Questionnaire digest attached.';
    final MailOptions mailOptions = MailOptions(
      body: body,
      subject: 'VoxFox Collected Questionnaires',
      recipients: [],
      isHTML: false,
      attachments: [(await reportFile).path],
    );
    final MailerResponse response = await FlutterMailer.send(mailOptions);
    handleMailerResponse(response);
    setState(() {
      // empty to trigger redraw with updated stats
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      UserStatsWidget(),
      new Expanded(
          child: new Align(
              alignment: Alignment.bottomCenter,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(onPressed: _submit, child: Text('Send'))
                ],
              )))
    ]);
  }

  String handleMailerResponse(MailerResponse response) {
    String platformResponse;
    switch (response) {
      case MailerResponse.saved:

        /// ios only
        platformResponse = 'mail was saved to draft';
        break;
      case MailerResponse.sent:

        /// ios only
        platformResponse = 'mail was sent';
        _fileManager.moveOutboxQuestionnaires();
        break;
      case MailerResponse.cancelled:

        /// ios only
        platformResponse = 'mail was cancelled';
        break;
      case MailerResponse.android:
        platformResponse = 'intent was successful';
        _fileManager.moveOutboxQuestionnaires();
        break;
      default:
        platformResponse = 'unknown';
        break;
    }
    print('platformResponse $platformResponse');
    return platformResponse;
  }
}
