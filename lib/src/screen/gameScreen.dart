// ignore_for_file: avoid_print, unused_field

import 'dart:math' as Math;

import 'package:audioplayers/audioplayers.dart';
import 'package:balloonblast/src/adds/ads_helper.dart';
import 'package:balloonblast/src/screen/ball3D.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  final int rows = 10;
  final int cols = 6;

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

  @override
  void initState() {
    super.initState();

    playerColors = {
      for (int i = 1; i <= widget.playerCount; i++)
        i: widget.playerSelectColors[i - 1]!,
    };

    resetBoard();

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

    List<int> validMoves = [];

    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i].value;

      if (cell.count == 0 || cell.owner == 2) {
        validMoves.add(i);
      }
    }

    if (validMoves.isNotEmpty) {
      final randomIndex = validMoves[Math.Random().nextInt(validMoves.length)];

      final row = randomIndex ~/ cols;
      final col = randomIndex % cols;

      addBall(row, col);
    }
  }

  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer % widget.playerCount + 1;
      print('Switched to Player $currentPlayer');
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

    if (activePlayers.length > 1 && owners.length == 1 && owners.first != 0) {
      gameOver = true;

      Future.delayed(const Duration(milliseconds: 300), () {
        _showAd();
        if (mounted) showWinnerDialog(owners.first);
      });
    }
  }

  void showWinnerDialog(int player) {
    final playerColor = playerColors[player]!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 We Have a Winner!'),
        content: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: playerColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: Text('Player $player wins!')),
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

  Widget buildCell(int row, int col) {
    final i = index(row, col);
    final limit = getLimit(row, col);

    return ValueListenableBuilder<Cell>(
      valueListenable: cells[i],
      builder: (_, cell, __) => CellWidget(
        cell: cell,
        borderColor: playerColors[currentPlayer]!,
        limit: limit,
        onTap: () {
          if (widget.isComputerMode && currentPlayer == 2) return;
          addBall(row, col);
        },
      ),
    );
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
        title: const Text(
          'Bubble Reaction',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                cacheExtent: 1000,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, i) => buildCell(i ~/ cols, i % cols),
              ),
            ),
          ),
          if (_bottomBannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: _bottomBannerAd!.size.width.toDouble(),
                height: _bottomBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bottomBannerAd!),
              ),
            ),
        ],
      ),
    );
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: widget.borderColor, width: 1),
          color: const Color.fromARGB(31, 190, 188, 188),
        ),
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
                        angle: widget.cell.count >= 4 ? angle : 0,
                        child: child,
                      ),
                    );
                  },
                  child: buildCluster(
                    widget.cell.count > widget.limit
                        ? widget.limit
                        : widget.cell.count,
                    widget.cell.color,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

Widget buildCluster(int count, Color color) {
  const double size = 22;

  if (count == 1) {
    return Ball3D(color: color, size: size);
  }

  if (count == 2) {
    return SizedBox(
      width: 48,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 6,
            child: Ball3D(color: color, size: size),
          ),
          Positioned(
            right: 6,
            child: Ball3D(color: color, size: size),
          ),
        ],
      ),
    );
  }

  if (count == 3) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 4,
            left: 4,
            child: Ball3D(color: color, size: size),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Ball3D(color: color, size: size),
          ),
          Positioned(
            top: 4,
            child: Ball3D(color: color, size: size),
          ),
        ],
      ),
    );
  }

  return SizedBox(
    width: 55,
    height: 55,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          child: Ball3D(color: color, size: size),
        ),
        Positioned(
          bottom: 0,
          child: Ball3D(color: color, size: size),
        ),
        Positioned(
          left: 0,
          child: Ball3D(color: color, size: size),
        ),
        Positioned(
          right: 0,
          child: Ball3D(color: color, size: size),
        ),
      ],
    ),
  );
}
