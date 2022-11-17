import 'package:flutter/widgets.dart';

import 'feed_videos_state_container.dart';

/// 储存曝光Item和接收曝光事件
class FeedVideosContainerProvider extends InheritedWidget {
  const FeedVideosContainerProvider({
    Key? key,
    required Widget child,
    required this.container,
  }) : super(key: key, child: child);

  final FeedVideosStateContainer container;

  static FeedVideosStateContainer of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<
            FeedVideosContainerProvider>() as FeedVideosContainerProvider)
        .container;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
