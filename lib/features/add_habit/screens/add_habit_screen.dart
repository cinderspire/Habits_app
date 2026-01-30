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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      frequency: _selectedFrequency,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Habit',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimaryLight),
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
              Text('Quick Start', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildSuggestedHabits(),
              const SizedBox(height: 28),

              // Name input
              Text('Habit Name', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                maxLength: AppConstants.maxHabitNameLength,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
                decoration: InputDecoration(
                  hintText: 'e.g. Morning Meditation',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiaryLight),
                  filled: true,
                  fillColor: AppColors.backgroundLightCard,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              Text('Icon', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildIconPicker(),
              const SizedBox(height: 24),

              // Color picker
              Text('Color', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildColorPicker(),
              const SizedBox(height: 24),

              // Frequency selector
              Text('Frequency', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 12),
              _buildFrequencySelector(),
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
                        color: AppColors.primaryOrange.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Create Habit',
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
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
                  ? Color(s['color'] as int).withOpacity(0.15)
                  : AppColors.backgroundLightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Color(s['color'] as int) : AppColors.glassBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s['icon'] as String, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  s['name'] as String,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Color(s['color'] as int) : AppColors.textSecondaryLight,
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
                    ? Color(_selectedColor).withOpacity(0.15)
                    : AppColors.backgroundLightElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Color(_selectedColor) : Colors.transparent,
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
                color: isSelected ? AppColors.textPrimaryLight : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(colorValue).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
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
                ? AppColors.primaryOrange.withOpacity(0.1)
                : AppColors.backgroundLightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primaryOrange : AppColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected ? AppColors.primaryOrange : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
