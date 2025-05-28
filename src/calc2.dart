import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CalculatorData(),
      child: const CalculatorApp(),
    ),
  );
}

class CalculatorData extends ChangeNotifier {
  String _expression = '';
  String _result = '';

  String get expression => _expression;
  String get result => _result;

  void updateExpression(String value) {
    _expression = value;
    notifyListeners();
  }

  void updateResult(String value) {
    _result = value;
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _result = '';
    notifyListeners();
  }

  void calculate() {
    try {
      // Basic parsing and calculation - more robust solution is recommended for production
      final exp = expression.replaceAll('÷', '/').replaceAll('×', '*');
      final resultValue = evalExpression(exp);

      _result = resultValue.toString();
    } catch (e) {
      _result = 'Error';
    }
    notifyListeners();
  }

  double evalExpression(String expression) {
    // Implement your expression evaluation logic here
    // This is a very basic example and may not handle all cases
    try {
      // Attempt to use eval directly for simple expressions
      return eval(expression);
    } catch (e) {
      return double.nan; // Indicate an error
    }
  }

  double eval(String expression) {
    // Simple evaluation of basic arithmetic operations
    // Warning: This is extremely basic and potentially unsafe.
    // In a real calculator, use a proper parsing library for safety and more features.

    final operators = ['+', '-', '*', '/'];
    String currentNumber = '';
    double result = 0.0;
    String currentOperator = '+'; // Start with addition

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];

      if (operators.contains(char)) {
        double number = double.tryParse(currentNumber) ?? 0.0;

        switch (currentOperator) {
          case '+':
            result += number;
            break;
          case '-':
            result -= number;
            break;
          case '*':
            result *= number;
            break;
          case '/':
            if (number != 0.0) {
              result /= number;
            } else {
              return double.nan; // Division by zero
            }
            break;
        }

        currentOperator = char;
        currentNumber = '';
      } else {
        currentNumber += char;
      }
    }

    // Process the last number
    double number = double.tryParse(currentNumber) ?? 0.0;
    switch (currentOperator) {
      case '+':
        result += number;
        break;
      case '-':
        result -= number;
        break;
      case '*':
        result *= number;
        break;
      case '/':
        if (number != 0.0) {
          result /= number;
        } else {
          return double.nan; // Division by zero
        }
        break;
    }

    return result;
  }
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Consumer<CalculatorData>(
                builder: (context, calculatorData, child) {
                  return Text(
                    calculatorData.expression,
                    style: const TextStyle(fontSize: 32),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Consumer<CalculatorData>(
                builder: (context, calculatorData, child) {
                  return Text(
                    calculatorData.result,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
          Row(
            children: [
              _buildButton(context, '7'),
              _buildButton(context, '8'),
              _buildButton(context, '9'),
              _buildButton(context, '÷'),
            ],
          ),
          Row(
            children: [
              _buildButton(context, '4'),
              _buildButton(context, '5'),
              _buildButton(context, '6'),
              _buildButton(context, '×'),
            ],
          ),
          Row(
            children: [
              _buildButton(context, '1'),
              _buildButton(context, '2'),
              _buildButton(context, '3'),
              _buildButton(context, '-'),
            ],
          ),
          Row(
            children: [
              _buildButton(context, '0'),
              _buildButton(context, '.'),
              _buildButton(context, '='),
              _buildButton(context, '+'),
            ],
          ),
          Row(
            children: [
              _buildButton(context, 'Clear'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String buttonText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(24.0),
            textStyle: const TextStyle(fontSize: 24),
          ),
          onPressed: () {
            final calculatorData = Provider.of<CalculatorData>(context, listen: false);
            if (buttonText == '=') {
              calculatorData.calculate();
            } else if (buttonText == 'Clear') {
              calculatorData.clear();
            } else {
              calculatorData.updateExpression(calculatorData.expression + buttonText);
            }
          },
          child: Text(buttonText),
        ),
      ),
    );
  }
}