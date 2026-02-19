// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

class BnRuleScreen extends StatelessWidget {
  const BnRuleScreen({super.key});

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
            "কিভাবে খেলবেন",
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "সবার জন্য সহজ নিয়ম 🎮",
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
            "জেতার নিয়ম",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "আপনি জিতবেন যখন:\n\n"
            "• সব বক্স আপনার রঙ হয়ে যাবে\n"
            "• অন্য সব প্লেয়ারের বল শেষ হয়ে যাবে\n"
            "• শুধু আপনি বেঁচে থাকবেন\n\n"
            "শেষে যে প্লেয়ার বেঁচে থাকবে,\n"
            "সে হবে বিজয়ী 🏆",
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
                  "বল যোগ করুন",
                  "যেকোনো খালি বক্সে ট্যাপ করুন।\n"
                      "আপনার বল সেই বক্সে যোগ হবে।\n"
                      "বক্সটি আপনার রঙ হয়ে যাবে।\n"
                      "আপনি সরাসরি শত্রুর বক্সে ট্যাপ করতে পারবেন না।",
                  Icons.touch_app,
                  Colors.blue,
                ),
                ruleCard(
                  "কোণার বক্স নিয়ম",
                  "কোণার বক্স সবচেয়ে দুর্বল।\n"
                      "এতে ১টি বল নিরাপদ থাকে।\n"
                      "২য় বল দিলে ব্লাস্ট হবে।\n"
                      "ব্লাস্ট হলে পাশের বক্সে বল ছড়িয়ে যাবে।",
                  Icons.crop_square,
                  Colors.red,
                ),
                ruleCard(
                  "পাশের বক্স নিয়ম",
                  "পাশের বক্স একটু শক্তিশালী।\n"
                      "এতে ২টি বল নিরাপদ থাকে।\n"
                      "৩য় বল দিলে ব্লাস্ট হবে।\n"
                      "ব্লাস্ট হলে ৩ দিকে বল যাবে।",
                  Icons.border_outer,
                  Colors.green,
                ),
                ruleCard(
                  "মাঝের বক্স নিয়ম",
                  "মাঝের বক্স সবচেয়ে শক্তিশালী।\n"
                      "এতে ৩টি বল নিরাপদ থাকে।\n"
                      "৪র্থ বল দিলে বড় ব্লাস্ট হবে।\n"
                      "ব্লাস্ট হলে চারদিকে বল ছড়াবে।",
                  Icons.grid_on,
                  Colors.purple,
                ),
                ruleCard(
                  "বন্ধুর বক্স দখল করুন",
                  "ব্লাস্ট হলে বন্ধুর বক্স আপনার হয়ে যাবে।\n"
                      "বন্ধুর বল আপনার রঙে পরিবর্তন হবে।\n"
                      "এভাবে আপনি পুরো বোর্ড দখল করতে পারবেন।\n"
                      "এটি আপনাকে জিততে সাহায্য করবে।",
                  Icons.bolt,
                  Colors.orange,
                ),
                ruleCard(
                  "প্লেয়ার বাদ পড়বে",
                  "যখন কোনো প্লেয়ারের সব বল শেষ হয়ে যাবে,\n"
                      "সে প্লেয়ার বাদ পড়বে।\n"
                      "সে আর খেলতে পারবে না।",
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
