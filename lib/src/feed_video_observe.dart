import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:in_feed_video/src/abstract_video_controller.dart';
import 'package:rxdart/rxdart.dart';

import 'feed_video_state_provider.dart';
import 'feed_videos_state_container.dart';

/// Feed流观察，发布列表Offset
/// 观察视频Item，接收Item曝光事件调用播放器控制器
class FeedVideosObserver extends StatefulWidget {
  const FeedVideosObserver({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  State<FeedVideosObserver> createState() => _FeedVideosObserverState();
}

class _FeedVideosObserverState extends State<FeedVideosObserver> {
  late FeedVideosStateContainer container;
  late AbstractVideosController controller;

  @override
  void didChangeDependencies() {
    container = FeedVideosContainerProvider.of(context);
    controller = container.videosController;
    //接收曝光事件，缓冲产生曝光队列后使用[AbstractVideosController.onItemExposed]处理
    container.acceptExposedAction
        .bufferTime(container.debounceTime)
        .where((event) => event.isNotEmpty)
        .listen(
      (event) {
        // 消费曝光的Item
        controller.onItemExposed(event.toSet());
      },
    );
    //接收消失事件，缓冲产生曝光队列由[AbstractVideosController.onItemDismiss]处理
    container.acceptDismissAction
        .bufferTime(container.debounceTime)
        .where((event) => event.isNotEmpty)
        .listen(
      (event) {
        // 消费曝光的Item
        controller.onItemDismiss(event.toSet());
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final publish = container.offsetPublishStream;
    ServicesBinding.instance!.addPostFrameCallback((timeStamp) {
      // 构建后发布一次为0的Offset
      publish.add(0);
    });
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        publish.add(notification.metrics.pixels);
        return true;
      },
      child: widget.child,
    );
  }
}
