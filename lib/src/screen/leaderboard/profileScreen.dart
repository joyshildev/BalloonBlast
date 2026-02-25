// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:balloonblast/src/screen/leaderboard/globalLeaderboard.dart';
import 'package:balloonblast/src/screen/leaderboard/transHistory.dart';
import 'package:balloonblast/src/screen/selectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum MilestoneState { completed, current, locked }

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  int xp = 0;
  int level = 1;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString("player_name") ?? "";

    if (name.isEmpty) return;

    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(name.toLowerCase())
        .get();

    if (doc.exists) {
      xp = doc["xp"] ?? 0;
      level = calculateLevel(xp);
      setState(() {});
    }
  }

  int calculateLevel(int xp) {
    int lvl = 1;
    int requiredXP = 10;

    while (xp >= requiredXP && lvl < 200) {
      xp -= requiredXP;
      lvl++;
      requiredXP += 10;
    }
    return lvl;
  }

  int getNextLevelXP() {
    int requiredXP = 10;
    for (int i = 1; i < level; i++) {
      requiredXP += 10;
    }
    return requiredXP;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerSelectionScreen(
          imgUrl: 'assets/image/bg_img.jpg',
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    int nextXp = getNextLevelXP();
    double progress = (xp % nextXp) / nextXp;

    return Scaffold(
      backgroundColor: const Color(0xff0f172a),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f172a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff1e293b),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  buildXpCircle(progress),
                  const SizedBox(height: 10),
                  Text(
                    "Level $level",
                    style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("$xp XP Total",
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: const Color.fromARGB(255, 61, 79, 109),
                      valueColor: const AlwaysStoppedAnimation(
                        Color.fromARGB(255, 207, 156, 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${xp % nextXp} / $nextXp XP",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Milestones",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildLevelMilestones(
                    level: level,
                    xp: xp,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xff111827),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: Icon(Icons.leaderboard,
                    color: Colors.white.withOpacity(0.8)),
                title: const Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GlobalLeaderboard(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xff111827),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: Icon(Icons.wallet_outlined,
                    color: Colors.white.withOpacity(0.8)),
                title: Text.rich(
                  TextSpan(
                    text: 'Coins ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: xp.toString(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TranscationHistory(coins: xp),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xff111827),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red.withOpacity(0.8)),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.red.withOpacity(0.8),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xff1e293b),
                      title: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        "Are you sure you want to logout?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await logout();
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildXpCircle(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: const Color.fromARGB(255, 61, 79, 109),
            valueColor: const AlwaysStoppedAnimation(
              Color.fromARGB(255, 207, 156, 16),
            ),
          ),
        ),
        const Icon(
          Icons.person_outline,
          size: 50,
          color: Color.fromARGB(255, 207, 156, 16),
        ),
      ],
    );
  }

  Widget buildLevelMilestones({
    required int level,
    required int xp,
  }) {
    List<Widget> cards = [];
    int getLevelXP(int lvl) {
      int requiredXP = 10;
      for (int i = 1; i < lvl; i++) {
        requiredXP += 10;
      }
      return requiredXP;
    }

    if (level > 1) {
      int completedLevelXp = getLevelXP(level - 1);

      cards.add(buildLevelCard(
        label: "Completed",
        value: completedLevelXp,
        target: completedLevelXp,
        state: MilestoneState.completed,
      ));
    }

    int upcoming = level + 1;
    while (cards.length < 2) {
      int upcomingTarget = getLevelXP(upcoming);

      cards.add(buildLevelCard(
        label: "Upcoming",
        value: 0,
        target: upcomingTarget,
        state: MilestoneState.locked,
      ));
      upcoming++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...cards,
      ],
    );
  }

  Widget buildLevelCard({
    required String label,
    required int value,
    required int target,
    required MilestoneState state,
  }) {
    Color color;
    IconData icon;

    switch (state) {
      case MilestoneState.completed:
        color = Colors.lightGreenAccent;
        icon = Icons.check_circle;
        break;
      case MilestoneState.current:
        color = const Color.fromARGB(255, 207, 156, 16);
        icon = Icons.backpack;
        break;
      case MilestoneState.locked:
        color = Colors.grey;
        icon = Icons.lock;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: state == MilestoneState.locked
                        ? Colors.white38
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "$value / $target",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (value / target).clamp(0, 1),
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
