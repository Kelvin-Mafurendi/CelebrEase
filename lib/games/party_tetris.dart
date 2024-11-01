import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:maroro/main.dart';

// Power-up types
enum PowerUpType { clearRow, slowDown, scoreboost }

class TetrisPiece {
  final List<List<int>> shape;
  final Color color;
  final String name;

  TetrisPiece(this.shape, this.color, this.name);
}

class PowerUp {
  final PowerUpType type;
  bool isActive = false;
  Timer? timer;

  PowerUp(this.type);
}

class PartyTetrisGame extends StatefulWidget {
  const PartyTetrisGame({super.key});

  @override
  _PartyTetrisGameState createState() => _PartyTetrisGameState();
}

class _PartyTetrisGameState extends State<PartyTetrisGame> {
  static const int BOARD_WIDTH = 10;
  static const int BOARD_HEIGHT = 20;
  static const double CELL_SIZE = 30.0;

  late List<List<Color?>> board;
  late TetrisPiece currentPiece;
  late int currentX;
  late int currentY;
  late Timer gameTimer;
  int score = 0;
  bool isGameOver = false;
  bool showInstructions = true;
  Map<PowerUpType, PowerUp> powerUps = {};
  int dropSpeed = 500; //
  bool _soundEnabled = true;

  void gameOver() {
    setState(() {
      isGameOver = true;
      gameTimer.cancel();
    });
    SoundManager.playGameOver();
  }

  void activatePowerUp(PowerUpType type) {
    final powerUp = powerUps[type]!;
    if (powerUp.isActive) return;

    SoundManager.playPowerUp();
    powerUp.isActive = true;

    switch (type) {
      case PowerUpType.clearRow:
        clearBottomRow();
        break;
      case PowerUpType.slowDown:
        setDropSpeed(dropSpeed * 2);
        powerUp.timer = Timer(Duration(seconds: 10), () {
          setDropSpeed(dropSpeed ~/ 2);
          powerUp.isActive = false;
        });
        break;
      case PowerUpType.scoreboost:
        powerUp.timer = Timer(Duration(seconds: 15), () {
          powerUp.isActive = false;
        });
        break;
    }
  }

  // Enhanced piece collection with event-themed shapes
  final List<TetrisPiece> pieces = [
    // Round table (8 people)
    TetrisPiece([
      [1, 1],
      [1, 1],
    ], primaryColor, "Round Table"),

    // Long banquet table
    TetrisPiece([
      [1, 1, 1, 1]
    ], Colors.blue, "Banquet Table"),

    // Dance floor
    TetrisPiece([
      [1, 1, 1],
      [1, 1, 1],
      [1, 0, 1]
    ], Colors.brown, "Dance Floor"),

    // Stage setup
    TetrisPiece([
      [1, 1, 1],
      [0, 1, 0]
    ], Colors.purple, "Stage"),

    // Photo booth
    TetrisPiece([
      [1, 1],
      [1, 0],
      [1, 0]
    ], Colors.orange, "Photo Booth"),

    // Bar counter
    TetrisPiece([
      [1, 0, 0],
      [1, 1, 1],
      [1, 0, 0]
    ], Colors.green, "Bar Counter"),
  ];

  @override
  void initState() {
    super.initState();
    SoundManager.initialize();
    _soundEnabled = true; // Get initial state
    initializePowerUps();
  }

  @override
  void dispose() {
    SoundManager.dispose();
    gameTimer.cancel();
    super.dispose();
  }

  void initializePowerUps() {
    powerUps[PowerUpType.clearRow] = PowerUp(PowerUpType.clearRow);
    powerUps[PowerUpType.slowDown] = PowerUp(PowerUpType.slowDown);
    powerUps[PowerUpType.scoreboost] = PowerUp(PowerUpType.scoreboost);
  }

  void startGame() {
    board = List.generate(
      BOARD_HEIGHT,
      (i) => List.generate(BOARD_WIDTH, (j) => null),
    );
    score = 0;
    dropSpeed = 500;
    spawnNewPiece();

    gameTimer = Timer.periodic(Duration(milliseconds: dropSpeed), (timer) {
      if (!isGameOver) {
        moveDown();
      }
    });
  }

  void setDropSpeed(int newSpeed) {
    dropSpeed = newSpeed;
    gameTimer.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: dropSpeed), (timer) {
      if (!isGameOver) {
        moveDown();
      }
    });
  }

  void clearLines() {
    bool linesCleared = false;

    for (int i = BOARD_HEIGHT - 1; i >= 0; i--) {
      bool isLineFull = true;
      for (int j = 0; j < BOARD_WIDTH; j++) {
        if (board[i][j] == null) {
          isLineFull = false;
          break;
        }
      }

      if (isLineFull) {
        linesCleared = true;
        setState(() {
          score += powerUps[PowerUpType.scoreboost]!.isActive ? 200 : 100;
          for (int k = i; k > 0; k--) {
            board[k] = List.from(board[k - 1]);
          }
          board[0] = List.generate(BOARD_WIDTH, (j) => null);
        });
      }
    }

    if (linesCleared) {
      SoundManager.playClearLine();
    }
  }

  void clearBottomRow() {
    setState(() {
      board.removeLast();
      board.insert(0, List.generate(BOARD_WIDTH, (j) => null));
      score += 100;
    });
  }

  Widget buildInstructionsPage() {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Party Tetris',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              color: backgroundColor,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Play:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '• Swipe LEFT or RIGHT to move pieces\n'
                      '• TAP to rotate pieces\n'
                      '• Swipe DOWN for quick drop\n'
                      '• Complete rows to score points\n'
                      '• Collect power-ups for special abilities',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Power-ups:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '🧹 Clear Row: Instantly removes bottom row\n'
                      '⏰ Slow Down: Reduces piece drop speed\n'
                      '⭐ Score Boost: Double points for 15 seconds',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () {
              setState(() {
                showInstructions = false;
                startGame();
              });
            },
            child: Text(
              'Start Game',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  void spawnNewPiece() {
    currentPiece = pieces[Random().nextInt(pieces.length)];
    currentX = BOARD_WIDTH ~/ 2 - currentPiece.shape[0].length ~/ 2;
    currentY = 0;

    if (!isValidMove(currentX, currentY, currentPiece)) {
      SoundManager.playGameOver();
      setState(() {
        isGameOver = true;
        gameTimer.cancel();
      });
    }
  }

  bool isValidMove(int x, int y, TetrisPiece piece) {
    for (int i = 0; i < piece.shape.length; i++) {
      for (int j = 0; j < piece.shape[i].length; j++) {
        if (piece.shape[i][j] == 1) {
          int newX = x + j;
          int newY = y + i;

          if (newX < 0 || newX >= BOARD_WIDTH || newY >= BOARD_HEIGHT) {
            return false;
          }

          if (newY >= 0 && board[newY][newX] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void moveLeft() {
    if (isValidMove(currentX - 1, currentY, currentPiece)) {
      setState(() {
        currentX--;
      });
      SoundManager.playMove();
    }
  }

  void moveRight() {
    if (isValidMove(currentX + 1, currentY, currentPiece)) {
      setState(() {
        currentX++;
      });
      SoundManager.playMove();
    }
  }

  void rotate() {
    List<List<int>> newShape = List.generate(
      currentPiece.shape[0].length,
      (i) => List.generate(currentPiece.shape.length, (j) => 0),
    );

    for (int i = 0; i < currentPiece.shape.length; i++) {
      for (int j = 0; j < currentPiece.shape[i].length; j++) {
        newShape[j][currentPiece.shape.length - 1 - i] =
            currentPiece.shape[i][j];
      }
    }

    TetrisPiece rotatedPiece = TetrisPiece(
      newShape,
      currentPiece.color,
      currentPiece.name,
    );

    if (isValidMove(currentX, currentY, rotatedPiece)) {
      setState(() {
        currentPiece = rotatedPiece;
      });
      SoundManager.playRotate();
    }
  }

  void placePiece() {
    for (int i = 0; i < currentPiece.shape.length; i++) {
      for (int j = 0; j < currentPiece.shape[i].length; j++) {
        if (currentPiece.shape[i][j] == 1) {
          if (currentY + i >= 0) {
            board[currentY + i][currentX + j] = currentPiece.color;
          }
        }
      }
    }
  }

  void moveDown() {
    if (isValidMove(currentX, currentY + 1, currentPiece)) {
      setState(() {
        currentY++;
      });
    } else {
      placePiece();
      SoundManager.playDrop();
      clearLines();
      spawnNewPiece();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showInstructions) {
      return Scaffold(
        body: buildInstructionsPage(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Party Tetris'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _soundEnabled = !_soundEnabled;
                SoundManager.toggleSound(); // Add this line
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          // color: backgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Row(
                      children: [
                        PowerUpButton(
                          icon: Icons.cleaning_services,
                          onPressed: () =>
                              activatePowerUp(PowerUpType.clearRow),
                          isActive: powerUps[PowerUpType.clearRow]!.isActive,
                        ),
                        PowerUpButton(
                          icon: Icons.timer,
                          onPressed: () =>
                              activatePowerUp(PowerUpType.slowDown),
                          isActive: powerUps[PowerUpType.slowDown]!.isActive,
                        ),
                        PowerUpButton(
                          icon: Icons.star,
                          onPressed: () =>
                              activatePowerUp(PowerUpType.scoreboost),
                          isActive: powerUps[PowerUpType.scoreboost]!.isActive,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < 0) {
                          moveLeft();
                        } else {
                          moveRight();
                        }
                      },
                      onTap: rotate,
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          moveDown();
                        }
                      },
                      child: CustomPaint(
                        size: Size(
                            CELL_SIZE * BOARD_WIDTH, CELL_SIZE * BOARD_HEIGHT),
                        painter: TetrisPainter(
                          board: board,
                          currentPiece: currentPiece,
                          currentX: currentX,
                          currentY: currentY,
                          cellSize: CELL_SIZE,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isGameOver)
              
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      
                      Text(
                        'Game Over!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isGameOver = false;
                            score = 0;
                            startGame();
                          });
                        },
                        child: Text('Play Again'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TetrisPainter extends CustomPainter {
  final List<List<Color?>> board;
  final TetrisPiece currentPiece;
  final int currentX;
  final int currentY;
  final double cellSize;

  TetrisPainter({
    required this.board,
    required this.currentPiece,
    required this.currentX,
    required this.currentY,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw board
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] != null) {
          drawCell(canvas, j, i, board[i][j]!);
        }
      }
    }

    // Draw current piece
    for (int i = 0; i < currentPiece.shape.length; i++) {
      for (int j = 0; j < currentPiece.shape[i].length; j++) {
        if (currentPiece.shape[i][j] == 1) {
          drawCell(canvas, currentX + j, currentY + i, currentPiece.color);
        }
      }
    }

    // Draw grid
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= board[0].length; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
    }

    for (int i = 0; i <= board.length; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }
  }

  void drawCell(Canvas canvas, int x, int y, Color color) {
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(
      x * cellSize,
      y * cellSize,
      cellSize,
      cellSize,
    );
    canvas.drawRect(rect, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(TetrisPainter oldDelegate) => true;
}

class PowerUpButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const PowerUpButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IconButton(
        icon: Icon(icon),
        onPressed: isActive ? null : onPressed,
        color: isActive ? Colors.grey : primaryColor,
      ),
    );
  }
}
class SoundManager {
  static final AudioPlayer _movePlayer = AudioPlayer();
  static final AudioPlayer _rotatePlayer = AudioPlayer();
  static final AudioPlayer _dropPlayer = AudioPlayer();
  static final AudioPlayer _clearLinePlayer = AudioPlayer();
  static final AudioPlayer _gameOverPlayer = AudioPlayer();
  static final AudioPlayer _powerUpPlayer = AudioPlayer();

  // Sound URLs with correct path format
  static const String moveSound = "assets/sound/click.mp3";
  static const String rotateSound = "assets/sound/swoosh.mp3";
  static const String dropSound = "assets/sound/thud.mp3";
  static const String clearLineSound = "assets/sound/sparkle.mp3";
  static const String gameOverSound = "assets/sound/game_over.mp3";
  static const String powerUpSound = "assets/sound/power_up.mp3";

  static bool _soundEnabled = true;

  static Future<void> initialize() async {
    try {
      await _movePlayer.setVolume(0.5);
      await _rotatePlayer.setVolume(0.5);
      await _dropPlayer.setVolume(0.5);
      await _clearLinePlayer.setVolume(0.7);
      await _gameOverPlayer.setVolume(0.7);
      await _powerUpPlayer.setVolume(0.6);
    } catch (e) {
      print("Error initializing sound players: $e");
    }
  }

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
    print("Sound enabled: $_soundEnabled"); // Debug print
  }

  static Future<void> playSound(AudioPlayer player, String soundPath) async {
    if (_soundEnabled) {
      try {
        final source = AssetSource(soundPath.replaceFirst('assets/', ''));
        await player.play(source);
      } catch (e) {
        print("Error playing sound $soundPath: $e");
      }
    }
  }

  static Future<void> playMove() async {
    await playSound(_movePlayer, moveSound);
  }

  static Future<void> playRotate() async {
    await playSound(_rotatePlayer, rotateSound);
  }

  static Future<void> playDrop() async {
    await playSound(_dropPlayer, dropSound);
  }

  static Future<void> playClearLine() async {
    await playSound(_clearLinePlayer, clearLineSound);
  }

  static Future<void> playGameOver() async {
    await playSound(_gameOverPlayer, gameOverSound);
  }

  static Future<void> playPowerUp() async {
    await playSound(_powerUpPlayer, powerUpSound);
  }

  static void dispose() {
    _movePlayer.dispose();
    _rotatePlayer.dispose();
    _dropPlayer.dispose();
    _clearLinePlayer.dispose();
    _gameOverPlayer.dispose();
    _powerUpPlayer.dispose();
  }
}