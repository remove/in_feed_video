import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'feed_video_state_provider.dart';
import 'feed_videos_state_container.dart';
import 'video_proxy_controller.dart';

typedef ExposedBuilder = Widget Function(
    BuildContext context, VideoProxyController videoProxyController);

/// Item曝光上报
/// 接收[FeedVideosStateContainer.offsetPublishStream]并计算Item自身曝光后上报至
/// [FeedVideosStateContainer.acceptExposedAction]由[FeedVideosObserver]监听
/// 此控件生命周期管理[VideoProxyController]初始化与销毁
class VideoExposedReport extends StatefulWidget {
  const VideoExposedReport({
    Key? key,
    required this.index,
    required this.builder,
    this.debugLabel,
  }) : super(key: key);
  final int index;
  final ExposedBuilder builder;
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
    // 接收列表Offset，防抖后计算曝光
    offsetStream = container.offsetPublishStream
        .debounceTime(const Duration(milliseconds: 250))
        .listen((offset) => calculationExposed(offset));
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
    // 曝光时上报到队列由[FeedVideosController]消费
    container.acceptExposedAction.add(widget.index);
  }

  void onDismiss() {}

  @override
  void dispose() {
    offsetStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ServicesBinding.instance!.addPostFrameCallback((timeStamp) {
      getViewPortAndBox();
    });
    return widget.builder(context, proxyController);
  }
}
