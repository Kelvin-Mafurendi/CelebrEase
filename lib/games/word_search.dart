import 'package:flutter/material.dart';
import 'dart:math';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  _WordSearchGameState createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  // Grid size
  static const int rows = 12;
  static const int cols = 12;
  
  // Word list related to celebrations
  final List<String> words = [
    'PARTY',
    'CAKE',
    'DANCE',
    'MUSIC',
    'GIFTS',
    'GUESTS',
    'VENUE',
    'DECOR',
    'CELEBREASE',
    'VENDOR',
    'FLASHAD'
  ];
  
  // Game state
  late List<List<String>> grid;
  List<String> foundWords = [];
  String selectedWord = '';
  List<Position> selectedCells = [];
  
  @override
  void initState() {
    super.initState();
    initializeGame();
  }
  
  void initializeGame() {
    // Initialize empty grid
    grid = List.generate(rows, (_) => List.filled(cols, ''));
    foundWords = [];
    
    // Place words in the grid
    for (String word in words) {
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 100) {
        int direction = Random().nextInt(3); // 0: horizontal, 1: vertical, 2: diagonal
        int startRow = Random().nextInt(rows);
        int startCol = Random().nextInt(cols);
        
        if (canPlaceWord(word, startRow, startCol, direction)) {
          placeWord(word, startRow, startCol, direction);
          placed = true;
        }
        attempts++;
      }
    }
    
    // Fill empty cells with random letters
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (grid[i][j].isEmpty) {
          grid[i][j] = String.fromCharCode(Random().nextInt(26) + 65);
        }
      }
    }
  }
  
  bool canPlaceWord(String word, int startRow, int startCol, int direction) {
    if (direction == 0) { // horizontal
      if (startCol + word.length > cols) return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[startRow][startCol + i].isNotEmpty && 
            grid[startRow][startCol + i] != word[i]) {
          return false;
        }
      }
    } else if (direction == 1) { // vertical
      if (startRow + word.length > rows) return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[startRow + i][startCol].isNotEmpty && 
            grid[startRow + i][startCol] != word[i]) {
          return false;
        }
      }
    } else { // diagonal
      if (startRow + word.length > rows || startCol + word.length > cols) return false;
      for (int i = 0; i < word.length; i++) {
        if (grid[startRow + i][startCol + i].isNotEmpty && 
            grid[startRow + i][startCol + i] != word[i]) {
          return false;
        }
      }
    }
    return true;
  }
  
  void placeWord(String word, int startRow, int startCol, int direction) {
    for (int i = 0; i < word.length; i++) {
      if (direction == 0) { // horizontal
        grid[startRow][startCol + i] = word[i];
      } else if (direction == 1) { // vertical
        grid[startRow + i][startCol] = word[i];
      } else { // diagonal
        grid[startRow + i][startCol + i] = word[i];
      }
    }
  }
  
  void onCellSelected(int row, int col) {
    setState(() {
      if (selectedCells.isEmpty) {
        selectedCells.add(Position(row, col));
      } else {
        selectedCells.add(Position(row, col));
        checkWord();
      }
    });
  }
  
  void checkWord() {
    if (selectedCells.length != 2) return;
    
    Position start = selectedCells[0];
    Position end = selectedCells[1];
    String word = '';
    
    if (start.row == end.row) { // horizontal
      int minCol = min(start.col, end.col);
      int maxCol = max(start.col, end.col);
      for (int col = minCol; col <= maxCol; col++) {
        word += grid[start.row][col];
      }
    } else if (start.col == end.col) { // vertical
      int minRow = min(start.row, end.row);
      int maxRow = max(start.row, end.row);
      for (int row = minRow; row <= maxRow; row++) {
        word += grid[row][start.col];
      }
    } else if ((end.row - start.row).abs() == (end.col - start.col).abs()) { // diagonal
      int rowStep = (end.row - start.row).sign;
      int colStep = (end.col - start.col).sign;
      int steps = (end.row - start.row).abs();
      for (int i = 0; i <= steps; i++) {
        word += grid[start.row + i * rowStep][start.col + i * colStep];
      }
    }
    
    if (words.contains(word) && !foundWords.contains(word)) {
      foundWords.add(word);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found word: $word!'))
      );
    }
    
    selectedCells.clear();
    
    if (foundWords.length == words.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You found all the words!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  initializeGame();
                });
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Celebration Word Search'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Find these words:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Wrap(
            spacing: 8,
            children: words.map((word) {
              bool isFound = foundWords.contains(word);
              return Chip(
                label: Text(
                  word,
                  style: TextStyle(
                    decoration: isFound ? TextDecoration.lineThrough : null,
                    color: isFound ? Colors.grey : Colors.black,
                  ),
                ),
                backgroundColor: isFound ? Colors.grey[200] : Colors.purple[100],
              );
            }).toList(),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                int row = index ~/ cols;
                int col = index % cols;
                bool isSelected = selectedCells.any((pos) => 
                    pos.row == row && pos.col == col);
                
                return GestureDetector(
                  onTap: () => onCellSelected(row, col),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple[500] : Colors.purple[200],
                      border: Border.all(color: Colors.purple[900]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      grid[row][col],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            initializeGame();
          });
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class Position {
  final int row;
  final int col;
  
  Position(this.row, this.col);
}