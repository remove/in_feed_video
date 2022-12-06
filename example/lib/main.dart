import 'package:flutter/material.dart';
import 'package:in_feed_video/in_feed_video.dart';
import 'package:video_player/video_player.dart';

import 'video_source.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<VideoProxyController> proxyControllers = [];

  @override
  void initState() {
    for (var element in VideoSource.data) {
      proxyControllers.add(
        VideoProxyController(
          () => VideoPlayerController.network(element),
          postVideo: PostVideo(thumbUrl: '', videoUrl: element),
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InFeedVideos(
          proxyControllers: proxyControllers,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 500),
            itemCount: proxyControllers.length,
            itemBuilder: (context, index) => Column(
              children: [
                VideoExposedReport(
                  index: index,
                  builder: (context, proxyController) {
                    return Stack(
                      children: [
                        AeroBox(controller: proxyController),
                        Text(index.toString()),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AeroBox extends StatefulWidget {
  const AeroBox({Key? key, required this.controller}) : super(key: key);
  final VideoProxyController controller;

  @override
  State<AeroBox> createState() => _AeroBoxState();
}

class _AeroBoxState extends State<AeroBox> {
  bool playerInitialized = false;

  VideoPlayerController get playerController =>
      widget.controller.playerController;

  @override
  void initState() {
    widget.controller.init();
    playerController.addListener(() {
      if (playerController.value.isInitialized != playerInitialized) {
        playerInitialized = playerController.value.isInitialized;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (playerController.value.isPlaying) {
                playerController.pause();
              } else {
                playerController.play();
              }
            },
            child: AspectRatio(
              aspectRatio: playerController.value.aspectRatio,
              child: VideoPlayer(playerController),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: VideoProgressIndicator(
                widget.controller.playerController,
                allowScrubbing: true,
              ),
            ),
          )
        ],
      ),
    );
  }
}
