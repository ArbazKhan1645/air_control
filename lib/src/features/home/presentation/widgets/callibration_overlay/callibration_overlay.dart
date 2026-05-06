// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Calibration overlay shown during sensor calibration
class CalibrationOverlay extends StatelessWidget {
  final bool isCalibrating;
  final VoidCallback? onRecalibrate;

  const CalibrationOverlay({
    super.key,
    required this.isCalibrating,
    this.onRecalibrate,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCalibrating) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.95),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phone icon with motion lines
              Stack(
                alignment: Alignment.center,
                children: [
                  // Motion lines
                  ...List.generate(3, (index) {
                    return Container(
                          width: 120 + (index * 30),
                          height: 120 + (index * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withOpacity(
                                0.3 - (index * 0.1),
                              ),
                              width: 2,
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.2, 1.2),
                          duration: (1500 + index * 200).ms,
                          curve: Curves.easeInOut,
                        )
                        .fadeOut(begin: 0.5, duration: (1500 + index * 200).ms);
                  }),

                  // Phone icon
                  Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smartphone,
                          color: Colors.blue,
                          size: 48,
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .rotate(
                        begin: -0.05,
                        end: 0.05,
                        duration: 1000.ms,
                        curve: Curves.easeInOut,
                      ),
                ],
              ),

              const SizedBox(height: 48),

              const Text(
                'CALIBRATING',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Hold your device steady...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // Progress indicator
              SizedBox(
                width: 200,
                child:
                    LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.3),
                        ),
              ),

              const SizedBox(height: 48),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Keep device flat and still',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Settings panel for motion configuration
class SettingsPanel extends StatelessWidget {
  final bool showDebug;
  final bool showInstructions;
  final VoidCallback? onToggleDebug;
  final VoidCallback? onShowInstructions;
  final VoidCallback? onRecalibrate;
  final VoidCallback? onClose;

  const SettingsPanel({
    super.key,
    required this.showDebug,
    required this.showInstructions,
    this.onToggleDebug,
    this.onShowInstructions,
    this.onRecalibrate,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Options
              _SettingsOption(
                icon: Icons.bug_report,
                title: 'Debug Overlay',
                subtitle: 'Show motion sensor data',
                trailing: Switch(
                  value: showDebug,
                  onChanged: (_) => onToggleDebug?.call(),
                  activeThumbColor: Colors.blue,
                ),
              ),

              _SettingsOption(
                icon: Icons.help_outline,
                title: 'Instructions',
                subtitle: 'View gesture controls',
                onTap: onShowInstructions,
              ),

              _SettingsOption(
                icon: Icons.refresh,
                title: 'Recalibrate',
                subtitle: 'Reset motion sensors',
                onTap: onRecalibrate,
              ),

              const SizedBox(height: 8),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 200.ms);
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }
}
