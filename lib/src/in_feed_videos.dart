import 'package:flutter/widgets.dart';

import 'feed_video_observe.dart';
import 'feed_video_state_provider.dart';
import 'feed_videos_state_container.dart';
import 'video_proxy_controller.dart';

class InFeedVideos extends StatefulWidget {
  const InFeedVideos({
    Key? key,
    required this.proxyControllers,
    required this.child,
    this.debounceTime = const Duration(milliseconds: 250),
    this.exposeFactor = 0.5,
  }) : super(key: key);
  final List<VideoProxyController> proxyControllers;
  final Widget child;
  final Duration debounceTime;
  final double exposeFactor;

  @override
  State<InFeedVideos> createState() => _InFeedVideosState();
}

class _InFeedVideosState extends State<InFeedVideos> {
  late FeedVideosStateContainer container;

  @override
  void initState() {
    container = FeedVideosStateContainer(
      proxyControllers: widget.proxyControllers,
      debounceTime: widget.debounceTime,
      exposeFactor: widget.exposeFactor,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FeedVideosContainerProvider(
      container: container,
      child: FeedVideosObserver(
        child: widget.child,
      ),
    );
  }
}
