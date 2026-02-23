// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, use_full_hex_values_for_flutter_colors

import 'package:balloonblast/src/adds/ads_helper.dart';
import 'package:balloonblast/src/screen/computerPlayer.dart';
// import 'package:balloonblast/src/screen/roomScreen.dart';
// import 'package:balloonblast/src/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';
import 'gameScreen.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final String imgUrl;
  const PlayerSelectionScreen({super.key, required this.imgUrl});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int selectedPlayerCount = 2;

  final List<Color> defaultColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  List<Color?> selectedColors = [];

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    selectedColors =
        List.generate(selectedPlayerCount, (index) => defaultColors[index]);

    checkForUpdate();

    InterstitialAd.load(
      adUnitId: AdHelper.getInterstatialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {});
          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstatial ad: ${err.message}');
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(
      AssetImage(widget.imgUrl),
      context,
    );
  }

  Future<void> checkForUpdate() async {
    print('checking for Updated');
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          print('update available');
          update();
        }
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void update() async {
    print('Updating...');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
      print(e.toString());
    });
  }

  void updatePlayerCount(int count) {
    setState(() {
      selectedPlayerCount = count;
      selectedColors = List.generate(count, (index) => defaultColors[index]);
    });
  }

  void changePlayerColor(int playerIndex, Color newColor) {
    if (selectedColors.contains(newColor)) {
      final existingIndex = selectedColors.indexOf(newColor);
      if (existingIndex != playerIndex) {
        final temp = selectedColors[playerIndex];
        selectedColors[playerIndex] = newColor;
        selectedColors[existingIndex] = temp!;
        setState(() {});
        return;
      }
    }

    setState(() {
      selectedColors[playerIndex] = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4d91a4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.imgUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              frameBuilder: (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }

                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 0),
                  child: child,
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSinglePlayer(),
                    const SizedBox(height: 24),
                    _buildMultiPlayer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage: const AssetImage(
            "assets/logo/newlogo.jpg",
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Bubble Reaction',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget glassButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePlayer() {
    return glassButton(
      title: "Single Player",
      subtitle: "Play with Computer",
      icon: Icons.smart_toy,
      onTap: () async {
        _interstitialAd?.show();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ComputerPlayer()),
        );
      },
    );
  }

  Widget _buildMultiPlayer() {
    return Column(
      children: [
        glassButton(
          title: "Local Multiplayer",
          subtitle: "Play on same device",
          icon: Icons.groups,
          onTap: () {
            _showMultiPlayerBottomSheet();
          },
        ),
        const SizedBox(height: 16),
        glassButton(
          title: "Play with Friend",
          subtitle: "Online (Coming Soon)",
          icon: Icons.public,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Coming Soon")),
            );

            // _interstitialAd?.show();

            // await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => RoomScreen(
            //       playerCount: selectedPlayerCount,
            //       playerSelectColors: selectedColors,
            //     ),
            //   ),
            // );

            // String playerId =
            //     DateTime.now().millisecondsSinceEpoch.toString();

            // String roomId = await RoomService().createRoom(
            //   playerId: playerId,
            //   maxPlayers: 2,
            // );

            // print("ROOM CREATED: $roomId");
          },
        ),
      ],
    );
  }

  void _showMultiPlayerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Text(
                      "Local Multiplayer Setup",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          "Select Player:",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 14),
                        DropdownButton<int>(
                          value: selectedPlayerCount,
                          items: List.generate(
                            7,
                            (index) => DropdownMenuItem(
                              value: index + 2,
                              child: Text("${index + 2} Players"),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                updatePlayerCount(value);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedPlayerCount,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text("Player ${index + 1}"),
                            trailing: DropdownButton2<Color>(
                              value: selectedColors[index],
                              customButton: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: selectedColors[index],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black26),
                                ),
                              ),
                              items: defaultColors
                                  .take(selectedPlayerCount)
                                  .map(
                                    (color) => DropdownMenuItem<Color>(
                                      value: color,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.black26),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (color) {
                                if (color != null) {
                                  setModalState(() {
                                    changePlayerColor(index, color);
                                  });
                                }
                              },
                              buttonStyleData: const ButtonStyleData(width: 50),
                              dropdownStyleData: DropdownStyleData(
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          _interstitialAd?.show();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChainReactionGame(
                                playerCount: selectedPlayerCount,
                                playerSelectColors: selectedColors,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "PLAY",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
