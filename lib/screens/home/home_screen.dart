import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_themes.dart';
import '../../core/constants.dart';
import '../../core/audio_haptic_helper.dart';
import '../../core/game_mode.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../game/game_screen.dart';
import '../level_select/level_select_screen.dart';
import '../how_to_play/how_to_play_screen.dart';
import '../multiplayer/multiplayer_seed_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preWarmLevels();
    });
  }

  void _preWarmLevels() {
    final progress = ref.read(progressRepositoryProvider);
    final levelRepo = ref.read(levelRepositoryProvider);
    final currentLevel = progress.currentLevel;
    for (int i = 0; i < 4; i++) {
      levelRepo.preGenerateAsync(currentLevel + i);
    }
  }

  void _cycleTheme() {
    final progress = ref.read(progressRepositoryProvider);
    final allThemes = GameTheme.values;
    final currentIndex = allThemes.indexOf(progress.selectedTheme);
    final nextTheme = allThemes[(currentIndex + 1) % allThemes.length];
    progress.setTheme(nextTheme);
  }

  int _randomLevelForDifficulty(String difficulty) {
    final rng = Random();
    switch (difficulty) {
      case 'easy':
        return AppConstants.randomEasyMin +
            rng.nextInt(
              AppConstants.randomEasyMax - AppConstants.randomEasyMin + 1,
            );
      case 'medium':
        return AppConstants.randomMediumMin +
            rng.nextInt(
              AppConstants.randomMediumMax - AppConstants.randomMediumMin + 1,
            );
      case 'hard':
        return AppConstants.randomHardMin +
            rng.nextInt(
              AppConstants.randomHardMax - AppConstants.randomHardMin + 1,
            );
      case 'master':
        return AppConstants.randomMasterMin +
            rng.nextInt(
              AppConstants.randomMasterMax - AppConstants.randomMasterMin + 1,
            );
      case 'expert':
        return AppConstants.randomExpertMin +
            rng.nextInt(
              AppConstants.randomExpertMax - AppConstants.randomExpertMin + 1,
            );
      default:
        return 11;
    }
  }

  void _showRandomPuzzleDialog() {
    final progress = ref.read(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: themeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: themeColors.accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.randomPuzzleTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: themeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.randomPuzzleSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _DifficultyButton(
                  label: l10n.difficultyEasy,
                  icon: Icons.bolt,
                  onTap: () => _playRandom('easy'),
                ),
                const SizedBox(height: 10),
                _DifficultyButton(
                  label: l10n.difficultyMedium,
                  icon: Icons.speed,
                  onTap: () => _playRandom('medium'),
                ),
                const SizedBox(height: 10),
                _DifficultyButton(
                  label: l10n.difficultyHard,
                  icon: Icons.local_fire_department,
                  onTap: () => _playRandom('hard'),
                ),
                const SizedBox(height: 10),
                _DifficultyButton(
                  label: l10n.difficultyMaster,
                  icon: Icons.psychology,
                  onTap: () => _playRandom('master'),
                ),
                const SizedBox(height: 10),
                _DifficultyButton(
                  label: l10n.difficultyExpert,
                  icon: Icons.military_tech,
                  onTap: () => _playRandom('expert'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    l10n.dialogCancel,
                    style: TextStyle(
                      color: themeColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _playRandom(String difficulty) async {
    Navigator.pop(context);
    final levelNum = _randomLevelForDifficulty(difficulty);
    if (!mounted) return;
    setState(() => _isNavigating = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(level: levelNum, isRandom: true),
      ),
    );
    if (mounted) setState(() => _isNavigating = false);
  }

  void _showModesSelection(BuildContext context, int currentLevel) {
    final progress = ref.read(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: themeColors.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.modesTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: themeColors.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ...[
                  (
                    label: l10n.modeLevelsTitle,
                    description: l10n.modeLevelsDesc,
                    icon: Icons.grid_view_rounded,
                    color: Colors.amberAccent,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LevelSelectScreen(),
                        ),
                      );
                    },
                  ),
                  (
                    label: l10n.modeRandomTitle,
                    description: l10n.modeRandomDesc,
                    icon: Icons.casino_rounded,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.pop(ctx);
                      _showRandomPuzzleDialog();
                    },
                  ),
                  (
                    label: l10n.modeZenTitle,
                    description: l10n.modeZenDesc,
                    icon: Icons.spa,
                    color: Colors.greenAccent,
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      setState(() => _isNavigating = true);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            level: currentLevel,
                            gameMode: GameMode.zen,
                          ),
                        ),
                      );
                      if (mounted) setState(() => _isNavigating = false);
                    },
                  ),
                  (
                    label: l10n.modeTimeAttackTitle,
                    description: l10n.modeTimeAttackDesc,
                    icon: Icons.timer,
                    color: Colors.orangeAccent,
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      setState(() => _isNavigating = true);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameScreen(
                            level: 1,
                            gameMode: GameMode.timeAttack,
                          ),
                        ),
                      );
                      if (mounted) setState(() => _isNavigating = false);
                    },
                  ),
                  (
                    label: l10n.modeMultiplayerTitle,
                    description: l10n.modeMultiplayerDesc,
                    icon: Icons.groups_rounded,
                    color: Colors.cyanAccent,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MultiplayerSeedScreen(),
                        ),
                      );
                    },
                  ),
                ].map(
                  (item) => GestureDetector(
                    onTap: item.onTap,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: themeColors.isLight
                              ? themeColors.surfaceLight
                              : Colors.white10,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, color: item.color, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: themeColors.textPrimary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: themeColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);
    final l10n = AppLocalizations.of(context)!;

    // Secondary accent color for rich 3D dual-tone gradient
    final secondaryAccent = themeColors.isLight
        ? themeColors.accentDark
        : Color.lerp(themeColors.accentColor, const Color(0xFF9D4EDD), 0.55)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AppBarIconButton(
                  icon: Icons.palette_outlined,
                  iconColor: themeColors.accentColor,
                  themeColors: themeColors,
                  onTap: _cycleTheme,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: themeColors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeColors.accentColor.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeColors.accentColor.withValues(alpha: 0.2),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag_rounded,
                        color: themeColors.accentColor,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.levelHeader(progress.currentLevel),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: themeColors.textPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _AppBarIconButton(
                  icon: Icons.settings_outlined,
                  iconColor: themeColors.textPrimary,
                  themeColors: themeColors,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Base Theme Gradient
          Container(
            decoration: BoxDecoration(gradient: themeColors.bgGradient),
          ),
          // 2. Subtle Arcade Puzzle Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: _ArcadeGridPainter(
                gridColor: themeColors.accentColor.withValues(
                  alpha: themeColors.isLight ? 0.08 : 0.06,
                ),
              ),
            ),
          ),
          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 3D Glowing Emblem Ring + Custom 3D Beveled Arrow
                Container(
                  width: 142,
                  height: 142,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        themeColors.accentColor.withValues(alpha: 0.28),
                        secondaryAccent.withValues(alpha: 0.14),
                        themeColors.surface.withValues(alpha: 0.92),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                    border: Border.all(
                      color: themeColors.accentColor,
                      width: 3.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeColors.accentColor.withValues(alpha: 0.45),
                        blurRadius: 34,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: secondaryAccent.withValues(alpha: 0.25),
                        blurRadius: 48,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 78,
                      height: 78,
                      child: CustomPaint(
                        painter: _Arrow3DEmblemPainter(
                          primaryColor: themeColors.accentColor,
                          secondaryColor: secondaryAccent,
                          depthColor: themeColors.accentDark,
                          isLight: themeColors.isLight,
                        ),
                      ),
                    )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .slideY(
                          begin: 0.07,
                          end: -0.07,
                          duration: 1400.ms,
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .shimmer(
                          duration: 1300.ms,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                  ),
                ),

                const SizedBox(height: 26),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: themeColors.textPrimary,
                        letterSpacing: 3.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(
                              alpha: themeColors.isLight ? 0.12 : 0.65,
                            ),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                          if (themeColors.hasGlow)
                            Shadow(
                              color: themeColors.accentColor
                                  .withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),
                ),

                const SizedBox(height: 10),

                Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: themeColors.textSecondary,
                    letterSpacing: 2.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.5, end: 0),

                const Spacer(flex: 3),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Column(
                    children: [
                      // Primary Glossy 3D Dual-Gradient PLAY Button with Moving Light Sweep
                      GestureDetector(
                        onTap: _isNavigating
                            ? null
                            : () async {
                                AudioHapticHelper.playClick();
                                if (!mounted) return;
                                setState(() => _isNavigating = true);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GameScreen(
                                      level: progress.currentLevel,
                                      gameMode: GameMode.classic,
                                    ),
                                  ),
                                );
                                if (mounted) {
                                  setState(() => _isNavigating = false);
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          height: 62,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeColors.accentColor,
                                secondaryAccent,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColors.accentDark,
                                offset: const Offset(0, 5),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: themeColors.accentColor
                                    .withValues(alpha: 0.45),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Top Half Glossy Reflection
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 28,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.28),
                                          Colors.white.withValues(alpha: 0.02),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                // Button Content
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: themeColors.accentColor
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black
                                          : Colors.white,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.menuPlay,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: themeColors.accentColor
                                                    .computeLuminance() >
                                                0.5
                                            ? Colors.black
                                            : Colors.white,
                                        letterSpacing: 2.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .shimmer(
                              delay: 1200.ms,
                              duration: 1500.ms,
                              angle: 0.35,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        label: l10n.menuGameModes,
                        icon: Icons.grid_view_rounded,
                        onTap: _isNavigating
                            ? null
                            : () => _showModesSelection(
                                  context,
                                  progress.currentLevel,
                                ),
                      ),

                      const SizedBox(height: 12),

                      _MenuButton(
                        label: l10n.menuHowToPlay,
                        icon: Icons.lightbulb_outline_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HowToPlayScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws subtle glowing puzzle grid lines across the background
class _ArcadeGridPainter extends CustomPainter {
  final Color gridColor;

  _ArcadeGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const step = 36.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcadeGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor;
}

/// Custom 3D Beveled Arrow Emblem Painter matching the Neon Preview
class _Arrow3DEmblemPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color depthColor;
  final bool isLight;

  _Arrow3DEmblemPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.depthColor,
    required this.isLight,
  });

  Path _buildArrowPath(Size size, {double dy = 0}) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.50, h * 0.08 + dy)
      ..lineTo(w * 0.88, h * 0.48 + dy)
      ..lineTo(w * 0.65, h * 0.48 + dy)
      ..lineTo(w * 0.65, h * 0.90 + dy)
      ..lineTo(w * 0.50, h * 0.78 + dy)
      ..lineTo(w * 0.35, h * 0.90 + dy)
      ..lineTo(w * 0.35, h * 0.48 + dy)
      ..lineTo(w * 0.12, h * 0.48 + dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. 3D Extruded Shadow / Depth Layer (shifted down)
    final depthPath = _buildArrowPath(size, dy: 6.5);
    final depthPaint = Paint()
      ..color = depthColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(depthPath, depthPaint);

    // 2. Main Front Face
    final mainPath = _buildArrowPath(size, dy: 0);

    // Left illuminated 3D facet
    final leftFacet = Path()
      ..moveTo(w * 0.50, h * 0.08)
      ..lineTo(w * 0.50, h * 0.78)
      ..lineTo(w * 0.35, h * 0.90)
      ..lineTo(w * 0.35, h * 0.48)
      ..lineTo(w * 0.12, h * 0.48)
      ..close();

    // Right shaded 3D facet
    final rightFacet = Path()
      ..moveTo(w * 0.50, h * 0.08)
      ..lineTo(w * 0.88, h * 0.48)
      ..lineTo(w * 0.65, h * 0.48)
      ..lineTo(w * 0.65, h * 0.90)
      ..lineTo(w * 0.50, h * 0.78)
      ..close();

    canvas.drawPath(
      leftFacet,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: isLight ? 0.35 : 0.75),
            primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawPath(
      rightFacet,
      Paint()
        ..shader = LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 3. Crisp Glowing Rim Outline
    final borderPaint = Paint()
      ..color = isLight ? depthColor : Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(mainPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _Arrow3DEmblemPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor ||
      oldDelegate.depthColor != depthColor;
}

class _MenuButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          AudioHapticHelper.playClick();
          onTap!();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: themeColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeColors.accentColor.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColors.accentDark.withValues(alpha: 0.45),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: themeColors.accentColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: themeColors.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);

    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: themeColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeColors.accentColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeColors.accentDark,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: themeColors.accentColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: themeColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final ThemeColors themeColors;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.iconColor,
    required this.themeColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioHapticHelper.playClick();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: themeColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: themeColors.accentColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColors.accentDark.withValues(alpha: 0.3),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(child: Icon(icon, color: iconColor, size: 22)),
      ),
    );
  }
}
