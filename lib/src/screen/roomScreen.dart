// ignore_for_file: file_names, avoid_print, depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:balloonblast/src/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class RoomScreen extends StatefulWidget {
  final int playerCount;
  final List<Color?> playerSelectColors;

  const RoomScreen({
    super.key,
    required this.playerCount,
    required this.playerSelectColors,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  String? roomId;

  String playerId = const Uuid().v4();

  final RoomService roomService = RoomService();

  void createRoom() async {
    String id = await roomService.createRoom(
      playerId: playerId,
      maxPlayers: widget.playerCount,
    );

    setState(() {
      roomId = id;
    });
  }

  void joinRoom() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Enter Room ID"),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                roomId = controller.text;

                await roomService.joinRoom(
                  roomId: roomId!,
                  playerId: playerId,
                );

                setState(() {});

                Navigator.pop(context);
              },
              child: const Text("Join"),
            )
          ],
        );
      },
    );
  }

  Future<void> shareRoom() async {
    String packageName = "com.balloonblastmy.balloonblast";

    String link =
        "https://play.google.com/store/apps/details?id=$packageName&referrer=$roomId";

    final byteData = await rootBundle.load('assets/logo/chainFinal.png');
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/bubble_reaction_logo.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "🎈 Bubble Reaction – Multiplayer Strategy Game\n\n"
          "🔥 Challenge your friends in a thrilling chain reaction battle\n"
          "🎮 Join my room and start playing now!\n\n"
          "🆔 Room ID: $roomId\n\n"
          "$link",
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
          "Friends",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: buildButton(
                    "Create Room",
                    Icons.add,
                    createRoom,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildButton(
                    "Join Room",
                    Icons.login,
                    joinRoom,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (roomId != null)
              Expanded(
                child: StreamBuilder(
                  stream: roomService.listenRoom(roomId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    var data = snapshot.data!;
                    List players = data["players"];
                    return buildRoomUI(players);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomUI(List players) {
    bool allJoined = players.length == widget.playerCount;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Room ID: ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: roomId,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: shareRoom,
                icon: const Icon(Icons.share, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            itemCount: widget.playerCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemBuilder: (_, index) {
              bool joined = index < players.length;
              return Container(
                decoration: BoxDecoration(
                  color: joined
                      ? widget.playerSelectColors[index]?.withOpacity(0.8)
                      : const Color.fromARGB(108, 209, 186, 186),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: joined
                      ? Text(
                          "Player ${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        )
                      : const Text(
                          "Connecting...",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: allJoined
                ? () {
                    print("Game Started");
                  }
                : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: allJoined ? 1 : 0.5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: allJoined
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 86, 89, 249),
                            Color.fromARGB(255, 89, 23, 221),
                          ],
                        )
                      : const LinearGradient(
                          colors: [
                            Colors.grey,
                            Colors.grey,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "START GAME",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xffFF512F),
              Color(0xffDD2476),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
