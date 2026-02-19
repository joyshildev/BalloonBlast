// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

class HindiRuleScreen extends StatelessWidget {
  const HindiRuleScreen({super.key});

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
            "कैसे खेलें",
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "आसान नियम सभी के लिए 🎮",
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
            "मैच जीतने के नियम",
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Text(
            "आप जीतते हैं जब:\n\n"
            "• सभी बॉक्स आपके रंग के हो जाएं\n"
            "• दुश्मन के सभी बॉल खत्म हो जाएं\n"
            "• बाकी सभी खिलाड़ी हार जाएं\n\n"
            "आखिरी बचा हुआ खिलाड़ी विजेता होता है 🏆",
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
                  "बॉल जोड़ें",
                  "किसी खाली बॉक्स पर टैप करें।\n"
                      "आपका बॉल उस बॉक्स में आ जाएगा।\n"
                      "वह बॉक्स आपका हो जाएगा।\n"
                      "आप दुश्मन के बॉक्स पर सीधे टैप नहीं कर सकते।",
                  Icons.touch_app,
                  Colors.blue,
                ),
                ruleCard(
                  "कोने का बॉक्स",
                  "कोने का बॉक्स कमजोर होता है।\n"
                      "इसमें केवल 1 बॉल सुरक्षित रहता है।\n"
                      "दूसरा बॉल डालने पर ब्लास्ट होता है।\n"
                      "ब्लास्ट से बॉल आसपास फैलते हैं।",
                  Icons.crop_square,
                  Colors.red,
                ),
                ruleCard(
                  "किनारे का बॉक्स",
                  "किनारे का बॉक्स थोड़ा मजबूत होता है।\n"
                      "इसमें 2 बॉल सुरक्षित रहते हैं।\n"
                      "तीसरा बॉल डालने पर ब्लास्ट होता है।\n"
                      "ब्लास्ट से बॉल 3 दिशा में जाते हैं।",
                  Icons.border_outer,
                  Colors.green,
                ),
                ruleCard(
                  "बीच का बॉक्स",
                  "बीच का बॉक्स सबसे मजबूत होता है।\n"
                      "इसमें 3 बॉल सुरक्षित रहते हैं।\n"
                      "चौथा बॉल डालने पर ब्लास्ट होता है।\n"
                      "ब्लास्ट से बॉल चारों तरफ जाते हैं।",
                  Icons.grid_on,
                  Colors.purple,
                ),
                ruleCard(
                  "दुश्मन बॉक्स कब्जा करें",
                  "ब्लास्ट से दुश्मन का बॉक्स आपका बन सकता है।\n"
                      "उनका रंग बदलकर आपका हो जाता है।\n"
                      "इससे आप गेम जीत सकते हैं।",
                  Icons.bolt,
                  Colors.orange,
                ),
                ruleCard(
                  "खिलाड़ी हार जाता है",
                  "जब किसी खिलाड़ी के सभी बॉल खत्म हो जाते हैं,\n"
                      "वह खिलाड़ी गेम से बाहर हो जाता है।\n"
                      "वह फिर खेल नहीं सकता।",
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
