import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/habit.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIcon = AppConstants.habitIcons[0];
  int _selectedColor = AppConstants.habitColors[0];
  String _selectedFrequency = 'daily';
  List<int> _selectedCustomDays = [];
  TimeOfDay? _reminderTime;
  int _targetPerDay = 1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    String? reminderStr;
    if (_reminderTime != null) {
      reminderStr =
          '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}';
    }

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      frequency: _selectedFrequency,
      customDays: _selectedFrequency == 'custom' ? _selectedCustomDays : [],
      reminderTime: reminderStr,
      targetPerDay: _targetPerDay,
    );

    ref.read(habitProvider.notifier).addHabit(habit);
    Navigator.of(context).pop();
  }

  void _selectSuggested(Map<String, dynamic> suggestion) {
    _nameController.text = suggestion['name'] as String;
    setState(() {
      _selectedIcon = suggestion['icon'] as String;
      _selectedColor = suggestion['color'] as int;
    });
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
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
      setState(() => _reminderTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Habit',
          style: AppTextStyles.headlineMedium
              .copyWith(color: AppColors.textPrimaryLight),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Suggested habits
              Text('Quick Start',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildSuggestedHabits(),
              const SizedBox(height: 28),

              // Name input
              Text('Habit Name',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                maxLength: AppConstants.maxHabitNameLength,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textPrimaryLight),
                decoration: InputDecoration(
                  hintText: 'e.g. Morning Meditation',
                  hintStyle: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textTertiaryLight),
                  filled: true,
                  fillColor: AppColors.backgroundLightCard,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primaryOrange, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Icon picker
              Text('Icon',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildIconPicker(),
              const SizedBox(height: 24),

              // Color picker
              Text('Color',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildColorPicker(),
              const SizedBox(height: 24),

              // Frequency selector
              Text('Frequency',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildFrequencySelector(),

              // Custom days picker
              if (_selectedFrequency == 'custom') ...[
                const SizedBox(height: 16),
                _buildCustomDaysPicker(),
              ],
              const SizedBox(height: 24),

              // Target per day
              Text('Target Per Day',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildTargetSelector(),
              const SizedBox(height: 24),

              // Reminder time
              Text('Reminder (Optional)',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildReminderPicker(),
              const SizedBox(height: 36),

              // Save button
              GestureDetector(
                onTap: _saveHabit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Create Habit',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedHabits() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.suggestedHabits.map((s) {
        final isSelected = _nameController.text == s['name'];
        return GestureDetector(
          onTap: () => _selectSuggested(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(s['color'] as int).withValues(alpha: 0.15)
                  : AppColors.backgroundLightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Color(s['color'] as int)
                    : AppColors.glassBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s['icon'] as String,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  s['name'] as String,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? Color(s['color'] as int)
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: AppConstants.habitIcons.length,
        itemBuilder: (context, index) {
          final icon = AppConstants.habitIcons[index];
          final isSelected = icon == _selectedIcon;
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(_selectedColor).withValues(alpha: 0.15)
                    : AppColors.backgroundLightElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      isSelected ? Color(_selectedColor) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppConstants.habitColors.map((colorValue) {
        final isSelected = colorValue == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = colorValue),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected ? AppColors.textPrimaryLight : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(colorValue).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return Row(
      children: [
        _buildFrequencyChip('Daily', 'daily'),
        const SizedBox(width: 12),
        _buildFrequencyChip('Weekly', 'weekly'),
        const SizedBox(width: 12),
        _buildFrequencyChip('Custom', 'custom'),
      ],
    );
  }

  Widget _buildFrequencyChip(String label, String value) {
    final isSelected = _selectedFrequency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFrequency = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryOrange.withValues(alpha: 0.1)
                : AppColors.backgroundLightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryOrange : AppColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDaysPicker() {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final dayNum = index + 1; // 1=Mon, 7=Sun
          final isSelected = _selectedCustomDays.contains(dayNum);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCustomDays.remove(dayNum);
                } else {
                  _selectedCustomDays.add(dayNum);
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.backgroundLightElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  dayLabels[index],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTargetSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat_rounded,
              color: AppColors.textTertiaryLight, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Times per day',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimaryLight),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_targetPerDay > 1) {
                setState(() => _targetPerDay--);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundLightElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.remove_rounded,
                  color: AppColors.textSecondaryLight, size: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_targetPerDay',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_targetPerDay < 10) {
                setState(() => _targetPerDay++);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primaryOrange, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderPicker() {
    return GestureDetector(
      onTap: _pickReminderTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundLightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _reminderTime != null
                    ? AppColors.primaryOrange.withValues(alpha: 0.1)
                    : AppColors.backgroundLightElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.alarm_rounded,
                color: _reminderTime != null
                    ? AppColors.primaryOrange
                    : AppColors.textTertiaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reminderTime != null
                        ? 'Reminder at ${_formatTimeOfDay(_reminderTime!)}'
                        : 'Set a reminder time',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: _reminderTime != null
                          ? AppColors.textPrimaryLight
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  if (_reminderTime == null)
                    Text(
                      'Tap to add a daily reminder',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textTertiaryLight),
                    ),
                ],
              ),
            ),
            if (_reminderTime != null)
              GestureDetector(
                onTap: () => setState(() => _reminderTime = null),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textTertiaryLight, size: 20),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiaryLight, size: 22),
          ],
        ),
      ),
    );
  }
}
