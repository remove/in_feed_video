import 'package:flutter/widgets.dart';
import 'package:in_feed_video/in_feed_video.dart';
import 'package:in_feed_video/src/abstract_video_controller.dart';

class InFeedVideos extends StatefulWidget {
  const InFeedVideos({
    Key? key,
    required this.proxyControllers,
    required this.child,
    this.debounceTime = const Duration(milliseconds: 250),
    this.exposeFactor = 0.5,
    this.videosController,
  }) : super(key: key);
  final List<VideoProxyController> proxyControllers;
  final Widget child;
  final Duration debounceTime;
  final double exposeFactor;
  final AbstractVideosController? videosController;

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
      videosController: widget.videosController ??
          DefaultBehaviorVideosController(players: widget.proxyControllers),
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
