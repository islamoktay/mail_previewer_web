import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mail_previewer_web/app/theme/app_colors.dart';

class StartupIntro extends StatefulWidget {
  const StartupIntro({super.key, required this.onFinished});

  final VoidCallback onFinished;

  static const Duration totalDuration = Duration(seconds: 3);
  static const Duration exitDuration = Duration(milliseconds: 450);

  @override
  State<StartupIntro> createState() => _StartupIntroState();
}

class _StartupIntroState extends State<StartupIntro>
    with TickerProviderStateMixin {
  static const List<_IntroEmojiSpec> _emojiSpecs = [
    _IntroEmojiSpec(
      Icons.favorite_rounded,
      leftFactor: 0.14,
      topFactor: 0.16,
      size: 24,
      delay: 0.02,
      travel: 26,
      sway: 10,
      rotation: -0.08,
      backgroundColor: Color(0xFFFFE6EE),
      foregroundColor: Color(0xFFD9789A),
    ),
    _IntroEmojiSpec(
      Icons.local_florist_rounded,
      leftFactor: 0.22,
      topFactor: 0.68,
      size: 22,
      delay: 0.18,
      travel: 30,
      sway: 14,
      rotation: 0.10,
      backgroundColor: Color(0xFFFFF1E2),
      foregroundColor: Color(0xFFC9925F),
    ),
    _IntroEmojiSpec(
      Icons.pets_rounded,
      leftFactor: 0.78,
      topFactor: 0.20,
      size: 24,
      delay: 0.12,
      travel: 22,
      sway: 9,
      rotation: -0.06,
      backgroundColor: Color(0xFFE7F3FF),
      foregroundColor: Color(0xFF6C8FB3),
    ),
    _IntroEmojiSpec(
      Icons.pets_rounded,
      leftFactor: 0.83,
      topFactor: 0.66,
      size: 24,
      delay: 0.34,
      travel: 24,
      sway: 12,
      rotation: 0.08,
      backgroundColor: Color(0xFFFFEFE4),
      foregroundColor: Color(0xFFB68966),
    ),
    _IntroEmojiSpec(
      Icons.local_florist_rounded,
      leftFactor: 0.10,
      topFactor: 0.44,
      size: 24,
      delay: 0.28,
      travel: 20,
      sway: 10,
      rotation: 0.05,
      backgroundColor: Color(0xFFFFF0F4),
      foregroundColor: Color(0xFFCA8CA0),
    ),
    _IntroEmojiSpec(
      Icons.favorite_rounded,
      leftFactor: 0.70,
      topFactor: 0.42,
      size: 20,
      delay: 0.42,
      travel: 18,
      sway: 8,
      rotation: -0.07,
      backgroundColor: Color(0xFFFFEAF1),
      foregroundColor: Color(0xFFD16B95),
    ),
    _IntroEmojiSpec(
      Icons.local_florist_rounded,
      leftFactor: 0.32,
      topFactor: 0.12,
      size: 20,
      delay: 0.24,
      travel: 22,
      sway: 8,
      rotation: 0.06,
      backgroundColor: Color(0xFFF7EFFF),
      foregroundColor: Color(0xFF8F79B8),
    ),
    _IntroEmojiSpec(
      Icons.pets_rounded,
      leftFactor: 0.64,
      topFactor: 0.78,
      size: 20,
      delay: 0.48,
      travel: 18,
      sway: 12,
      rotation: -0.05,
      backgroundColor: Color(0xFFEFF7F1),
      foregroundColor: Color(0xFF6D9A78),
    ),
    _IntroEmojiSpec(
      Icons.favorite_rounded,
      leftFactor: 0.90,
      topFactor: 0.34,
      size: 22,
      delay: 0.56,
      travel: 24,
      sway: 10,
      rotation: 0.09,
      backgroundColor: Color(0xFFFFEDF4),
      foregroundColor: Color(0xFFDF7AA3),
    ),
    _IntroEmojiSpec(
      Icons.local_florist_rounded,
      leftFactor: 0.42,
      topFactor: 0.80,
      size: 20,
      delay: 0.64,
      travel: 16,
      sway: 8,
      rotation: -0.04,
      backgroundColor: Color(0xFFFFF5DF),
      foregroundColor: Color(0xFFC6A24F),
    ),
  ];

  late final AnimationController _heartbeatController;
  late final AnimationController _confettiController;
  late final AnimationController _exitController;
  late final Animation<double> _heartbeatScale;
  Timer? _exitTimer;
  Timer? _finishTimer;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
    _exitController = AnimationController(
      vsync: this,
      duration: StartupIntro.exitDuration,
    );
    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.96,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.06,
          end: 0.99,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.99,
          end: 1.11,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.11,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 24,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 36),
    ]).animate(_heartbeatController);

    final exitLeadTime = StartupIntro.totalDuration - StartupIntro.exitDuration;
    _exitTimer = Timer(exitLeadTime, _startExit);
    _finishTimer = Timer(StartupIntro.totalDuration, widget.onFinished);
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _finishTimer?.cancel();
    _heartbeatController.dispose();
    _confettiController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _startExit() {
    if (!mounted) {
      return;
    }
    _exitController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _heartbeatController,
        _confettiController,
        _exitController,
      ]),
      builder: (context, child) {
        final exitOpacity =
            1.0 - Curves.easeInOut.transform(_exitController.value);
        final exitScale = 1.0 - (_exitController.value * 0.025);

        return IgnorePointer(
          child: Opacity(
            opacity: exitOpacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: exitScale,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFF5F8),
                      AppColors.surface,
                      Color(0xFFF7F3FF),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _IntroBackgroundGlow(
                      alignment: Alignment(-0.72, -0.66),
                      color: Color(0xFFFFD7E3),
                      radius: 220,
                    ),
                    const _IntroBackgroundGlow(
                      alignment: Alignment(0.82, -0.24),
                      color: Color(0xFFE9DEFF),
                      radius: 190,
                    ),
                    const _IntroBackgroundGlow(
                      alignment: Alignment(0.0, 0.92),
                      color: Color(0xFFFFE8D9),
                      radius: 240,
                    ),
                    ..._emojiSpecs.map(
                      (spec) => _FloatingEmoji(
                        animationValue: _confettiController.value,
                        spec: spec,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: _heartbeatScale.value,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest
                                      .withValues(alpha: 0.76),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x142A3439),
                                      blurRadius: 42,
                                      offset: Offset(0, 22),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 28,
                                  ),
                                  child: Text(
                                    'It is made for only NİS',
                                    textAlign: TextAlign.center,
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.7,
                                      color: AppColors.onSurface,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingEmoji extends StatelessWidget {
  const _FloatingEmoji({required this.animationValue, required this.spec});

  final double animationValue;
  final _IntroEmojiSpec spec;

  @override
  Widget build(BuildContext context) {
    final progress = (animationValue + spec.delay) % 1.0;
    final wave = math.sin(progress * math.pi * 2);
    final drift = math.sin((progress * math.pi * 2) + (spec.delay * math.pi));
    final verticalOffset =
        (0.5 - math.cos(progress * math.pi * 2) / 2) * spec.travel;
    final opacity = 0.38 + ((wave + 1) * 0.14);
    final scale = 0.92 + ((drift + 1) * 0.05);

    return Positioned(
      left: spec.leftFactor * MediaQuery.sizeOf(context).width,
      top: spec.topFactor * MediaQuery.sizeOf(context).height,
      child: Transform.translate(
        offset: Offset(drift * spec.sway, verticalOffset - (spec.travel * 0.5)),
        child: Transform.rotate(
          angle: spec.rotation + (wave * 0.08),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: spec.backgroundColor.withValues(alpha: 0.86),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x122A3439),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    spec.icon,
                    size: spec.size,
                    color: spec.foregroundColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroBackgroundGlow extends StatelessWidget {
  const _IntroBackgroundGlow({
    required this.alignment,
    required this.color,
    required this.radius,
  });

  final Alignment alignment;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.48),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroEmojiSpec {
  const _IntroEmojiSpec(
    this.icon, {
    required this.leftFactor,
    required this.topFactor,
    required this.size,
    required this.delay,
    required this.travel,
    required this.sway,
    required this.rotation,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final double leftFactor;
  final double topFactor;
  final double size;
  final double delay;
  final double travel;
  final double sway;
  final double rotation;
  final Color backgroundColor;
  final Color foregroundColor;
}
