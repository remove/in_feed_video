import 'dart:math';

import 'video_proxy_controller.dart';

/// Item曝光对于播放器的控制
class FeedVideosController {
  FeedVideosController({required this.players});

  final List<VideoProxyController> players;

  void onItemExposed(Set<int> indexes) {
    final firstExposedIndex = indexes.reduce(min);
    // 暂停除目标播放器外的全部播放器
    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      if (i != firstExposedIndex && player.playerController.value.isPlaying) {
        player.playerController.pause();
      }
    }
    players[firstExposedIndex].playerController.play();
  }
}
