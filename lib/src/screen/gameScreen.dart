// ignore_for_file: avoid_print, unused_field

import 'package:balloonblast/src/adds/ads_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../model/cellModel.dart';

class ChainReactionGame extends StatefulWidget {
  final int playerCount;
  final List<Color?> playerSelectColors;

  const ChainReactionGame({
    super.key,
    required this.playerCount,
    required this.playerSelectColors,
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

  @override
  void initState() {
    super.initState();

    playerColors = {
      for (int i = 1; i <= widget.playerCount; i++)
        i: widget.playerSelectColors[i - 1]!,
    };

    resetBoard();

    // Bottom Banner
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
              _loadAd(); // Load the next ad
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
      pendingExplosions++;
      waitingForExplosion = true;

      Future.delayed(const Duration(milliseconds: 250), () async {
        await explode(row, col, thisPlayer);
        pendingExplosions--;

        if (pendingExplosions == 0) {
          waitingForExplosion = false;
          checkWinner();
          if (!gameOver) {
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

  Future<void> explode(int row, int col, int player) async {
    if (gameOver) return;

    final i = index(row, col);
    cells[i].value = Cell(); // Clear this cell

    final directions = [
      const Offset(0, -1),
      const Offset(0, 1),
      const Offset(-1, 0),
      const Offset(1, 0),
    ];

    for (var dir in directions) {
      await Future.delayed(const Duration(milliseconds: 50));
      final newRow = row + dir.dy.toInt();
      final newCol = col + dir.dx.toInt();
      if (isInside(newRow, newCol)) {
        addBall(newRow, newCol, player);
      }
    }
  }

  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer % widget.playerCount + 1;
      print('Switched to Player $currentPlayer');
    });
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
        onTap: () => addBall(row, col),
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, i) => buildCell(i ~/ cols, i % cols),
              ),
            ),
          ),

          // Bottom banner
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

      //   SafeArea(
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: GridView.builder(
      //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //           crossAxisCount: cols,
      //         ),
      //         itemCount: rows * cols,
      //         itemBuilder: (context, i) => buildCell(i ~/ cols, i % cols),
      //       ),
      //     ),
      //   ),
    );
  }
}

class CellWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          color: const Color.fromARGB(31, 190, 188, 188),
        ),
        child: Center(
          child: cell.count > 0
              ? Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(
                    cell.count > limit ? limit : cell.count,
                    (_) => Icon(
                      Icons.circle,
                      color: cell.color,
                      size: 20,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
