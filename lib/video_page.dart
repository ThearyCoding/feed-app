import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'bloc/preload_bloc.dart';
import 'utils/custom_linear_progress_indicator.dart';

import 'video_widget.dart';

class VideoPage extends StatefulWidget {
  final Function(CachedVideoPlayerPlusController) onControllerChanged;

  const VideoPage({super.key, required this.onControllerChanged});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isBuffering = false;
  bool _isMuted = false;

  void _updateProgress(CachedVideoPlayerPlusController controller) {
    if (mounted) {
      setState(() {
        _position = controller.value.position;
        _duration = controller.value.duration;
        _isBuffering = controller.value.isBuffering;
      });
    }
  }

  void _toggleMute(CachedVideoPlayerPlusController controller) {
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreloadBloc, PreloadState>(
      builder: (context, state) {
        return PageView.builder(
          itemCount: state.urls.length,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            BlocProvider.of<PreloadBloc>(context, listen: false)
                .add(PreloadEvent.onVideoIndexChanged(index));
          },
          itemBuilder: (context, index) {
            final bool isLoading =
                (state.isLoading && index == state.urls.length - 1);
            final controller = state.controllers[index];

            if (controller == null) {
              return const SizedBox();
            }
            widget.onControllerChanged(controller);
            final bool isPaused = !controller.value.isPlaying;
            final thumbRadius = isPaused ? 5.0 : 0.0;

            controller.addListener(() => _updateProgress(controller));

            return isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      VideoWidget(
                        isLoading: isLoading,
                        controller: controller,
                        isPaused: isPaused,
                      ),
                      Positioned(
                        right: 16,
                        bottom: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    AssetImage('assets/no-profile.png'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () async {
                                await CachedVideoPlayerPlusController
                                    .clearAllCache();

                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Cached Video is clean all")));
                              },
                              child: const Column(
                                children: [
                                  Icon(Icons.favorite,
                                      color: Colors.red, size: 32),
                                  SizedBox(height: 4),
                                  Text("1.2k",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {},
                              child: const Column(
                                children: [
                                  Icon(Icons.comment,
                                      color: Colors.white, size: 32),
                                  SizedBox(height: 4),
                                  Text("345",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {},
                              child: const Column(
                                children: [
                                  Icon(Icons.share,
                                      color: Colors.white, size: 32),
                                  SizedBox(height: 4),
                                  Text("Share",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _toggleMute(controller),
                              child: Icon(
                                _isMuted ? Icons.volume_off : Icons.volume_up,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        bottom: 80,
                        left: 16,
                        right: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Theary Coding",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Sample Video Description #trending #example",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 70,
                          left: 16,
                          right: 16,
                          child: _isBuffering
                              ? const CustomLinearProgressIndicator()
                              : ProgressBar(
                                  thumbGlowRadius: 10.0,
                                  barCapShape: BarCapShape.square,
                                  progress: _position,
                                  total: _duration,
                                  onSeek: (duration) {
                                    controller.seekTo(duration);
                                  },
                                  progressBarColor: Colors.white,
                                  baseBarColor: Colors.white.withOpacity(0.24),
                                  bufferedBarColor:
                                      Colors.white.withOpacity(0.24),
                                  thumbColor: Colors.white,
                                  barHeight: 3.0,
                                  thumbRadius: thumbRadius,
                                  timeLabelLocation: TimeLabelLocation.none,
                                ))
                    ],
                  );
          },
        );
      },
    );
  }
}
