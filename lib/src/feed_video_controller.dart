import 'dart:math';

import 'package:in_feed_video/src/abstract_video_controller.dart';

/// 默认Item曝光/消失对于播放器的控制
class DefaultBehaviorVideosController extends AbstractVideosController {
  DefaultBehaviorVideosController({required players}) : super(players: players);

  @override
  void onItemExposed(Set<int> indexes) {
    // 同屏内最前的播放器索引
    final firstExposedIndex = indexes.reduce(min);
    // 解决冲突暂停同屏内最前的播放器以外的全部播放器
    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      if (i != firstExposedIndex && player.playerController.value.isPlaying) {
        player.playerController.pause();
      }
    }
    players[firstExposedIndex].playerController.play();
  }

  @override
  void onItemDismiss(Set<int> indexes) {
    for (var index in indexes) {
      final player = players[index];
      if (player.playerController.value.isPlaying) {
        player.pause(reset: true);
      }
    }
  }
}
