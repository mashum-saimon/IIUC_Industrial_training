import 'dart:io';

// Abstraction
abstract class Bank {
  void deposit(double amount);
  void withdraw(double amount);
  void displayInfo();
}

// Inheritance
class BankAccount extends Bank {
  String accountHolder;
  int accountNumber;

  // Encapsulation
  double _balance;

  // Constructor
  BankAccount(this.accountHolder, this.accountNumber, this._balance);

  // Polymorphism
  @override
  void deposit(double amount) {
    _balance += amount;
    print("Deposited: \$amount");
  }

  // Polymorphism
  @override
  void withdraw(double amount) {
    if (amount > _balance) {
      print("Insufficient Balance");
    } else {
      _balance -= amount;
      print("Withdrawn: \$amount");
    }
  }

  // Polymorphism
  @override
  void displayInfo() {
    print("\n=== Account Information ===");
    print("Account Holder: $accountHolder");
    print("Account Number: $accountNumber");
    print("Current Balance: \$$_balance");
  }
}

void main() {
  BankAccount user1 =
      BankAccount("Mashum Abdullah", 1001, 5000);

  user1.displayInfo();

  stdout.write("\nEnter deposit amount: ");
  double depositAmount =
      double.parse(stdin.readLineSync()!);

  user1.deposit(depositAmount);

  stdout.write("\nEnter withdraw amount: ");
  double withdrawAmount =
      double.parse(stdin.readLineSync()!);

  user1.withdraw(withdrawAmount);

  user1.displayInfo();
}