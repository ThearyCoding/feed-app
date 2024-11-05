import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/preload_bloc.dart';


class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.isLoading,
    required this.controller,
    required this.isPaused,
  });

  final bool isLoading;
  final BetterPlayerController controller;
  final bool isPaused;

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  String _speedFeedback = "";
  bool _isLongPressing = false;

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _speedFeedback = "Speed: ${speed}x";
    });
    widget.controller.setSpeed(speed);
  }

  void _clearFeedback() {
    setState(() {
      _speedFeedback = "";
      _isLongPressing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<PreloadBloc>().add(const PreloadEvent.togglePlayPause());
      },
      onLongPressStart: (_) {
        setState(() {
          _isLongPressing = true;
        });
        _setPlaybackSpeed(2.0);
      },
      onLongPressEnd: (_) {
        _clearFeedback();
        _setPlaybackSpeed(1.0);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.videoPlayerController!.value.aspectRatio,
              child: BetterPlayer(controller: widget.controller),
            ),
          ),
          if (widget.isLoading)
            const Positioned.fill(
              child: Center(
                child:
                    CupertinoActivityIndicator(color: Colors.white, radius: 8),
              ),
            ),
          if (widget.isPaused)
            Positioned(
              child: Icon(
                CupertinoIcons.play_arrow_solid,
                size: 64.0,
                color: Colors.white.withOpacity(.5),
              ),
            ),
          if (_isLongPressing)
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _speedFeedback,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
