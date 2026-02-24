// ignore_for_file: avoid_print, unused_field, deprecated_member_use, use_build_context_synchronously, file_names, library_prefixes

import 'dart:io';
import 'dart:math' as Math;
import 'package:audioplayers/audioplayers.dart';
import 'package:balloonblast/src/adds/ads_helper.dart';
import 'package:balloonblast/src/screen/3Dbox.dart';
import 'package:balloonblast/src/screen/ball3D.dart';
import 'package:balloonblast/src/screen/iconsBlast/Ball3DIcon.dart';
import 'package:balloonblast/src/screen/rules/bengRules.dart';
import 'package:balloonblast/src/screen/rules/engRules.dart';
import 'package:balloonblast/src/screen/rules/hindRules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cellModel.dart';

class ChainReactionGame extends StatefulWidget {
  final int playerCount;
  final List<Color?> playerSelectColors;
  final bool isComputerMode;

  const ChainReactionGame({
    super.key,
    required this.playerCount,
    required this.playerSelectColors,
    this.isComputerMode = false,
  });

  @override
  State<ChainReactionGame> createState() => _ChainReactionGameState();
}

class _ChainReactionGameState extends State<ChainReactionGame> {
  late int rows;
  late int cols;

  late List<ValueNotifier<Cell>> cells;
  int currentPlayer = 1;

  late Map<int, Color> playerColors;

  int pendingExplosions = 0;
  bool waitingForExplosion = false;
  bool gameOver = false;

  Set<int> activePlayers = {};

  BannerAd? _bottomBannerAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdLoaded = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingSound = false;

  int blastCountThisTurn = 0;
  final int maxBlastPerTurn = 10;
  bool forceSwitchAfterLimit = false;
  bool isInternetAvailable = true;

  int highScore = 0;
  bool isNewHighScore = false;

  @override
  void initState() {
    super.initState();

    loadHighScore();

    final width =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;

    if (width > 600) {
      rows = 12;
      cols = 8;
    } else {
      rows = 10;
      cols = 6;
    }

    playerColors = {
      for (int i = 1; i <= widget.playerCount; i++)
        i: widget.playerSelectColors[i - 1]!,
    };

    resetBoard();

    checkInternetOnStart();

    _bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          print('Bottom banner failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
    _loadAd();
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();

    if (score > highScore) {
      highScore = score;

      await prefs.setInt('high_score', score);

      isNewHighScore = true;
    } else {
      isNewHighScore = false;
    }
  }

  Future<void> playBlastSound() async {
    if (_isPlayingSound) return;

    _isPlayingSound = true;

    try {
      await _audioPlayer.play(
        AssetSource('sound/blast.wav'),
        volume: 0.7,
      );
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 300), () {
      _isPlayingSound = false;
    });
  }

  void _loadAd() {
    RewardedInterstitialAd.load(
      adUnitId: AdHelper.getRewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Rewarded Interstitial Ad loaded.');
          setState(() {
            _rewardedInterstitialAd = ad;
            _isAdLoaded = true;
          });

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('Ad dismissed.');
              ad.dispose();
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Ad failed to show: $error');
              ad.dispose();
              _loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Failed to load rewarded interstitial ad: $error');
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );
  }

  void _showAd() {
    if (_rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Reward received: ${reward.amount} ${reward.type}"),
          ));
        },
      );
      _rewardedInterstitialAd = null;
      _isAdLoaded = false;
    } else {
      print("Ad not ready yet.");
    }
  }

  Future<bool> hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }

    return false;
  }

  void checkInternetOnStart() async {
    bool internet = await hasRealInternet();

    if (!internet) {
      isInternetAvailable = false;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Internet Required"),
          content: const Text("Please turn on internet to play this game."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Exit"),
            )
          ],
        ),
      );
    } else {
      isInternetAvailable = true;
    }
  }

  @override
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    _bottomBannerAd?.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  int index(int row, int col) => row * cols + col;

  bool isInside(int row, int col) =>
      row >= 0 && row < rows && col >= 0 && col < cols;

  int getLimit(int row, int col) {
    if ((row == 0 || row == rows - 1) && (col == 0 || col == cols - 1)) {
      return 1;
    } else if (row == 0 || row == rows - 1 || col == 0 || col == cols - 1) {
      return 2;
    }
    return 3;
  }

  void addBall(int row, int col, [int? forcePlayer]) {
    if (gameOver) return;

    final i = index(row, col);
    final cellNotifier = cells[i];
    final cell = cellNotifier.value;

    if (forcePlayer == null && cell.count > 0 && cell.owner != currentPlayer) {
      return;
    }

    final thisPlayer = forcePlayer ?? currentPlayer;
    activePlayers.add(thisPlayer);

    cellNotifier.value = Cell(
      count: cell.count + 1,
      owner: thisPlayer,
      color: playerColors[thisPlayer]!,
    );

    final isExplosion = cellNotifier.value.count > getLimit(row, col);

    if (isExplosion) {
      if (blastCountThisTurn >= maxBlastPerTurn) {
        forceSwitchAfterLimit = true;
        return;
      }

      blastCountThisTurn++;
      pendingExplosions++;
      waitingForExplosion = true;

      Future.delayed(const Duration(milliseconds: 250), () async {
        await explode(row, col, thisPlayer);

        pendingExplosions--;

        if (pendingExplosions == 0) {
          waitingForExplosion = false;

          checkWinner();

          if (!gameOver) {
            resetBlastCounter();
            switchPlayer();
          }
        }
      });
    } else if (!waitingForExplosion) {
      checkWinner();
      if (!gameOver) {
        switchPlayer();
      }
    }
  }

  void resetBlastCounter() {
    blastCountThisTurn = 0;
    forceSwitchAfterLimit = false;
  }

  Future<void> explode(int row, int col, int player) async {
    if (gameOver) return;
    playBlastSound();
    final i = index(row, col);
    cells[i].value = Cell();
    final directions = [
      const Offset(0, -1),
      const Offset(0, 1),
      const Offset(-1, 0),
      const Offset(1, 0),
    ];
    for (var dir in directions) {
      await Future.delayed(const Duration(milliseconds: 30));
      final newRow = row + dir.dy.toInt();
      final newCol = col + dir.dx.toInt();
      if (isInside(newRow, newCol)) {
        addBall(newRow, newCol, player);
      }
    }
  }

  void computerMove() {
    if (gameOver) return;

    int bestMove = -1;
    int bestScore = -999999;

    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i].value;

      int row = i ~/ cols;
      int col = i % cols;

      if (cell.count != 0 && cell.owner != 2) continue;

      int score = evaluateMoveAdvanced(row, col);

      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }

    if (bestMove == -1) {
      computerMoveSafe();
      return;
    }

    addBall(bestMove ~/ cols, bestMove % cols);
  }

  bool isPlayerAlive(int player) {
    return cells.any(
      (cell) => cell.value.owner == player && cell.value.count > 0,
    );
  }

  void switchPlayer() {
    if (gameOver) return;
    int nextPlayer = currentPlayer;

    for (int i = 0; i < widget.playerCount; i++) {
      nextPlayer = nextPlayer % widget.playerCount + 1;

      if (!activePlayers.contains(nextPlayer) || isPlayerAlive(nextPlayer)) {
        break;
      }
    }

    setState(() {
      currentPlayer = nextPlayer;
      print("Switched to Player $currentPlayer");
    });

    resetBlastCounter();

    if (widget.isComputerMode && currentPlayer == 2 && !gameOver) {
      Future.delayed(const Duration(milliseconds: 600), () {
        computerMove();
      });
    }
  }

  void resetBoard() {
    cells = List.generate(rows * cols, (_) => ValueNotifier(Cell()));
    currentPlayer = 1;
    pendingExplosions = 0;
    waitingForExplosion = false;
    gameOver = false;
    activePlayers.clear();
    setState(() {});
  }

  void checkWinner() {
    final owners =
        cells.where((c) => c.value.count > 0).map((c) => c.value.owner).toSet();

    if (activePlayers.length < widget.playerCount) {
      return;
    }

    if (owners.length == 1) {
      gameOver = true;

      Future.delayed(const Duration(milliseconds: 300), () {
        _showAd();
        if (mounted) showWinnerDialog(owners.first);
      });
    }
  }

  Future<void> showWinnerDialog(int player) async {
    final playerColor = playerColors[player]!;

    final score = getPlayerScore(player);

    saveScoreToLeaderboard(score);

    //  HIGH SCORE SAVE
    await saveHighScore(score);

    bool isComputerGame = widget.isComputerMode;

    String titleText;

    if (isComputerGame) {
      if (player == 1) {
        titleText = "You Win!";
      } else {
        titleText = "Computer Wins!";
      }
    } else {
      titleText = "Player $player Wins!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 We Have a Winner!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: playerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Score: $score",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "🏆 High Score: $highScore",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isNewHighScore)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "🎉 NEW HIGH SCORE!",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showAd();

              Navigator.of(context).pop();

              Navigator.of(context).maybePop();
            },
            child: const Text('Exit'),
          ),
          TextButton(
            onPressed: () {
              _showAd();

              Navigator.of(context).pop();

              resetBoard();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Future<void> saveScoreToLeaderboard(int score) async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString("player_name") ?? "Unknown";

    await FirebaseFirestore.instance.collection("leaderboard").add({
      "name": name,
      "score": score,
      "time": FieldValue.serverTimestamp(),
    });
  }

  Widget buildCell(int row, int col) {
    final i = index(row, col);
    final limit = getLimit(row, col);

    return ValueListenableBuilder<Cell>(
      valueListenable: cells[i],
      builder: (_, cell, __) => CellWidget(
        cell: cell,
        borderColor: playerColors[currentPlayer]!,
        limit: limit,
        onTap: () async {
          if (widget.isComputerMode && currentPlayer == 2) return;
          bool internet = await hasRealInternet();

          if (!internet) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("No Internet"),
                content: const Text("Internet is required to play."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  )
                ],
              ),
            );

            return;
          }
          addBall(row, col);
        },
      ),
    );
  }

  int getPlayerScore(int player) {
    int score = 0;

    for (var cell in cells) {
      if (cell.value.owner == player) {
        score += cell.value.count;
      }
    }

    return score;
  }

  String getTurnText() {
    int score = getPlayerScore(currentPlayer);
    if (widget.isComputerMode) {
      if (currentPlayer == 1) {
        return "Your Turn(Score: $score)";
      } else {
        return "Computer Turn(Score: $score)";
      }
    } else {
      return "Player $currentPlayer Turn(Score: $score)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 8, 74, 128),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: playerColors[currentPlayer],
                shape: BoxShape.circle,
              ),
            ),
            Text(
              getTurnText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 'en') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EngRuleScreen(),
                  ),
                );
              } else if (value == 'hi') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HindiRuleScreen(),
                  ),
                );
              } else if (value == 'bn') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BnRuleScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'en',
                child: Text("English"),
              ),
              const PopupMenuItem(
                value: 'hi',
                child: Text("हिन्दी (Hindi)"),
              ),
              const PopupMenuItem(
                value: 'bn',
                child: Text("বাংলা (Bengali)"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double gridWidth = constraints.maxWidth;
                double gridHeight = constraints.maxHeight;
                double cellWidth = gridWidth / cols;
                double cellHeight = gridHeight / rows;
                double cellSize = Math.min(cellWidth, cellHeight);

                return Center(
                  child: SizedBox(
                    width: cellSize * cols,
                    height: cellSize * rows,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: 1,
                      ),
                      itemCount: rows * cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ cols;
                        int c = index % cols;
                        return buildCell(r, c);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (_bottomBannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: MediaQuery.of(context).size.width,
                height: _bottomBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bottomBannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  int evaluateMoveAdvanced(int row, int col) {
    int score = 0;

    int limit = getLimit(row, col);
    final cell = cells[index(row, col)].value;

    if (cell.count == limit) {
      score += 1000;
    }

    final dirs = [
      const Offset(0, -1),
      const Offset(0, 1),
      const Offset(-1, 0),
      const Offset(1, 0),
    ];

    for (var d in dirs) {
      int r = row + d.dy.toInt();
      int c = col + d.dx.toInt();

      if (!isInside(r, c)) continue;

      final neighbor = cells[index(r, c)].value;
      int nLimit = getLimit(r, c);

      if (neighbor.owner == 1 && neighbor.count == nLimit - 1) {
        score -= 1500;
      }

      if (neighbor.owner == 1 && neighbor.count < nLimit - 1) {
        score += 200;
      }

      if (neighbor.owner == 2 && neighbor.count == nLimit - 1) {
        score += 300;
      }
    }

    if (limit == 1) score += 500;

    if (limit == 2) score += 200;
    return score;
  }

  void computerMoveSafe() {
    List<int> safeMoves = [];

    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i].value;

      int row = i ~/ cols;
      int col = i % cols;

      if (cell.count != 0 && cell.owner != 2) continue;

      if (!isDangerousMove(row, col)) {
        safeMoves.add(i);
      }
    }

    if (safeMoves.isNotEmpty) {
      int pick = safeMoves[Math.Random().nextInt(safeMoves.length)];
      addBall(pick ~/ cols, pick % cols);
    }
  }

  bool isDangerousMove(int row, int col) {
    final dirs = [
      const Offset(0, -1),
      const Offset(0, 1),
      const Offset(-1, 0),
      const Offset(1, 0),
    ];

    for (var d in dirs) {
      int r = row + d.dy.toInt();
      int c = col + d.dx.toInt();

      if (!isInside(r, c)) continue;

      final neighbor = cells[index(r, c)].value;

      if (neighbor.owner == 1 && neighbor.count == getLimit(r, c) - 1) {
        return true;
      }
    }

    return false;
  }
}

class CellWidget extends StatefulWidget {
  final Cell cell;
  final Color borderColor;
  final int limit;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.borderColor,
    required this.limit,
    required this.onTap,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.cell.count > 0) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  double getShakeIntensity(int count) {
    if (count == 1) return 0.5;
    if (count == 2) return 1.5;
    if (count == 3) return 3.0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: CustomPaint(
        painter: Box3DPainter(widget.borderColor),
        child: Center(
          child: widget.cell.count > 0
              ? AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final intensity = getShakeIntensity(widget.cell.count);
                    final angle = _controller.value * 2 * 3.1416;
                    return Transform.translate(
                      offset: Offset(
                        intensity * Math.sin(angle),
                        intensity * Math.cos(angle),
                      ),
                      child: Transform.rotate(
                        angle: widget.cell.count >= 3 ? angle : 0,
                        child: child,
                      ),
                    );
                  },
                  child: buildCluster(
                    widget.cell.count > widget.limit
                        ? widget.limit
                        : widget.cell.count,
                    widget.cell.color,
                    context,
                    limit: widget.limit,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

Widget buildCluster(
  int count,
  Color color,
  BuildContext context, {
  required int limit,
}) {
  double size = MediaQuery.of(context).size.width * 0.09;

  if (limit == 1 && count == 1) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.width * 0.1,
      child: BlastIcon(
        icon: "assets/image/icon2.png",
        size: MediaQuery.of(context).size.width * 0.1,
        color: color,
      ),
    );
  }

  if (limit == 2 && count == 1) {
    return SizedBox(
      width: size,
      height: size,
      child: BlastIcon(
        icon: "assets/image/icon1.png",
        size: size,
        color: color,
      ),
    );
  }

  if (limit == 2 && count == 2) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.width * 0.1,
      child: BlastIcon(
        icon: "assets/image/icon2.png",
        size: MediaQuery.of(context).size.width * 0.1,
        color: color,
      ),
    );
  }

  if (limit == 3 && count == 1) {
    return SizedBox(
      width: size,
      height: size,
      child: Ball3D(
        color: color,
        size: size * 0.07,
      ),
    );
  }

  String iconPath = (count == 2 || count == 4)
      ? "assets/image/icon1.png"
      : "assets/image/icon2.png";

  double iconSize;

  if (count == 2) {
    iconSize = size;
  } else {
    iconSize = MediaQuery.of(context).size.width * 0.1;
  }

  return SizedBox(
    width: iconSize,
    height: iconSize,
    child: BlastIcon(
      icon: iconPath,
      size: iconSize,
      color: color,
    ),
  );
}
