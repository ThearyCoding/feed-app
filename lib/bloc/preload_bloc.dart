import 'dart:async';
import 'dart:developer';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../core/constants.dart';
import '../main.dart';
import '../services/api/api_service.dart';
import 'package:better_player/better_player.dart';
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
        // Fetch first 5 videos from API
        final List<String> urls = await ApiService.getVideos();
        state.urls.addAll(urls);

        // Initialize and play the first video
        await _initializeControllerAtIndex(0);
        _playControllerAtIndex(0);

        // Preload the second video
        await _initializeControllerAtIndex(1);

        emit(state.copyWith(reloadCounter: state.reloadCounter + 1));
      },
      onVideoIndexChanged: (e) {
        final bool shouldFetch = (e.index + kPreloadLimit) % kNextLimit == 0 &&
            state.urls.length == e.index + kPreloadLimit;

        if (shouldFetch) {
          createIsolate(e.index);
        }

        // Next / Prev video decision
        if (e.index > state.focusedIndex) {
          _playNext(e.index);
        } else {
          _playPrevious(e.index);
        }

        emit(state.copyWith(focusedIndex: e.index));
      },
      updateUrls: (e) {
        state.urls.addAll(e.urls);
        _initializeControllerAtIndex(state.focusedIndex + 1);
        emit(state.copyWith(
            reloadCounter: state.reloadCounter + 1, isLoading: false));
        log('🚀 NEW VIDEOS ADDED');
      },
      togglePlayPause: (_TogglePlayPause value) {
        if (state.focusedIndex >= 0 && state.focusedIndex < state.urls.length) {
          final BetterPlayerController controller =
              state.controllers[state.focusedIndex]!;

          if (controller.isPlaying() ?? false) {
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

  void _playNext(int index) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future _initializeControllerAtIndex(int index) async {
    if (state.urls.length > index && index >= 0) {
      const BetterPlayerConfiguration betterPlayerConfiguration =
          BetterPlayerConfiguration(
        autoPlay: false,
        looping: true,
        autoDispose: true,
      );

      // Create the BetterPlayerController with caching and buffering configuration
      final BetterPlayerController controller = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          state.urls[index],
          cacheConfiguration: const BetterPlayerCacheConfiguration(
            useCache: true,
            preCacheSize: 1024 * 1024 * 5, 
            maxCacheSize: 1024 * 1024 * 100,
          ),
          bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 8000,
            maxBufferMs: 10000,
          ),
        ),
      );

      state.controllers[index] = controller;

      controller.addEventsListener((BetterPlayerEvent event){
        if(event.betterPlayerEventType == BetterPlayerEventType.initialized){
          controller.setOverriddenAspectRatio(
            controller.videoPlayerController!.value.aspectRatio,
          );
        }
      });
      

      // Precache a portion of the video for faster initial loading
      await controller.preCache(controller.betterPlayerDataSource!);

      log('🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final BetterPlayerController controller = state.controllers[index]!;
      controller.play();
      log('🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final BetterPlayerController controller = state.controllers[index]!;

      // Stop playback
      controller.pause();
      controller.seekTo(const Duration(seconds: 0));

      if (controller.betterPlayerDataSource != null) {
        controller.stopPreCache(controller.betterPlayerDataSource!);
        log('🚀 STOPPED PRECACHE $index');
      }

      log('🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final BetterPlayerController? controller = state.controllers[index];
      controller?.dispose();
      if (controller != null) {
        state.controllers.remove(controller);
      }
      log('🚀 DISPOSED $index');
    }
  }
}
