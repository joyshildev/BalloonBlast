// ignore_for_file: file_names

import 'package:flutter/material.dart';

class WithdrawTermsSheet extends StatelessWidget {
  const WithdrawTermsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xff0f172a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 15),
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      "Withdrawal Terms & Conditions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TermsText(
                    "1. Minimum Withdrawal Requirement",
                    "Users must have a minimum available balance of ₹10,000 "
                        "in their Bubble Reaction wallet to request a withdrawal. "
                        "Withdrawal requests below this amount will not be processed.",
                  ),
                  TermsText(
                    "2. Withdrawal Methods",
                    "Once eligible, users can transfer their winnings via:\n"
                        "• Bank Transfer (NEFT / IMPS / UPI)\n"
                        "• Digital Wallets (Paytm, PhonePe, Google Pay, etc.)",
                  ),
                  TermsText(
                    "3. Verification Requirement",
                    "Users must complete account verification including valid "
                        "bank details and identity verification before withdrawal.",
                  ),
                  TermsText(
                    "4. Processing Time",
                    "Withdrawal requests are processed within 1–5 business days. "
                        "Delays may occur due to bank or technical issues.",
                  ),
                  TermsText(
                    "5. Fair Play Policy",
                    "Any fraudulent activity, cheating, hacking, or misuse "
                        "will result in permanent suspension and forfeiture of balance.",
                  ),
                  TermsText(
                    "6. Game Earnings",
                    "Rewards are earned through gameplay, achievements, events, "
                        "and promotional activities organized by Bubble Reaction.",
                  ),
                  TermsText(
                    "7. Modification Rights",
                    "Bubble Reaction reserves the right to modify withdrawal terms "
                        "at any time without prior notice.",
                  ),
                  TermsText(
                    "8. Acceptance",
                    "By using Bubble Reaction, you agree to all withdrawal terms "
                        "and conditions mentioned above.",
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 29, 44, 79),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.lock,
                color: Colors.grey,
              ),
              label: const Text(
                "Withdraw Locked",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TermsText extends StatelessWidget {
  final String title;
  final String body;

  const TermsText(this.title, this.body, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
