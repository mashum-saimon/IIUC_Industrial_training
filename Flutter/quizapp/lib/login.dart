import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'admin.dart';
import 'student.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isRegistering = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessage('Enter username and password');
      return;
    }

    setState(() => isLoading = true);
    final user = await DBHelper.login(username, password);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (user == null) {
      showMessage('Login failed');
      return;
    }

    if (user['role'] == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentPage(username: user['username'].toString()),
        ),
      );
    }
  }

  Future<void> registerStudent() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessage('Enter username and password');
      return;
    }

    setState(() => isRegistering = true);
    final created = await DBHelper.addStudent(username, password);

    if (!mounted) return;
    setState(() => isRegistering = false);

    showMessage(
      created ? 'Student account created. Now login.' : 'Username already used',
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
      appBar: AppBar(title: const Text('Quiz App')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.quiz,
                  color: Theme.of(context).colorScheme.primary,
                  size: 72,
                ),
                const SizedBox(height: 12),
                Text(
                  'Login to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: isLoading ? null : login,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: const Text('Login'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isRegistering ? null : registerStudent,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create Student Account'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Default admin: admin / admin',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
