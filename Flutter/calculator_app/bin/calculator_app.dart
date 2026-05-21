/*import 'package:calculator_app/calculator_app.dart' as calculator_app;

void main(List<String> arguments) {
  print('Hello world: ${calculator_app.calculate()}!');
}
*/
import 'dart:io';

void main() {
  print("=== Simple Calculator ===");

  stdout.write("Enter first number: ");
  double num1 = double.parse(stdin.readLineSync()!);

  stdout.write("Enter operator (+, -, *, /): ");
  String op = stdin.readLineSync()!;

  stdout.write("Enter second number: ");
  double num2 = double.parse(stdin.readLineSync()!);

  double result;

  switch (op) {
    case '+':
      result = num1 + num2;
      break;

    case '-':
      result = num1 - num2;
      break;

    case '*':
      result = num1 * num2;
      break;

    case '/':
      if (num2 == 0) {
        print("Cannot divide by zero");
        return;
      }
      result = num1 / num2;
      break;

    default:
      print("Invalid Operator");
      return;
  }

  print("Result = $result");
}