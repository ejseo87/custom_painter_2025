import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PomodorScreen extends StatefulWidget {
  const PomodorScreen({super.key});

  @override
  State<PomodorScreen> createState() => _PomodorScreenState();
}

class _PomodorScreenState extends State<PomodorScreen>
    with TickerProviderStateMixin {
  final _bgColor = Color(0xFF043953);
  final _inactvieColor = Color(0xFFEEEEEE);
  final _primaryColor = Color(0xFFFE676B);

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 100,
  );
  static const List<int> timerSet = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
  int _selectedIdex = 4;
  late int _timerSettingValue = timerSet[_selectedIdex] * 60;

  void _onTimeCardTap(int index) {
    setState(() {
      _selectedIdex = index;
      _timerSettingValue = timerSet[index] * 60;
      _progressController.duration = Duration(seconds: _timerSettingValue);
      _progressController.reset();

      _playPauseController.reset();
    });
  }

  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: Duration(seconds: _timerSettingValue),
    lowerBound: 0.0,
    upperBound: 2.0,
  );

  // for play button. It is a toggle button betweenn play and pause
  late final AnimationController _playPauseController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 500),
  );

  void _onPlayPauseTap() {
    if (_playPauseController.isCompleted) {
      _playPauseController.reverse();
      _progressController.stop();
    } else {
      _playPauseController.forward();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _playPauseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          "Pomodor",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF043953),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 40,
            width: size.width * 0.9,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,

              itemBuilder: (context, index) {
                /*      SchedulerBinding.instance.addPostFrameCallback((_) {
                  _scrollController.jumpTo(_scrollController.position.;
                }); */

                return GestureDetector(
                  onTap: () => _onTimeCardTap(index),
                  child: Container(
                    alignment: Alignment.center,
                    width: 50,
                    decoration: BoxDecoration(
                      color:
                          _selectedIdex == index ? _primaryColor : Colors.white,
                      border: Border.all(
                        width: 1,
                        color:
                            _selectedIdex == index
                                ? Colors.white
                                : _primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${timerSet[index]}",
                      style: TextStyle(
                        color:
                            _selectedIdex == index
                                ? Colors.white
                                : _primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(width: 10),
              itemCount: timerSet.length,
            ),
          ),

          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return CustomPaint(
                painter: PomodorTimer(
                  progress: _progressController.value,
                  timerSettingValue: _timerSettingValue,
                  primaryColor: _primaryColor,
                  inactiveColor: _inactvieColor,
                  timerTextStyle: GoogleFonts.notoSansMono(
                    fontSize: 70,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                size: Size(300, 300),
              );
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                highlightColor: _primaryColor,
                onPressed: () {
                  _progressController.reset();
                  _playPauseController.reset();
                },
                icon: Icon(Icons.rotate_left),
                iconSize: 18,
                color: Colors.grey.shade700,
                style: IconButton.styleFrom(backgroundColor: _inactvieColor),
                padding: EdgeInsets.all(10),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: _onPlayPauseTap,
                child: Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: _playPauseController,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 20),
              IconButton(
                highlightColor: _primaryColor,
                onPressed: () {
                  _progressController.stop();
                },
                icon: Icon(Icons.stop),
                iconSize: 18,
                color: Colors.grey.shade700,
                style: IconButton.styleFrom(backgroundColor: _inactvieColor),
                padding: EdgeInsets.all(10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FaIcon {}

class FontAwesomeIcons {}

class PomodorTimer extends CustomPainter {
  final double progress;
  final int timerSettingValue;
  final Color primaryColor;
  final Color inactiveColor;
  final TextStyle timerTextStyle;
  PomodorTimer({
    required this.primaryColor,
    required this.timerSettingValue,
    required this.inactiveColor,
    required this.progress,
    required this.timerTextStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.width / 2);
    final radius = (size.width / 2) * 0.9;
    final strokeWidth = 25.0;
    const startingAngle = -0.5 * pi;
    final timerString = Duration(
      seconds: timerSettingValue - ((timerSettingValue / 2) * progress).toInt(),
    ).toString().split('.').first.substring(2, 7);

    final circlePaint =
        Paint()
          ..color = inactiveColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, circlePaint);

    final timerArchRect = Rect.fromCircle(center: center, radius: radius);
    final timerArcPaint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;
    canvas.drawArc(
      timerArchRect,
      startingAngle,
      progress * pi,
      false,
      timerArcPaint,
    );

    final textSpan = TextSpan(text: timerString, style: timerTextStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.width - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant PomodorTimer oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
