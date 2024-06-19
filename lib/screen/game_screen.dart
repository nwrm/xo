// GameScreen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xoxo/data/database_helper.dart';
import 'package:xoxo/screen/history_screen.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int gridSize;
  late List<List<String>> board;
  DatabaseHelper dbHelper = DatabaseHelper();
  bool isAiMode = false;
  String currentPlayer = 'X';

  @override
  void initState() {
    super.initState();
    gridSize = 3;
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
  }

  void _handleTap(int x, int y) {
    if (board[y][x] == '') {
      setState(() {
        board[y][x] = currentPlayer;
        if (_checkWin(currentPlayer)) {
          _saveGame();
          _showGameOverDialog('$currentPlayer wins!');
        } else if (_checkDraw()) {
          _saveGame();
          _showGameOverDialog('It\'s a draw!');
        } else {
          if (isAiMode && currentPlayer == 'X') {
            _makeAIMove();
          } else {
            currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
          }
        }
      });
    }
  }

  Future<void> _saveGame() async {
    String moves = board.expand((e) => e).join(',');
    await dbHelper.insertGame(moves); // ปรับเพิ่ม gridSize ที่จะถูกส่งไป
  }

  bool _checkWin(String player) {
    for (int y = 0; y < gridSize; y++) {
      if (board[y].every((cell) => cell == player)) {
        return true;
      }
    }

    for (int x = 0; x < gridSize; x++) {
      if (board.every((row) => row[x] == player)) {
        return true;
      }
    }

    if (List.generate(gridSize, (index) => board[index][index]).every((cell) => cell == player)) {
      return true;
    }
    if (List.generate(gridSize, (index) => board[index][gridSize - 1 - index]).every((cell) => cell == player)) {
      return true;
    }

    return false;
  }

  bool _checkDraw() {
    return board.every((row) => row.every((cell) => cell.isNotEmpty));
  }

  void _makeAIMove() {
    List<int> emptyCells = [];

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (board[y][x] == '') {
          emptyCells.add(x + y * gridSize);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      int randomIndex = Random().nextInt(emptyCells.length);
      int position = emptyCells[randomIndex];
      int x = position % gridSize;
      int y = position ~/ gridSize;

      setState(() {
        board[y][x] = 'O';
        if (_checkWin('O')) {
          _showGameOverDialog('O wins!');
        } else if (_checkDraw()) {
          _showGameOverDialog('It\'s a draw!');
        }
        currentPlayer = 'X';
      });
    }
  }

  void _toggleMode() {
    setState(() {
      isAiMode = !isAiMode;
      _initializeBoard();
      currentPlayer = 'X';
    });
  }

  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeBoard();
                  currentPlayer = 'X';
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XO', style: TextStyle(fontFamily: 'Pacifico')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()), // ส่ง gridSize ไปยัง HistoryScreen
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildBoard()),
          _buildGridSizeInput(),
          _buildModeToggle(),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
        ),
        itemBuilder: _buildGridItems,
        itemCount: gridSize * gridSize,
      ),
    );
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int x = index % gridSize;
    int y = index ~/ gridSize;

    return GestureDetector(
      onTap: () {
        _handleTap(x, y);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Center(
          child: Text(
            board[y][x],
            style: TextStyle(fontSize: 32.0, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildGridSizeInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Text('Grid Size:', style: TextStyle(color: Colors.grey[700]!)),
          SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter grid size',
                hintStyle: TextStyle(color: Colors.grey[500]!),
              ),
              onSubmitted: (value) {
                int newSize = int.tryParse(value) ?? gridSize;
                setState(() {
                  gridSize = newSize;
                  _initializeBoard();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Mode: ', style: TextStyle(color: Colors.grey[700]!)),
          ToggleButtons(
            isSelected: [!isAiMode, isAiMode],
            onPressed: (index) {
              _toggleMode();
            },
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('User vs User', style: TextStyle(color: Colors.blueAccent)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('User vs AI', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

