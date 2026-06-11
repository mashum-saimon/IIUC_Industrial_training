import 'dart:async';
import 'package:flutter/material.dart';
import 'result_page.dart';
import 'question_model.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  int score = 0;
  int timeLeft = 20;
  Timer? timer;

  List<Question> questions = [
    Question(
      question: "What is Flutter?",
      options: ["SDK", "OS", "Game", "Browser"],
      answer: "SDK",
    ),
    Question(
      question: "Dart is used for?",
      options: ["Frontend", "Backend", "Both", "None"],
      answer: "Both",
    ),
    Question(
      question: "Who created Flutter?",
      options: ["Apple", "Google", "Facebook", "Microsoft"],
      answer: "Google",
    ),
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          nextQuestion();
        }
      });
    });
  }

  void checkAnswer(String selected) {
    if (selected == questions[currentIndex].answer) {
      score++;
    }
    nextQuestion();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        timeLeft = 20;
      });
    } else {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(score: score),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Question q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
        actions: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Center(child: Text("⏱ $timeLeft")),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              q.question,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...q.options.map((opt) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(opt),
                  child: Text(opt),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }
}