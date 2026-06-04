import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../Core/Routes/app_routes.dart';

// ─── Splash Screen ────────────────────────────────────────────────────────────

/// Pantalla inicial de bienvenida; prepara la navegacion hacia el flujo principal.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Estado interno de `SplashScreen`; coordina datos, eventos y reconstrucciones de la pantalla.
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotsController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  // Background
  late Animation<double> _bgScale;

  // Logo
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoY;

  // Icon inner
  late Animation<double> _iconRotate;
  late Animation<double> _iconScale;

  // Text
  late Animation<double> _textOpacity;
  late Animation<double> _textY;
  late Animation<double> _letterSpacing;

  // Dots
  late Animation<double> _dotsOpacity;

  // Pulse rings
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // Particles
  late Animation<double> _particleProgress;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Background
    _bgScale = Tween<double>(
      begin: 1.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));

    // Logo
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_logoController);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoY = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Icon inner
    _iconRotate = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_logoController);

    // Text
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textY = Tween<double>(
      begin: 16.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _letterSpacing = Tween<double>(
      begin: 8.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Dots
    _dotsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _dotsController, curve: Curves.easeIn));

    // Pulse
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    _pulseOpacity = Tween<double>(
      begin: 0.35,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    // Particles
    _particleProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 120));
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 620));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 380));
    _dotsController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      body: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.login);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _bgController,
            _logoController,
            _textController,
            _dotsController,
            _pulseController,
            _particleController,
          ]),
          builder: (context, _) {
            return Stack(
              children: [
                // ── Animated background blobs ──
                _buildBackground(size),

                // ── Floating particles ──
                ..._buildParticles(size),

                // ── Content ──
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // ── Logo + pulse rings ──
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            Opacity(
                              opacity: _pulseOpacity.value,
                              child: Transform.scale(
                                scale: _pulseScale.value,
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFF6B47),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Inner pulse ring (offset)
                            Opacity(
                              opacity: (_pulseOpacity.value * 0.6).clamp(
                                0.0,
                                1.0,
                              ),
                              child: Transform.scale(
                                scale: (_pulseScale.value * 0.75).clamp(
                                  0.0,
                                  3.0,
                                ),
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFFFF6B47,
                                    ).withOpacity(0.08),
                                  ),
                                ),
                              ),
                            ),

                            // Logo card
                            Transform.translate(
                              offset: Offset(0, _logoY.value),
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: _buildLogoCard(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Wordmark ──
                      Transform.translate(
                        offset: Offset(0, _textY.value),
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: Text(
                            'Promomania',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: _letterSpacing.value,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ── Tagline ──
                      Transform.translate(
                        offset: Offset(0, _textY.value * 1.4),
                        child: Opacity(
                          opacity: (_textOpacity.value - 0.3).clamp(0, 1),
                          child: const Text(
                            'Discover the best deals near you',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFAA8880),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // ── Loading dots ──
                      Opacity(
                        opacity: _dotsOpacity.value,
                        child: _AnimatedDots(),
                      ),

                      const SizedBox(height: 20),

                      // ── Version ──
                      Opacity(
                        opacity: _dotsOpacity.value * 0.5,
                        child: const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFCCB0AA),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7A5A), Color(0xFFE84E2A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE84E2A).withOpacity(0.40),
            blurRadius: 28,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFFFF9070).withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: _iconRotate.value,
        child: Transform.scale(
          scale: _iconScale.value,
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 46,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Transform.scale(
      scale: _bgScale.value,
      child: Stack(
        children: [
          // Top-right warm blob
          Positioned(
            top: -size.height * 0.12,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD5C8).withOpacity(0.6),
                    const Color(0xFFFFF5F2).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Bottom-left accent blob
          Positioned(
            bottom: -size.height * 0.08,
            left: -size.width * 0.15,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFCFC5).withOpacity(0.45),
                    const Color(0xFFFFF5F2).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(Size size) {
    const particles = [
      _ParticleData(0.15, 0.22, 3.5, 0.0),
      _ParticleData(0.82, 0.18, 2.5, 0.15),
      _ParticleData(0.08, 0.68, 2.0, 0.30),
      _ParticleData(0.90, 0.60, 3.0, 0.45),
      _ParticleData(0.50, 0.10, 2.8, 0.60),
      _ParticleData(0.25, 0.88, 2.2, 0.75),
      _ParticleData(0.70, 0.82, 3.2, 0.20),
      _ParticleData(0.45, 0.75, 1.8, 0.55),
    ];

    return particles.map((p) {
      final t = (_particleProgress.value + p.phase) % 1.0;
      final opacity = (math.sin(t * math.pi) * 0.5).clamp(0.0, 0.5);
      final yOffset = math.sin(t * math.pi * 2) * 12;

      return Positioned(
        left: size.width * p.x,
        top: size.height * p.y + yOffset,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: p.size,
            height: p.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE05535),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ─── Particle data ─────────────────────────────────────────────────────────

/// Modelo interno con posicion y animacion de una particula visual.
class _ParticleData {
  final double x, y, size, phase;
  const _ParticleData(this.x, this.y, this.size, this.phase);
}

// ─── Animated dots loader ─────────────────────────────────────────────────

/// Widget interno de puntos animados usado como indicador visual.
class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

/// Estado interno de `AnimatedDots`; coordina datos, eventos y reconstrucciones de la pantalla.
class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_c.value - i * 0.2).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * math.sin(t * math.pi);
            final opacity = 0.3 + 0.7 * math.sin(t * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE84E2A),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
