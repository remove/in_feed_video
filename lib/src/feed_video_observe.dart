import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'feed_video_controller.dart';
import 'feed_video_state_provider.dart';
import 'feed_videos_state_container.dart';

/// 视频Item观察，接收Item曝光事件调用播放器控制器
class FeedVideosObserver extends StatefulWidget {
  const FeedVideosObserver({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);
  final Widget child;
  final FeedVideosController controller;

  @override
  State<FeedVideosObserver> createState() => _FeedVideosObserverState();
}

class _FeedVideosObserverState extends State<FeedVideosObserver> {
  late FeedVideosStateContainer container;

  @override
  void didChangeDependencies() {
    container = FeedVideosContainerProvider.of(context);
    //接收曝光事件，防抖处理后调用[FeedVideosController]处理
    container.acceptExposedAction.debounceTime(container.debounceTime).listen(
      (value) {
        final indexes = container.exposedPlayerIndex;
        if (indexes.isNotEmpty) {
          widget.controller.onItemExposed(indexes);

          // 消费曝光的Item后清空
          indexes.clear();
        }
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final publish = container.offsetPublishStream;
    ServicesBinding.instance!.addPostFrameCallback((timeStamp) {
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
