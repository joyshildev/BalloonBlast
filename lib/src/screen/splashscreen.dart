// ignore_for_file: use_super_parameters

import 'package:balloonblast/src/screen/selectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoMoveUp;
  late Animation<Offset> _bankSlide;
  late Animation<double> _bankFade;
  late Animation<Offset> _indieSlide;
  late Animation<double> _indieFade;
  String imgUrl = 'assets/image/bg_img.jpg';

  int _playCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _playCount++;
        if (_playCount < 1) {
          _controller.reset();
          _controller.forward();
        } else {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerSelectionScreen(imgUrl: imgUrl),
                ),
              );
            }
          });
        }
      }
    });

    _logoMoveUp = Tween<double>(begin: 0, end: -40).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    _bankSlide =
        Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    _bankFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5),
      ),
    );

    _indieSlide =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _indieFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, _logoMoveUp.value),
                  child: Image.asset('assets/logo/chainFinal.png', width: 200),
                ),
                Opacity(
                  opacity: _bankFade.value,
                  child: SlideTransition(
                    position: _bankSlide,
                    child: const Text(
                      'Bubble',
                      style: TextStyle(
                        color: Color(0xFF800000),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: _indieFade.value,
                  child: SlideTransition(
                    position: _indieSlide,
                    child: const Text(
                      'Reaction',
                      style: TextStyle(
                        color: Color(0xFF800000),
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
