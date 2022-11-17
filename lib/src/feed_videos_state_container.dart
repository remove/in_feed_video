import 'package:rxdart/rxdart.dart';

import 'video_proxy_controller.dart';

class FeedVideosStateContainer {
  FeedVideosStateContainer({
    required this.debounceTime,
    required this.exposeFactor,
    required this.proxyControllers,
  });

  final Duration debounceTime;

  final double exposeFactor;

  /// item曝光事件流
  final PublishSubject<int> acceptExposedAction = PublishSubject();

  /// 列表滚动偏移流
  final PublishSubject<double> offsetPublishStream = PublishSubject();

  /// 代理播放器实例列表
  final List<VideoProxyController> proxyControllers;
}
