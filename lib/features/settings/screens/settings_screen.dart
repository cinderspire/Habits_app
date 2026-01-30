import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/habit.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadSettings();
  }

  void _loadSettings() {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _reminderTime = NotificationService.getReminderTime(prefs);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildProfileCard(habits)),
          SliverToBoxAdapter(child: _buildAppearanceSection()),
          SliverToBoxAdapter(child: _buildNotificationSection()),
          SliverToBoxAdapter(child: _buildDataSection()),
          SliverToBoxAdapter(child: _buildAboutSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        'Settings',
        style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryLight),
      ),
    );
  }

  Widget _buildProfileCard(List<Habit> habits) {
    final totalDays = habits.isEmpty
        ? 0
        : DateTime.now()
            .difference(habits
                .map((h) => h.createdAt)
                .reduce((a, b) => a.isBefore(b) ? a : b))
            .inDays;
    final totalCompletions =
        habits.fold<int>(0, (sum, h) => sum + h.completedDates.toSet().length);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Journey',
                      style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    '${habits.length} habits | $totalDays days | $totalCompletions completions',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final isDarkMode = ref.watch(themeModeProvider);
    return _buildSection(
      'Appearance',
      Icons.palette_rounded,
      [
        _buildSwitchTile(
          'Dark Mode',
          'Switch between light and dark theme',
          Icons.dark_mode_rounded,
          isDarkMode,
          (value) {
            ref.read(themeModeProvider.notifier).setDarkMode(value);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      'Notifications',
      Icons.notifications_rounded,
      [
        _buildSwitchTile(
          'Daily Reminders',
          'Get reminded to complete your habits',
          Icons.alarm_rounded,
          _notificationsEnabled,
          (value) async {
            final prefs = ref.read(sharedPreferencesProvider);
            final notifService = NotificationService();
            await notifService.initialize();

            if (value) {
              final granted = await notifService.requestPermissions();
              if (!granted) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notification permission denied',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                return;
              }

              // Schedule notifications for all habits
              final habits = ref.read(habitProvider);
              for (final habit in habits) {
                await notifService.scheduleHabitReminder(
                  id: habit.id.hashCode,
                  habitName: habit.name,
                  habitIcon: habit.icon,
                  time: _reminderTime,
                );
              }
            } else {
              await notifService.cancelAllNotifications();
            }

            await NotificationService.setNotificationsEnabled(prefs, value);
            setState(() => _notificationsEnabled = value);
          },
        ),
        _buildTappableTile(
          'Reminder Time',
          _formatTimeOfDay(_reminderTime),
          Icons.access_time_rounded,
          _notificationsEnabled
              ? () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primaryOrange,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    final prefs = ref.read(sharedPreferencesProvider);
                    await NotificationService.setReminderTime(prefs, picked);
                    setState(() => _reminderTime = picked);

                    // Reschedule notifications
                    if (_notificationsEnabled) {
                      final notifService = NotificationService();
                      await notifService.cancelAllNotifications();
                      final habits = ref.read(habitProvider);
                      for (final habit in habits) {
                        await notifService.scheduleHabitReminder(
                          id: habit.id.hashCode,
                          habitName: habit.name,
                          habitIcon: habit.icon,
                          time: picked,
                        );
                      }
                    }
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      'Data',
      Icons.storage_rounded,
      [
        _buildTappableTile(
          'Export Data',
          'Export your habit data as JSON',
          Icons.file_download_rounded,
          () => _exportData(),
        ),
        _buildTappableTile(
          'Reset All Data',
          'Delete all habits and data',
          Icons.delete_forever_rounded,
          () => _confirmResetData(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      'About',
      Icons.info_rounded,
      [
        _buildInfoTile('App Name', AppConstants.appName, Icons.apps_rounded),
        _buildInfoTile('Version', AppConstants.appVersion, Icons.verified_rounded),
        _buildInfoTile('Developer', 'Built with Flutter', Icons.code_rounded),
      ],
    );
  }

  Widget _buildSection(String title, IconData titleIcon, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, color: AppColors.textTertiaryLight, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.textTertiaryLight, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLightCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryOrange, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.textPrimaryLight)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textTertiaryLight)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildTappableTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.secondaryBlue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.titleSmall.copyWith(
                          color: isDestructive
                              ? AppColors.error
                              : AppColors.textPrimaryLight)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textTertiaryLight)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: onTap != null
                    ? AppColors.textTertiaryLight
                    : AppColors.textTertiaryLight.withOpacity(0.3),
                size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.secondaryPurple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textPrimaryLight)),
          ),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textTertiaryLight)),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _exportData() {
    final prefs = ref.read(sharedPreferencesProvider);
    final storage = StorageService(prefs);
    final json = storage.exportAllData();

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: json));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Data copied to clipboard',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          backgroundColor: AppColors.secondaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset All Data',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.error)),
        content: Text(
          'This will permanently delete all your habits and progress. This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textTertiaryLight)),
          ),
          TextButton(
            onPressed: () {
              final prefs = ref.read(sharedPreferencesProvider);
              final storage = StorageService(prefs);
              storage.clearAllData();

              // Clear all habits at once
              ref.read(habitProvider.notifier).clearAllHabits();

              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data has been reset',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Text('Delete Everything',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
