import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CalculatorData(),
      builder: (context, child) => MaterialApp(
        title: 'Calculator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Calculator(),
      ),
    ),
  );
}

class CalculatorData extends ChangeNotifier {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondOperand = false;

  String get display => _display;

  void inputDigit(String digit) {
    if (_waitingForSecondOperand) {
      _display = digit;
      _waitingForSecondOperand = false;
    } else {
      if (_display == '0') {
        _display = digit;
      } else {
        _display = _display + digit;
      }
    }
    notifyListeners();
  }

  void inputDecimal() {
    if (_waitingForSecondOperand) {
      _display = '0.';
      _waitingForSecondOperand = false;
    } else {
      if (!_display.contains('.')) {
        _display = _display + '.';
      }
    }
    notifyListeners();
  }

  void performOperation(String nextOperator) {
    double? number = double.tryParse(_display);
    if (number == null) {
      return;
    }

    if (_firstOperand == null) {
      _firstOperand = number;
    } else if (_operator != null) {
      _firstOperand = _performCalculation();
    }

    _waitingForSecondOperand = true;
    _operator = nextOperator;

    // Ensure _firstOperand is not null before assigning it to the display
    _display = _firstOperand != null ? _firstOperand.toString() : '0';
    notifyListeners();
  }

  double? _performCalculation() {
    double? secondNumber = double.tryParse(_display);
    if (_firstOperand == null || secondNumber == null || _operator == null) {
      return null;
    }

    switch (_operator) {
      case '+':
        return _firstOperand! + secondNumber;
      case '-':
        return _firstOperand! - secondNumber;
      case '*':
        return _firstOperand! * secondNumber;
      case '/':
        if (secondNumber == 0) {
          return double.infinity;
        }
        return _firstOperand! / secondNumber;
    }
    return null;
  }

  void clear() {
    _display = '0';
    _firstOperand = null;
    _operator = null;
    _waitingForSecondOperand = false;
    notifyListeners();
  }

  void calculateResult() {
    if (_operator == null) {
      return;
    }
    double? result = _performCalculation();
    if (result != null) {
      _display = result.toString();
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = true;
      notifyListeners();
    }
  }

  void toggleSign() {
    double? number = double.tryParse(_display);
    if (number != null) {
      _display = (number * -1).toString();
      notifyListeners();
    }
  }

  void inputPercent() {
    double? number = double.tryParse(_display);
    if (number != null) {
      _display = (number / 100).toString();
      notifyListeners();
    }
  }
}

class Calculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Consumer<CalculatorData>(
                builder: (context, calculatorData, child) {
                  return Text(
                    calculatorData.display,
                    style: const TextStyle(fontSize: 60.0),
                  );
                },
              ),
            ),
          ),
          Row(
            children: <Widget>[
              _buildButton('AC', Colors.grey, () {
                Provider.of<CalculatorData>(context, listen: false).clear();
              }),
              _buildButton('+/-', Colors.grey, () {
                Provider.of<CalculatorData>(context, listen: false).toggleSign();
              }),
              _buildButton('%', Colors.grey, () {
                Provider.of<CalculatorData>(context, listen: false).inputPercent();
              }),
              _buildButton('/', Colors.amber, () {
                Provider.of<CalculatorData>(context, listen: false).performOperation('/');
              }),
            ],
          ),
          Row(
            children: <Widget>[
              _buildButton('7', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('7');
              }),
              _buildButton('8', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('8');
              }),
              _buildButton('9', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('9');
              }),
              _buildButton('*', Colors.amber, () {
                Provider.of<CalculatorData>(context, listen: false).performOperation('*');
              }),
            ],
          ),
          Row(
            children: <Widget>[
              _buildButton('4', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('4');
              }),
              _buildButton('5', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('5');
              }),
              _buildButton('6', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('6');
              }),
              _buildButton('-', Colors.amber, () {
                Provider.of<CalculatorData>(context, listen: false).performOperation('-');
              }),
            ],
          ),
          Row(
            children: <Widget>[
              _buildButton('1', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('1');
              }),
              _buildButton('2', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('2');
              }),
              _buildButton('3', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('3');
              }),
              _buildButton('+', Colors.amber, () {
                Provider.of<CalculatorData>(context, listen: false).performOperation('+');
              }),
            ],
          ),
          Row(
            children: <Widget>[
              _buildButton('0', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDigit('0');
              }, flex: 2),
              _buildButton('.', Colors.grey[800]!, () {
                Provider.of<CalculatorData>(context, listen: false).inputDecimal();
              }),
              _buildButton('=', Colors.amber, () {
                Provider.of<CalculatorData>(context, listen: false).calculateResult();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String buttonText, Color buttonColor, VoidCallback onPressed, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.all(22.0),
            textStyle: const TextStyle(fontSize: 28.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}