import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/challenge_model.dart';
import '../../data/providers/challenge_provider.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _gradients = [
    LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFF3B82F6)]),
    LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF10B981)]),
    LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFFF6B35)]),
    LinearGradient(colors: [Color(0xFF10B981), Color(0xFF3B82F6)]),
    LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF59E0B)]),
    LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeChallengesProvider);
    final completed = ref.watch(completedChallengesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Challenges',
                  style: AppTextStyles.displaySmall
                      .copyWith(color: Theme.of(context).colorScheme.onSurface)),
              GestureDetector(
                onTap: _showAvailableChallenges,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text('Join',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryOrange,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          labelStyle: AppTextStyles.labelMedium,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveTab(active),
              _buildCompletedTab(completed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTab(List<ChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined,
                size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No active challenges',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Join a challenge to get started!',
                style: AppTextStyles.bodySmall
                    .copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showAvailableChallenges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Browse Challenges'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final gradient = _gradients[index % _gradients.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(challenge.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(challenge.title,
                        style: AppTextStyles.headlineSmall
                            .copyWith(color: Colors.white)),
                  ),
                  if (!challenge.isTodayCompleted)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(challengeProvider.notifier)
                            .completeTodayForChallenge(challenge.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Complete',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: Colors.white)),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('Done',
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                challenge.description,
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.85)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: Colors.white.withValues(alpha: 0.9), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.completedDays}/${challenge.totalDays} days',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(width: 16),
                  if (challenge.currentStreak > 0) ...[
                    const Icon(Icons.local_fire_department,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.currentStreak} day streak',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: challenge.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab(List<ChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events,
                size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No completed challenges yet',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.secondaryGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(challenge.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title,
                        style: AppTextStyles.titleSmall
                            .copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    Text('${challenge.totalDays} days completed',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              const Icon(Icons.emoji_events,
                  color: AppColors.secondaryGreen, size: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAvailableChallenges() {
    final templates = PreBuiltChallenges.templates;
    final joinedIds = ref.read(challengeProvider).map((c) => c.id).toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundLightCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLightElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Available Challenges',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: templates.length,
                      itemBuilder: (ctx, index) {
                        final template = templates[index];
                        final isJoined = joinedIds.contains(template.id);
                        final gradient = _gradients[index % _gradients.length];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(template.icon,
                                      style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(template.title,
                                        style: AppTextStyles.headlineSmall
                                            .copyWith(color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                template.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${template.totalDays} days',
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color:
                                              Colors.white.withValues(alpha: 0.8))),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: isJoined
                                        ? null
                                        : () {
                                            ref
                                                .read(challengeProvider.notifier)
                                                .joinChallenge(template);
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Joined ${template.title}! 🎉',
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                            color:
                                                                Colors.white)),
                                                backgroundColor:
                                                    AppColors.secondaryGreen,
                                              ),
                                            );
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isJoined
                                            ? Colors.white.withValues(alpha: 0.2)
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isJoined ? 'Joined' : 'Join',
                                        style:
                                            AppTextStyles.labelMedium.copyWith(
                                          color: isJoined
                                              ? Colors.white
                                              : AppColors.primaryOrange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
