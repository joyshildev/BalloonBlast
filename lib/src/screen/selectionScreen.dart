// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously, use_full_hex_values_for_flutter_colors

import 'package:balloonblast/src/screen/computerPlayer.dart';
import 'package:balloonblast/src/screen/leaderboard/profileScreen.dart';
import 'package:balloonblast/src/screen/leaderboard/withdrawTermsSheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:balloonblast/src/screen/roomScreen.dart';
// import 'package:balloonblast/src/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gameScreen.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final String imgUrl;
  const PlayerSelectionScreen({super.key, required this.imgUrl});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int selectedPlayerCount = 2;
  String playerName = "";

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

  @override
  void initState() {
    super.initState();

    selectedColors =
        List.generate(selectedPlayerCount, (index) => defaultColors[index]);

    checkForUpdate();

    loadPlayerName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(
      AssetImage(widget.imgUrl),
      context,
    );
  }

  Future<void> loadPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString("player_name") ?? "";

    if (savedName.isEmpty) {
      askPlayerName();
    } else {
      setState(() {
        playerName = savedName;
      });
    }
  }

  Future<void> askPlayerName() async {
    TextEditingController controller = TextEditingController();
    TextEditingController controllerAge = TextEditingController();

    bool isLogin = false;
    bool isChecking = false;
    bool isAvailable = false;

    await showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    /// Premium Gradient
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff0f172a),
                        Color(0xff1e293b),
                        Color(0xff020617),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    borderRadius: BorderRadius.circular(30),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.6),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Skip",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateDialog(() {
                                      isLogin = false;
                                      controller.clear();
                                      isAvailable = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !isLogin
                                          ? Colors.orange
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setStateDialog(() {
                                      isLogin = true;
                                      controller.clear();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isLogin
                                          ? Colors.orange
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Username",
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.orange,
                            ),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) async {
                            String docId = value.trim().toLowerCase();

                            if (!isLogin && docId.length >= 6) {
                              setStateDialog(() {
                                isChecking = true;
                              });

                              var doc = await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(docId)
                                  .get();

                              setStateDialog(() {
                                isChecking = false;

                                isAvailable = !doc.exists;
                              });
                            }

                            setStateDialog(() {});
                          },
                        ),
                        const SizedBox(height: 10),
                        if (!isLogin)
                          TextField(
                            controller: controllerAge,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Age (optional)",
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(
                                Icons.cake,
                                color: Colors.orange,
                              ),
                              filled: true,
                              fillColor: Colors.black26,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        if (!isLogin && controller.text.trim().length >= 6)
                          isChecking
                              ? const CircularProgressIndicator()
                              : Text(
                                  isAvailable
                                      ? "Username available"
                                      : "Username already taken",
                                  style: TextStyle(
                                    color:
                                        isAvailable ? Colors.green : Colors.red,
                                  ),
                                ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () async {
                              String displayName = controller.text.trim();
                              String docId = displayName.toLowerCase();

                              if (displayName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Username cannot be empty"),
                                    backgroundColor: Colors.red,
                                  ),
                                );

                                return;
                              }

                              if (displayName.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Minimum 6 characters required"),
                                    backgroundColor: Colors.red,
                                  ),
                                );

                                return;
                              }

                              if (isLogin) {
                                var doc = await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(docId)
                                    .get();

                                if (!doc.exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Login failed"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );

                                  return;
                                }

                                final prefs =
                                    await SharedPreferences.getInstance();

                                await prefs.setString(
                                    "player_name", displayName);

                                playerName = displayName;

                                Navigator.pop(context);

                                setState(() {});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Welcome back $displayName"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                var doc = await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(docId)
                                    .get();

                                if (doc.exists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Username already taken"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );

                                  return;
                                }

                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(docId)
                                    .set({
                                  "name": displayName,
                                  "xp": 0,
                                  "level": 1,
                                  "createdAt": FieldValue.serverTimestamp(),
                                });

                                final prefs =
                                    await SharedPreferences.getInstance();

                                await prefs.setString(
                                    "player_name", displayName);

                                playerName = displayName;

                                Navigator.pop(context);

                                setState(() {});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Account created $displayName"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              isLogin ? "Login" : "Create Account",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
      backgroundColor: const Color(0xff0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f172a),
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 16,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const WithdrawTermsSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 17, 55, 125)
                                .withOpacity(0.25),
                            const Color.fromARGB(255, 35, 97, 172)
                                .withOpacity(0.05),
                          ],
                        ),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.wallet,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'WITHDRAW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (playerName.isEmpty) {
                        loadPlayerName();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 17, 55, 125)
                                .withOpacity(0.25),
                            const Color.fromARGB(255, 35, 97, 172)
                                .withOpacity(0.05),
                          ],
                        ),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
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
                          const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            playerName.isEmpty ? "SIGN IN" : playerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSinglePlayer(),
              const SizedBox(height: 24),
              _buildMultiPlayer(),
            ],
          ),
        ),
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
              const Color.fromARGB(255, 17, 55, 125).withOpacity(0.25),
              const Color.fromARGB(255, 35, 97, 172).withOpacity(0.05),
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
      onTap: () {
        Navigator.push(
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
                  color: const Color(0xff0f172a),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          "Select Player:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        DropdownButton<int>(
                          value: selectedPlayerCount,
                          dropdownColor: const Color(0xff020617),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          items: List.generate(
                            7,
                            (i) => DropdownMenuItem(
                              value: i + 2,
                              child: Text("${i + 2} Players"),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                updatePlayerCount(value);
                              });
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedPlayerCount,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              playerName.isNotEmpty
                                  ? (index == 0
                                      ? "${playerName[0].toUpperCase()}${playerName.substring(1)} (You)"
                                      : "Player $index")
                                  : "Player ${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
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
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
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
