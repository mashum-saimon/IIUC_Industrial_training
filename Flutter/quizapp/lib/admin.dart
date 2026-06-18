import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'login.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  String? selectedAnswer;
  List<Map<String, Object?>> questions = [];
  List<Map<String, Object?>> results = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    questionController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final loadedQuestions = await DBHelper.getQuestions();
    final loadedResults = await DBHelper.getAllResults();

    if (!mounted) return;
    setState(() {
      questions = loadedQuestions;
      results = loadedResults;
    });
  }

  Future<void> addQuestion() async {
    final question = questionController.text.trim();
    final a = optionAController.text.trim();
    final b = optionBController.text.trim();
    final c = optionCController.text.trim();
    final d = optionDController.text.trim();

    if ([question, a, b, c, d].any((value) => value.isEmpty) ||
        selectedAnswer == null) {
      showMessage('Fill all fields and choose the correct answer');
      return;
    }

    final answers = {'A': a, 'B': b, 'C': c, 'D': d};

    await DBHelper.addQuestion({
      'question': question,
      'a': a,
      'b': b,
      'c': c,
      'd': d,
      'answer': answers[selectedAnswer],
    });

    questionController.clear();
    optionAController.clear();
    optionBController.clear();
    optionCController.clear();
    optionDController.clear();
    setState(() => selectedAnswer = null);

    await loadData();
    showMessage('Question added');
  }

  Future<void> deleteQuestion(int id) async {
    await DBHelper.deleteQuestion(id);
    await loadData();
    showMessage('Question deleted');
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            onPressed: logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Question', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: questionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 12),
            optionField('A', optionAController),
            optionField('B', optionBController),
            optionField('C', optionCController),
            optionField('D', optionDController),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedAnswer,
              decoration: const InputDecoration(labelText: 'Correct Answer'),
              items: const [
                DropdownMenuItem(value: 'A', child: Text('Option A')),
                DropdownMenuItem(value: 'B', child: Text('Option B')),
                DropdownMenuItem(value: 'C', child: Text('Option C')),
                DropdownMenuItem(value: 'D', child: Text('Option D')),
              ],
              onChanged: (value) => setState(() => selectedAnswer = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
            const Divider(height: 36),
            Text(
              'Questions (${questions.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (questions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No questions added yet.'),
              )
            else
              ...questions.map(
                (question) => Card(
                  child: ListTile(
                    title: Text(question['question'].toString()),
                    subtitle: Text('Answer: ${question['answer']}'),
                    trailing: IconButton(
                      onPressed: () => deleteQuestion(question['id'] as int),
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                ),
              ),
            const Divider(height: 36),
            Text(
              'Student Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No results submitted yet.'),
              )
            else
              ...results.map(
                (result) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.assessment),
                    title: Text(result['username'].toString()),
                    subtitle: Text(
                      'Score: ${result['score']} / ${result['total']}',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget optionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: 'Option $label'),
      ),
    );
  }
}
