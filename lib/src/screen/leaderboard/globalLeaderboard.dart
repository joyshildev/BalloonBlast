// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalLeaderboard extends StatefulWidget {
  const GlobalLeaderboard({super.key});

  @override
  State<GlobalLeaderboard> createState() => _GlobalLeaderboardState();
}

class _GlobalLeaderboardState extends State<GlobalLeaderboard> {
  String myName = "";

  @override
  void initState() {
    super.initState();
    loadMyName();
  }

  loadMyName() async {
    final prefs = await SharedPreferences.getInstance();

    myName = prefs.getString("player_name") ?? "";

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff0f172a),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Leaderboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("leaderboard")
            .orderBy("score", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) return Container();

          int myIndex = data.indexWhere((doc) => doc["name"] == myName);

          List listData = data.length > 3 ? data.sublist(3) : [];

          if (myIndex > 2) {
            final myDoc = data[myIndex];

            listData.removeWhere((e) => e["name"] == myName);

            listData.insert(0, myDoc);
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  podium(data[1], 2, 110, 180, data[1]["name"] == myName),
                  podium(data[0], 1, 130, 210, data[0]["name"] == myName),
                  podium(data[2], 3, 110, 180, data[2]["name"] == myName),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: listData.length,
                  itemBuilder: (context, index) {
                    final doc = listData[index];
                    final rank = data.indexOf(doc) + 1;
                    final isMe = doc["name"] == myName;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color.fromARGB(255, 192, 145, 3)
                            : const Color(0xff1e293b),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Text(
                              rank.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              doc["name"][0].toUpperCase() +
                                  doc["name"].substring(1) +
                                  (isMe ? " (You)" : ""),
                              style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            doc["score"].toString(),
                            style: TextStyle(
                              color: isMe ? Colors.black : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget podium(doc, int rank, double width, double height, bool isMe) {
    Color crownColor;

    if (rank == 1) {
      crownColor = Colors.amber;
    } else if (rank == 2) {
      crownColor = Colors.grey;
    } else {
      crownColor = const Color.fromARGB(255, 164, 44, 0);
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: rank == 1
              ? [
                  const Color.fromARGB(255, 31, 49, 91),
                  const Color(0xff92400e),
                ]
              : rank == 2
                  ? [
                      const Color.fromARGB(255, 31, 49, 91),
                      const Color(0xff1e3a8a),
                    ]
                  : [
                      const Color.fromARGB(255, 31, 49, 91),
                      const Color(0xff881337),
                    ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              text: "$rank",
              style: TextStyle(
                color: crownColor,
                fontWeight: FontWeight.bold,
                fontSize: rank == 1
                    ? 26
                    : rank == 2
                        ? 24
                        : 20,
              ),
              children: [
                TextSpan(
                  text: rank == 1
                      ? "st"
                      : rank == 2
                          ? "nd"
                          : "rd",
                  style: TextStyle(
                    color: crownColor,
                    fontWeight: FontWeight.bold,
                    fontSize: rank == 1
                        ? 22
                        : rank == 2
                            ? 20
                            : 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: rank == 1
                ? 80
                : rank == 2
                    ? 70
                    : 60,
            width: rank == 1
                ? 80
                : rank == 2
                    ? 70
                    : 60,
            child: Lottie.asset(
              rank == 1
                  ? "assets/json/trophy.json"
                  : rank == 2
                      ? "assets/json/silver-medal.json"
                      : "assets/json/bronze-medal.json",
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            doc["name"][0].toUpperCase() +
                doc["name"].substring(1) +
                (isMe ? " (You)" : ""),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            doc["score"].toString(),
            style: const TextStyle(
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }
}
