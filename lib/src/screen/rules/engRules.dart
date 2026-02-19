// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

class EngRuleScreen extends StatelessWidget {
  const EngRuleScreen({super.key});

  Widget header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1565C0), Color(0xff42A5F5)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.sports_esports, size: 60, color: Colors.white),
          SizedBox(height: 10),
          Text(
            "How to Play",
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Easy Rules for Everyone 🎮",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }

  Widget ruleCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$title\n\n",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: desc,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget winCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.emoji_events, color: Colors.white, size: 55),
          SizedBox(height: 10),
          Text(
            "Match Win Rules",
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Text(
            "You WIN the game when:\n\n"
            "• All boxes become your color\n"
            "• All enemy balls are destroyed\n"
            "• Enemy players have ZERO balls\n\n"
            "When only one player remains alive,\n"
            "that player becomes the WINNER 🏆",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 16, 125, 214),
        title: const Text(
          'Bubble Reaction',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          header(),
          Expanded(
            child: ListView(
              children: [
                ruleCard(
                  "Add Ball",
                  "Tap on any empty box to place your ball.\n"
                      "That box becomes your color.\n"
                      "You can also tap your own boxes to increase balls.\n"
                      "You cannot tap enemy boxes directly.",
                  Icons.touch_app,
                  Colors.blue,
                ),
                ruleCard(
                  "Corner Box Rule",
                  "Corner box is weakest.\n"
                      "It can hold only 1 ball safely.\n"
                      "When you add the 2nd ball, it explodes.\n"
                      "Explosion sends balls to nearby boxes.",
                  Icons.crop_square,
                  Colors.red,
                ),
                ruleCard(
                  "Edge Box Rule",
                  "Edge box is stronger than corner.\n"
                      "It can hold 2 balls safely.\n"
                      "When you add the 3rd ball, it explodes.\n"
                      "Explosion spreads balls in 3 directions.",
                  Icons.border_outer,
                  Colors.green,
                ),
                ruleCard(
                  "Middle Box Rule",
                  "Middle box is strongest.\n"
                      "It can hold 3 balls safely.\n"
                      "When the 4th ball comes, it explodes.\n"
                      "Explosion spreads balls in all directions.",
                  Icons.grid_on,
                  Colors.purple,
                ),
                ruleCard(
                  "Capture Enemy Box",
                  "Explosion can capture enemy boxes.\n"
                      "Enemy balls change into your color.\n"
                      "You can take over their boxes.\n"
                      "This helps you win the game faster.",
                  Icons.bolt,
                  Colors.orange,
                ),
                ruleCard(
                  "Player Elimination",
                  "If a player loses all balls,\n"
                      "that player is eliminated.\n"
                      "They cannot play again.\n"
                      "Game continues with remaining players.",
                  Icons.person_off,
                  Colors.black,
                ),
                winCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
