import 'package:in_feed_video/in_feed_video.dart';
import 'package:in_feed_video/src/abstract_video_controller.dart';
import 'package:rxdart/rxdart.dart';

import 'video_proxy_controller.dart';

class FeedVideosStateContainer {
  FeedVideosStateContainer({
    required this.debounceTime,
    required this.exposeFactor,
    required this.proxyControllers,
    required this.videosController,
  });

  final Duration debounceTime;

  final double exposeFactor;

  /// item曝光事件流
  final PublishSubject<int> acceptExposedAction = PublishSubject();

  /// item消失事件流
  final PublishSubject<int> acceptDismissAction = PublishSubject();

  /// 列表滚动偏移流
  final PublishSubject<double> offsetPublishStream = PublishSubject();

  /// 代理播放器实例列表
  final List<VideoProxyController> proxyControllers;

  /// 视频曝光控制器
  final AbstractVideosController videosController;
}
