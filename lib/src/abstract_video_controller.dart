import 'package:in_feed_video/in_feed_video.dart';

abstract class AbstractVideosController {
  AbstractVideosController({required this.players});

  final List<VideoProxyController> players;

  void onItemExposed(Set<int> indexes);

  void onItemDismiss(Set<int> indexes);
}
