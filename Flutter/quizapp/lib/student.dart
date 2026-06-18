import 'dart:async';
import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'login.dart';

class StudentPage extends StatefulWidget {
  final String username;

  const StudentPage({super.key, required this.username});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  List<Map<String, Object?>> questions = [];
  List<Map<String, Object?>> results = [];
  int index = 0;
  int score = 0;

  int time = 10;
  Timer? timer;

  String? selected;
  bool resultSaved = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadQuestions() async {
    final loadedQuestions = await DBHelper.getQuestions();
    final loadedResults = await DBHelper.getResults(widget.username);

    if (!mounted) return;
    setState(() {
      questions = loadedQuestions;
      results = loadedResults;
      index = 0;
      score = 0;
      selected = null;
      resultSaved = false;
    });

    if (loadedQuestions.isNotEmpty) {
      startTimer();
    }
  }

  void startTimer() {
    timer?.cancel();

    time = 10;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (time == 0) {
        nextQuestion();
      } else {
        setState(() {
          time--;
        });
      }
    });
  }

  void checkAnswer(String value) {
    setState(() => selected = value);
  }

  void logout() {
    timer?.cancel();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void nextQuestion() {
    if (selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select an answer first')));
      return;
    }

    if (selected == questions[index]['answer']) {
      score++;
    }

    if (index < questions.length - 1) {
      setState(() {
        index++;
        selected = null;
      });
      startTimer();
    } else {
      timer?.cancel();
      showResult();
    }
  }

  Future<void> showResult() async {
    if (!resultSaved) {
      resultSaved = true;
      await DBHelper.saveResult(widget.username, score, questions.length);
      results = await DBHelper.getResults(widget.username);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Exam Finished'),
        content: Text('Score: $score / ${questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              loadQuestions();
            },
            child: const Text('Restart'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Panel')),
        body: const Center(child: Text('No questions found')),
      );
    }

    var q = questions[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Exam - ${widget.username}'),
        actions: [
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${index + 1} of ${questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  avatar: const Icon(Icons.timer, size: 18),
                  label: Text('$time sec'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              q['question'].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RadioGroup<String>(
              groupValue: selected,
              onChanged: (value) {
                if (value != null) checkAnswer(value);
              },
              child: Column(
                children: [
                  option(q['a'].toString()),
                  option(q['b'].toString()),
                  option(q['c'].toString()),
                  option(q['d'].toString()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: nextQuestion,
              icon: Icon(
                index == questions.length - 1
                    ? Icons.check_circle
                    : Icons.arrow_forward,
              ),
              label: Text(index == questions.length - 1 ? 'Finish' : 'Next'),
            ),
            const Divider(height: 32),
            Text(
              'My Previous Results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (results.isEmpty)
              const Text('No previous results yet.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final result = results[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history),
                      title: Text(
                        'Score: ${result['score']} / ${result['total']}',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget option(String text) {
    return Card(
      child: RadioListTile<String>(value: text, title: Text(text)),
    );
  }
}
