// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:balloonblast/src/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/screen/selectionScreen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background FCM: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RequestConfiguration configuration = RequestConfiguration(
    tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
  );
  MobileAds.instance.updateRequestConfiguration(configuration);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  await FCMService.initializeFCM();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) => 'Bubble Reaction',
      home: const PlayerSelectionScreen(),
    );
  }
}
