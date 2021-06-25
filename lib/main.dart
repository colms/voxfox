import 'package:flutter/material.dart';
import 'package:voxcat/question_answer_pair.dart';
import 'package:voxcat/questionnaire_submitter.dart';
import 'package:voxcat/sent_page.dart';
import 'package:voxcat/submitted_questionnaires_file_manager.dart';
import 'package:voxcat/text_field.dart';
import 'package:voxcat/radio_buttons.dart';
import 'package:voxcat/vox_question_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: MaterialApp(
          title: 'Questionnaire',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(title: 'Voter Questions'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double _margins = 16.0;
  double _spaceBetweenQuestions = 32.0;
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  var _radioButtons = VoxRadioButtons(
      question: 'Expected vote',
      answers: [
        'Number 1',
        'Possible vote or transfer',
        'Unlikely to vote for candidate',
        'No indication / undecided',
        'Not home'
      ],
      required: true,
      resetAfterSubmit: true);
  var _textField = VoxTextField(
      question: 'Address', required: true, resetAfterSubmit: false);
  var _textField2 = VoxTextField(
      question: 'Comments', required: false, resetAfterSubmit: true);
  List<VoxQuestionWidget> get questionWidgets =>
      [_textField, _radioButtons, _textField2];

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(milliseconds: 500), curve: Curves.linear);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (!_radioButtons.isValid) {
        _radioButtons.errorMessage = 'Required field.';
        return;
      } else {
        _radioButtons.errorMessage = '';
      }
      if (!_formKey.currentState!.validate()) {
        return;
      }
      List<QuestionAnswerPair> qas = questionWidgets
          .map((e) => QuestionAnswerPair(e.question, e.answer))
          .toList();
      QuestionnaireSubmitter submitter = QuestionnaireSubmitter();
      submitter.submit(qas);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Successfully submitted: ${_textField.answer} ${_radioButtons.answer} ${_textField2.answer}')));
      questionWidgets.forEach((widget) {
        if (widget.shouldResetAfterSubmit) {
          widget.reset();
        }
      });
      _scrollToTop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            onTap: (index) {
              FocusScope.of(context).unfocus();
            },
            tabs: [
              Tab(text: 'COLLECT'),
              Tab(text: 'SEND'),
            ],
          ),
          title: Text('Voter Questionnaire'),
        ),
        body: TabBarView(children: [buildQuestionnaireWidget(), SentPage()]));
  }

  Widget buildQuestionnaireWidget() {
    return SingleChildScrollView(
        controller: _scrollController,
        physics: ClampingScrollPhysics(),
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Center(
                  child: Container(
                height: MediaQuery.of(context).size.height,
                margin: EdgeInsets.all(_margins),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Wrap(
                        children: questionWidgets,
                        runSpacing: _spaceBetweenQuestions,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: _submit, child: Text('Submit'))
                        ])
                  ],
                ),
              )),
            )));
  }
}
