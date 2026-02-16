import 'package:flutter/material.dart';
import 'screen/selectionScreen.dart';

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
