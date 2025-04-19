// star_reward_data.dart
class StarRewardData {
  final String starColor; // 'yellow' หรือ 'purple'
  final int starRequirement; // เช่น 5 สำหรับเหลือง, 1 สำหรับม่วง
  final String rewardImagePath; // Path รูปภาพสติ๊กเกอร์/กุญแจ
  final String rewardStickerName; // เช่น 'yellow_key' / 'purple_sticker'

  const StarRewardData({
    required this.starColor,
    required this.starRequirement,
    required this.rewardImagePath,
    required this.rewardStickerName,
  });
}

// เราสามารถกำหนดรายการรางวัลเป็น List
final List<StarRewardData> starRewardsForDot = [
  const StarRewardData(
    starColor: 'purple',
    starRequirement: 1,
    rewardImagePath: 'assets/images/rewards/purple_sticker.png',
    rewardStickerName: 'sticker5',
  ),
  const StarRewardData(
    starColor: 'yellow',
    starRequirement: 5,
    rewardImagePath: 'assets/images/rewards/yellow_key.png',
    rewardStickerName: 'sticker6',
  ),
];

final List<StarRewardData> starRewardsForLine = [
  const StarRewardData(
    starColor: 'purple',
    starRequirement: 1,
    rewardImagePath:
        'assets/images/strickerbook/line_sticker/skibidi_sticker.png',
    rewardStickerName: 'stickerLine5',
  ),
  const StarRewardData(
    starColor: 'yellow',
    starRequirement: 5,
    rewardImagePath: 'assets/images/strickerbook/sticker_key_2.png',
    rewardStickerName: 'sticker_key_2',
  ),
];
final List<StarRewardData> starRewardsForShape = [
  const StarRewardData(
    starColor: 'purple',
    starRequirement: 1,
    rewardImagePath:
        'assets/images/strickerbook/line_sticker/skibidi_sticker.png',
    rewardStickerName: 'stickerShape5',
  ),
  const StarRewardData(
    starColor: 'yellow',
    starRequirement: 5,
    rewardImagePath: 'assets/images/strickerbook/sticker_key_3.png',
    rewardStickerName: 'sticker_key_3',
  ),
];
final List<StarRewardData> starRewardsForColor = [
  const StarRewardData(
    starColor: 'purple',
    starRequirement: 1,
    rewardImagePath: 'assets/images/rewards/purple_sticker.png',
    rewardStickerName: 'stickerColor5',
  ),
  const StarRewardData(
    starColor: 'yellow',
    starRequirement: 5,
    rewardImagePath: 'assets/images/rewards/yellow_key.png',
    rewardStickerName: '',
  ),
];
