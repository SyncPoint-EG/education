/// Defines the star milestone reward system.
/// Each milestone has a target star count and a reward.
class StarMilestone {
  final String id;
  final String title;
  final String emoji;
  final int requiredStars;
  final String rewardDescription;

  const StarMilestone({
    required this.id,
    required this.title,
    required this.emoji,
    required this.requiredStars,
    required this.rewardDescription,
  });
}

/// All milestones ordered by required stars (ascending).
const List<StarMilestone> allMilestones = [
  StarMilestone(
    id: 'rising_star',
    title: 'نجم صاعد',
    emoji: '🌟',
    requiredStars: 10,
    rewardDescription: 'أول 10 نجوم! أنت بطل حقيقي',
  ),
  StarMilestone(
    id: 'bright_star',
    title: 'نجم لامع',
    emoji: '✨',
    requiredStars: 25,
    rewardDescription: 'واصل التألق! جمعت 25 نجمة',
  ),
  StarMilestone(
    id: 'golden_star',
    title: 'نجم ذهبي',
    emoji: '🥇',
    requiredStars: 50,
    rewardDescription: 'مذهل! وصلت لـ 50 نجمة ذهبية',
  ),
  StarMilestone(
    id: 'diamond_star',
    title: 'نجم ماسي',
    emoji: '💎',
    requiredStars: 100,
    rewardDescription: 'لامع كالماس! 100 نجمة كاملة',
  ),
  StarMilestone(
    id: 'super_star',
    title: 'سوبر ستار',
    emoji: '👑',
    requiredStars: 150,
    rewardDescription: 'ملك النجوم! وصلت لـ 150 نجمة',
  ),
];

/// Returns the next milestone that hasn't been unlocked yet,
/// or null if all are unlocked.
StarMilestone? getNextMilestone(List<String> unlockedIds) {
  for (final m in allMilestones) {
    if (!unlockedIds.contains(m.id)) return m;
  }
  return null;
}

/// Returns all newly unlockable milestones for the given total stars
/// that haven't been unlocked yet.
List<StarMilestone> checkNewMilestones(int totalStars, List<String> unlockedIds) {
  final List<StarMilestone> newlyUnlocked = [];
  for (final m in allMilestones) {
    if (totalStars >= m.requiredStars && !unlockedIds.contains(m.id)) {
      newlyUnlocked.add(m);
    }
  }
  return newlyUnlocked;
}
