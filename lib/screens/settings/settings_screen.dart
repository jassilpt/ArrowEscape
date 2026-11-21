import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/app_themes.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeColors = AppThemes.getThemeColors(progress.selectedTheme);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: themeColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.themeSectionTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: themeColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: GameTheme.values.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final theme = GameTheme.values[index];
                    final isSelected = progress.selectedTheme == theme;
                    const isLocked = false;
                    final previewColors = AppThemes.getThemeColors(theme);

                    return GestureDetector(
                      onTap: () {
                        ref.read(progressRepositoryProvider).setTheme(theme);
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: previewColors.bgGradient,
                          border: Border.all(
                            color: isSelected
                                ? previewColors.accentColor
                                : themeColors.surfaceLight,
                            width: isSelected ? 3 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: isLocked
                              ? Icon(
                                  Icons.lock,
                                  color: previewColors.isLight
                                      ? const Color(0xFF8C95A3)
                                      : AppColors.textMuted,
                                  size: 20,
                                )
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: previewColors.arrowPalette != null
                                      ? const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: SweepGradient(
                                            colors: [
                                              Color(0xFFFF5252),
                                              Color(0xFFFF9100),
                                              Color(0xFFFFEA00),
                                              Color(0xFF00E676),
                                              Color(0xFF00E5FF),
                                              Color(0xFF7C4DFF),
                                              Color(0xFFFF4081),
                                              Color(0xFFFF5252),
                                            ],
                                          ),
                                        )
                                      : BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: previewColors.arrowColor,
                                          border: Border.all(
                                            color: Colors.white24,
                                            width: 1,
                                          ),
                                        ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: previewColors.arrowColor
                                                      .computeLuminance() >
                                                  0.5
                                              ? Colors.black
                                              : Colors.white,
                                        )
                                      : null,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.preferencesSectionTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: themeColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildPreferenceTile(
                title: l10n.prefHapticsTitle,
                description: l10n.prefHapticsDesc,
                value: progress.hapticsEnabled,
                onChanged: (_) =>
                    ref.read(progressRepositoryProvider).toggleHaptics(),
                accentColor: themeColors.accentColor,
                themeColors: themeColors,
              ),
              const SizedBox(height: 14),
              _buildPreferenceTile(
                title: l10n.prefInfiniteLivesTitle,
                description: l10n.prefInfiniteLivesDesc,
                value: progress.heartRemover,
                onChanged: (_) =>
                    ref.read(progressRepositoryProvider).toggleHeartRemover(),
                accentColor: themeColors.accentColor,
                themeColors: themeColors,
              ),
              const SizedBox(height: 14),
              _buildPreferenceTile(
                title: l10n.prefTapAssistTitle,
                description: l10n.prefTapAssistDesc,
                value: progress.assistMode,
                onChanged: (_) =>
                    ref.read(progressRepositoryProvider).toggleAssistMode(),
                accentColor: themeColors.accentColor,
                themeColors: themeColors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accentColor,
    required ThemeColors themeColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.surfaceLight, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: themeColors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: themeColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.3),
            inactiveThumbColor: themeColors.textMuted,
            inactiveTrackColor: themeColors.surfaceLight,
          ),
        ],
      ),
    );
  }
}
