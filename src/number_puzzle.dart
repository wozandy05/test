import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NumberPuzzleApp());
}

class NumberPuzzleApp extends StatelessWidget {
  const NumberPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NumberPuzzleHomePage(),
    );
  }
}

class NumberPuzzleHomePage extends StatefulWidget {
  const NumberPuzzleHomePage({super.key});

  @override
  State<NumberPuzzleHomePage> createState() => _NumberPuzzleHomePageState();
}

class _NumberPuzzleHomePageState extends State<NumberPuzzleHomePage> {
  List<int> tiles = [];
  int gridSize = 4;
  bool gameWon = false;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
    tiles.remove(0);
    tiles.add(0);
    shuffle();
    gameWon = false;
  }

  void shuffle() {
    Random random = Random();
    do {
      tiles.shuffle(random);
    } while (!isSolvable());
  }

  bool isSolvable() {
    int inversions = 0;
    for (int i = 0; i < tiles.length; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] != 0 && tiles[j] != 0 && tiles[i] > tiles[j]) {
          inversions++;
        }
      }
    }

    if (gridSize % 2 == 0) {
      int blankRow = tiles.indexOf(0) ~/ gridSize;
      return (inversions + blankRow) % 2 == 1;
    } else {
      return inversions % 2 == 0;
    }
  }

  void moveTile(int index) {
    int blankIndex = tiles.indexOf(0);
    int row = index ~/ gridSize;
    int col = index % gridSize;
    int blankRow = blankIndex ~/ gridSize;
    int blankCol = blankIndex % gridSize;

    if ((row == blankRow && (col == blankCol - 1 || col == blankCol + 1)) ||
        (col == blankCol && (row == blankRow - 1 || row == blankRow + 1))) {
      setState(() {
        tiles[blankIndex] = tiles[index];
        tiles[index] = 0;
        checkWin();
      });
    }
  }

  void checkWin() {
    bool won = true;
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) {
        won = false;
        break;
      }
    }
    if (won) {
      setState(() {
        gameWon = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (gameWon)
            const Text(
              'You Win!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (!gameWon) {
                    moveTile(index);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: tiles[index] == 0 ? Colors.grey[300] : Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      tiles[index] == 0 ? '' : '${tiles[index]}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: tiles[index] == 0 ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                resetGame();
              });
            },
            child: const Text('Reset Game'),
          ),
        ],
      ),
    );
  }
}