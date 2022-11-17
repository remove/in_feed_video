import 'dart:async';

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

typedef ControllerBuilder<T> = T Function();

class VideoProxyController {
  VideoPlayerController? _playController;

  final PostVideo postVideo;

  final ControllerBuilder<VideoPlayerController> _builder;

  VideoProxyController(
    ControllerBuilder<VideoPlayerController> builder, {
    required this.postVideo,
  }) : _builder = builder;

  VideoPlayerController get playerController {
    return _playController ??= _builder.call();
  }

  bool get prepared => _prepared;
  bool _prepared = false;

  bool get banned => _banned;
  bool _banned = false;

  Future<void> dispose() async {
    try {
      await playerController.dispose();
    } catch (_) {}
    _prepared = false;
    _playController = null;
  }

  Future<void> init() async {
    if (_prepared) return;
    try {
      await playerController.initialize();
    } on PlatformException catch (e) {
      _banned = e.code == "403";
    } catch (_) {}
    await playerController.setLooping(true);
    _prepared = true;
  }

  Future<void> pause({bool reset = false}) async {
    if (!_prepared) return;
    await playerController.pause();
    if (reset) await playerController.seekTo(Duration.zero);
  }

  Future<void> play(int index) async {
    await init();
    if (!_prepared) return;
    unawaited(playerController.play());
  }
}

class PostVideo {
  final String? videoUrl;
  final String? thumbUrl;

  PostVideo({
    this.videoUrl,
    this.thumbUrl,
  });
}
