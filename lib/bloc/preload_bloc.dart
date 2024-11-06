import 'dart:async';
import 'dart:developer';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../core/constants.dart';
import '../main.dart';
import '../services/api/api_service.dart';
part 'preload_bloc.freezed.dart';
part 'preload_event.dart';
part 'preload_state.dart';
@injectable
@prod
class PreloadBloc extends Bloc<PreloadEvent, PreloadState> {
  PreloadBloc() : super(PreloadState.initial()) {
    on(_mapEventToState);
  }

  void _mapEventToState(PreloadEvent event, Emitter<PreloadState> emit) async {
    await event.map(
      setLoading: (e) {
        emit(state.copyWith(isLoading: true));
      },
      getVideosFromApi: (e) async {
        final List<String> urls = await ApiService.getVideos();
        state.urls.addAll(urls);

        // Immediately initialize and play the first video
        await _initializeControllerAtIndex(0);
        _playControllerAtIndex(0);

        // Concurrently initialize the next few videos in the background
        _initializeControllers([1, 2, 3]);

        emit(state.copyWith(reloadCounter: state.reloadCounter + 1));
      },
      onVideoIndexChanged: (e) {
        final bool shouldFetch = (e.index + kPreloadLimit) % kNextLimit == 0 &&
            state.urls.length == e.index + kPreloadLimit;

        if (shouldFetch) {
          createIsolate(e.index);
        }

        if (e.index > state.focusedIndex) {
          _playNext(e.index);
        } else {
          _playPrevious(e.index);
        }

        emit(state.copyWith(focusedIndex: e.index));
      },
      updateUrls: (e) {
        state.urls.addAll(e.urls);
        _initializeControllers([state.focusedIndex + 1, state.focusedIndex + 2, state.focusedIndex + 3]);

        emit(state.copyWith(
            reloadCounter: state.reloadCounter + 1, isLoading: false));
        log('🚀 NEW VIDEOS ADDED');
      },
      togglePlayPause: (value) {
        if (state.focusedIndex >= 0 && state.focusedIndex < state.urls.length) {
          final controller = state.controllers[state.focusedIndex]!;

          if (controller.value.isPlaying) {
            controller.pause();
            emit(state.copyWith(isPlaying: false));
          } else {
            controller.play();
            emit(state.copyWith(isPlaying: true));
          }
        }
      },
    );
  }

  Future<void> _initializeControllers(List<int> indices) async {
    // Initialize controllers in the background, but do not await here
    for (final index in indices) {
      _initializeControllerAtIndex(index);
    }
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (state.urls.length > index && index >= 0 && !state.controllers.containsKey(index)) {
      final controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(state.urls[index]),
        cacheKey: state.urls[index],
      );

      state.controllers[index] = controller;
      await controller.initialize();
      log('🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final controller = state.controllers[index]!;
      controller.play();
      controller.setLooping(true);
      log('🚀 PLAYING $index');
    }
  }

  void _playNext(int index) {
    // Stop and dispose of controllers for videos that are too far behind
    _stopControllerAtIndex(index - 1);
    _disposeControllerAtIndex(index - 2);  // Dispose of the video that is 2 steps behind

    _playControllerAtIndex(index);

    // Concurrently initialize future videos
    _initializeControllers([index + 1, index + 2, index + 3]);
  }

  void _playPrevious(int index) {
    // Stop and dispose of controllers for videos that are too far ahead
    _stopControllerAtIndex(index + 1);
    _disposeControllerAtIndex(index + 2);  // Dispose of the video that is 2 steps ahead

    _playControllerAtIndex(index);

    // Concurrently initialize past videos
    _initializeControllers([index - 1, index - 2, index - 3]);
  }

  void _stopControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final controller = state.controllers[index]!;
      controller.pause();
      controller.seekTo(const Duration());
      log('🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0 && (index < state.focusedIndex - 3 || index > state.focusedIndex + 3)) {
      final controller = state.controllers.remove(index);
      controller?.dispose();
      log('🚀 DISPOSED $index');
    }
  }
}
