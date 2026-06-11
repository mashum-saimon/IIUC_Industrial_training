import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final int score;

  ResultPage({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Center(
        child: Text(
          "Your Score: $score",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}