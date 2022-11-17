import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'feed_video_state_provider.dart';
import 'feed_videos_state_container.dart';
import 'video_proxy_controller.dart';

/// Item曝光上报
/// 接收[ListViewScrollOffsetPublish.offsetStream]并计算Item自身曝光后上报给
/// [ListViewVideoStateProvider.exposedPlayerIndex]后，通知由[VideoObserver]监听
/// 的[ListViewVideoStateProvider.acceptAction]接收到事件后调用
/// [ListViewVideoController]进行播放器控制
class VideoExposedReport extends StatefulWidget {
  const VideoExposedReport({
    Key? key,
    required this.index,
    required this.child,
    this.debugLabel,
  }) : super(key: key);
  final int index;
  final Widget child;
  final String? debugLabel;

  @override
  State<VideoExposedReport> createState() => _VideoExposedReportState();
}

class _VideoExposedReportState extends State<VideoExposedReport> {
  late FeedVideosStateContainer container;
  late StreamSubscription<double> offsetStream;
  RenderObject? itemBox;
  RenderAbstractViewport? viewPortObj;

  VideoProxyController get proxyController =>
      container.proxyControllers[widget.index];

  @override
  void didChangeDependencies() {
    container = FeedVideosContainerProvider.of(context);
    offsetStream = container.offsetPublishStream
        .debounceTime(const Duration(milliseconds: 250))
        .listen((offset) => calculationExposed(offset));
    proxyController.init();
    super.didChangeDependencies();
  }

  getViewPortAndBox() {
    if (itemBox == null) {
      itemBox = context.findRenderObject() as RenderBox;
      viewPortObj = RenderAbstractViewport.of(itemBox);
    }
  }

  calculationExposed(double offset) {
    if (!mounted) return;
    final viewPortHeight = viewPortObj!.paintBounds.height;
    final itemOffsetToReveal = viewPortObj!.getOffsetToReveal(itemBox!, 0);
    // 视窗范围
    final viewPortRange = [offset, offset + viewPortHeight];
    // item可以曝光的视窗范围
    final itemExposedRange = [
      itemOffsetToReveal.offset,
      itemOffsetToReveal.offset + itemOffsetToReveal.rect.height
    ];
    // item曝光于视窗范围的交集
    final interSelection = [
      max<double>(viewPortRange[0], itemExposedRange[0]),
      min<double>(viewPortRange[1], itemExposedRange[1]),
    ];
    // item可见高度
    final itemVisibleSize = max(0, interSelection[1] - interSelection[0]);

    final exposed = itemVisibleSize >
        (itemBox as RenderBox).size.height * container.exposeFactor;

    if (exposed) {
      onExposed();
    } else {
      onDismiss();
    }

    if (widget.debugLabel != null) {
      debugPrint(
        'debugLabel:${widget.debugLabel},'
        ' viewPortRange:$viewPortRange,'
        ' itemExposedRange:$itemExposedRange,'
        ' interSelection:$interSelection,'
        ' itemVisibleSize:$itemVisibleSize,'
        ' exposed: $exposed',
      );
    }
  }

  void onExposed() {
    container
      ..exposedPlayerIndex.add(widget.index)
      ..acceptExposedAction.add(widget.index);
  }

  void onDismiss() {}

  @override
  void dispose() {
    offsetStream.cancel();
    proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ServicesBinding.instance!.addPostFrameCallback((timeStamp) {
      getViewPortAndBox();
    });
    return widget.child;
  }
}
