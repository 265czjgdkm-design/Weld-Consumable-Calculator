import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart' as rive;

import 'calculator_page.dart';
import 'calculator_page/calculator_page_widgets.dart';

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
    _navigateTimer = Timer(const Duration(milliseconds: 1900), _goToApp);
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

  void _goToApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CalculatorPage(),
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

/// The original hand-coded splash animation: the Varyos mark scales and
/// fades in, then the wordmark slides up beneath it. Used whenever
/// [_riveSplashAsset] hasn't been supplied yet (see [SplashScreen]).
class _FallbackSplashAnimation extends StatefulWidget {
  const _FallbackSplashAnimation();

  @override
  State<_FallbackSplashAnimation> createState() =>
      _FallbackSplashAnimationState();
}

class _FallbackSplashAnimationState extends State<_FallbackSplashAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markScale;
  late final Animation<double> _markOpacity;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _markScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.62, curve: Curves.easeOutBack),
      ),
    );
    _markOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _wordmarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );
    _wordmarkOffset =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
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
              Opacity(
                opacity: _markOpacity.value,
                child: Transform.scale(
                  scale: _markScale.value,
                  child: Container(
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
                        BoxShadow(
                          color: Color(0x66FF6A35),
                          blurRadius: 40,
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: const Center(child: VaryosMark(size: 52)),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SlideTransition(
                position: _wordmarkOffset,
                child: FadeTransition(
                  opacity: _wordmarkOpacity,
                  child: const Column(
                    children: [
                      Text(
                        'VARYOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
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
}
