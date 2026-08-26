import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart' as rive;

import '../services/signup_gate_store.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'email_gate_screen.dart';
import 'home_dashboard_screen.dart';

/// Path a designer can drop a Rive-authored splash animation into. When it's
/// present (and loads successfully) it replaces [_FallbackSplashAnimation]
/// below; otherwise the hand-coded fallback plays instead, so the app never
/// breaks while no .riv file exists yet.
const _riveSplashAsset = 'assets/splash.riv';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigateTimer;
  bool _riveAssetAvailable = false;

  @override
  void initState() {
    super.initState();
    _navigateTimer = Timer(const Duration(milliseconds: 2100), _goToApp);
    _checkRiveAsset();
  }

  // Probe for the asset ourselves before ever handing it to Rive's loader:
  // RiveWidgetBuilder reports a missing/corrupt file as a FlutterError even
  // though it recovers into RiveFailed internally, which flutter test's
  // zone-based error tracking flags as a failed test regardless. Since no
  // .riv file exists until a designer supplies one, we'd otherwise trip
  // that on every test run.
  Future<void> _checkRiveAsset() async {
    try {
      final data = await rootBundle.load(_riveSplashAsset);
      if (data.lengthInBytes == 0) return;
      if (!mounted) return;
      setState(() => _riveAssetAvailable = true);
    } catch (_) {
      // No custom Rive splash yet — the hand-coded fallback plays instead.
    }
  }

  Future<void> _goToApp() async {
    if (!mounted) return;
    final gateResolved = await const SignupGateStore().isResolved();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (context, animation, secondaryAnimation) => gateResolved
            ? const HomeDashboardScreen()
            : const EmailGateScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToApp,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F10),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.5),
              radius: 1.3,
              colors: [Color(0xFF232D30), Color(0xFF0B0F10)],
            ),
          ),
          child: _riveAssetAvailable
              ? rive.RiveWidgetBuilder(
                  fileLoader: rive.FileLoader.fromAsset(
                    _riveSplashAsset,
                    riveFactory: rive.Factory.rive,
                  ),
                  builder: (context, state) {
                    return switch (state) {
                      rive.RiveLoaded(:final controller) => rive.RiveWidget(
                        controller: controller,
                        fit: rive.Fit.contain,
                      ),
                      rive.RiveLoading() || rive.RiveFailed() =>
                        const _FallbackSplashAnimation(),
                    };
                  },
                )
              : const _FallbackSplashAnimation(),
        ),
      ),
    );
  }
}

/// The hand-coded splash animation, played whenever [_riveSplashAsset]
/// hasn't been supplied yet (see [SplashScreen]).
///
/// Sequence: the two blade shapes strike inward from opposite sides and meet
/// at center; the impact throws a brief flash and a shower of ember
/// particles (welding imagery, on brand); the spark settles with a light
/// bounce; the wordmark slides up as its letter-spacing relaxes from wide to
/// its resting value.
class _FallbackSplashAnimation extends StatefulWidget {
  const _FallbackSplashAnimation();

  @override
  State<_FallbackSplashAnimation> createState() =>
      _FallbackSplashAnimationState();
}

class _FallbackSplashAnimationState extends State<_FallbackSplashAnimation>
    with SingleTickerProviderStateMixin {
  static const _particleAnglesDeg = <double>[
    200.0,
    230.0,
    260.0,
    285.0,
    305.0,
    330.0,
    355.0,
    20.0,
  ];

  late final AnimationController _controller;
  late final Animation<Offset> _leftBladeOffset;
  late final Animation<Offset> _rightBladeOffset;
  late final Animation<double> _incomingOpacity;
  late final Animation<double> _impactFlash;
  late final Animation<double> _markRevealScale;
  late final Animation<double> _markRevealOpacity;
  late final List<Animation<double>> _particleDistance;
  late final List<Animation<double>> _particleOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkOffset;
  late final Animation<double> _wordmarkSpacing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _leftBladeOffset = Tween<Offset>(
      begin: const Offset(-1.6, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutExpo),
      ),
    );
    _rightBladeOffset = Tween<Offset>(
      begin: const Offset(1.6, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutExpo),
      ),
    );
    // The two incoming blade slivers: fade in, hold while they travel, then
    // fade out right as they meet — handing off to the real mark, which
    // reveals in the same instant.
    _incomingOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 14),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 22),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 54),
    ]).animate(_controller);

    _impactFlash = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 70,
      ),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.34, 0.62)),
    );

    _markRevealScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.66, curve: Curves.elasticOut),
      ),
    );
    _markRevealOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.5, curve: Curves.easeOut),
      ),
    );

    _particleDistance = [
      for (var i = 0; i < _particleAnglesDeg.length; i++)
        Tween<double>(begin: 0.0, end: 30.0 + (i.isEven ? 6 : 0)).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              0.4 + (i * 0.012),
              0.68 + (i * 0.012),
              curve: Curves.easeOut,
            ),
          ),
        ),
    ];
    _particleOpacity = [
      for (var i = 0; i < _particleAnglesDeg.length; i++)
        TweenSequence<double>([
          TweenSequenceItem(tween: ConstantTween(1.0), weight: 35),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.0).chain(
              CurveTween(curve: Curves.easeIn),
            ),
            weight: 65,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              0.4 + (i * 0.012),
              0.7 + (i * 0.012),
              curve: Curves.linear,
            ),
          ),
        ),
    ];

    _wordmarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.92, curve: Curves.easeOut),
      ),
    );
    _wordmarkOffset =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.56, 0.92, curve: Curves.easeOutCubic),
          ),
        );
    _wordmarkSpacing = Tween<double>(begin: 15.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 1.0, curve: Curves.easeOutCubic),
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
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Impact flash: a soft orange bloom behind everything.
                    Opacity(
                      opacity: _impactFlash.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0x99FF6A35),
                              Color(0x00FF6A35),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Ember particles thrown from the impact point.
                    for (var i = 0; i < _particleAnglesDeg.length; i++)
                      _buildParticle(
                        angleDeg: _particleAnglesDeg[i],
                        distance: _particleDistance[i].value,
                        opacity: _particleOpacity[i].value,
                      ),
                    // Two blade slivers strike inward from either side...
                    FractionalTranslation(
                      translation: _leftBladeOffset.value,
                      child: Opacity(
                        opacity: _incomingOpacity.value,
                        child: _buildIncomingBlade(tiltRight: true),
                      ),
                    ),
                    FractionalTranslation(
                      translation: _rightBladeOffset.value,
                      child: Opacity(
                        opacity: _incomingOpacity.value,
                        child: _buildIncomingBlade(tiltRight: false),
                      ),
                    ),
                    // ...and the real mark reveals at the moment they meet.
                    Opacity(
                      opacity: _markRevealOpacity.value,
                      child: Transform.scale(
                        scale: _markRevealScale.value,
                        child: _buildMarkFrame(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SlideTransition(
                position: _wordmarkOffset,
                child: FadeTransition(
                  opacity: _wordmarkOpacity,
                  child: Column(
                    children: [
                      Text(
                        'VARYOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: _wordmarkSpacing.value,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'WELD',
                        style: TextStyle(
                          color: Color(0xFFFF6A35),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParticle({
    required double angleDeg,
    required double distance,
    required double opacity,
  }) {
    final angle = angleDeg * math.pi / 180;
    final dx = math.cos(angle) * distance;
    final dy = math.sin(angle) * distance;
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: 7,
            height: 2.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD9A0), Color(0xFFFF6A35)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A simplified stand-in blade sliver used only for the two-halves-strike
  /// approach animation; the precise brand shape only needs to appear once
  /// the halves meet, via [_buildMarkFrame]'s real [VaryosMark].
  Widget _buildIncomingBlade({required bool tiltRight}) {
    return Transform.rotate(
      angle: (tiltRight ? 1 : -1) * 0.28,
      child: Container(
        width: 14,
        height: 78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFCBD4D0)],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkFrame() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B3538), Color(0xFF0B0F10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x66FF6A35), blurRadius: 40, spreadRadius: -12),
        ],
      ),
      child: const Center(child: VaryosMark(size: 52)),
    );
  }
}
