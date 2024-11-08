part of 'preload_bloc.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class PreloadState with _$PreloadState {
  factory PreloadState({
    required List<String> urls,
    required Map<int, CachedVideoPlayerPlusController?> controllers,
    required int focusedIndex,
    required int reloadCounter,
    required bool isLoading,
    required bool isPlaying,
  }) = _PreloadState;

  factory PreloadState.initial() => PreloadState(
        focusedIndex: 0,
        reloadCounter: 0,
        isLoading: false,
        urls: [],
        controllers: {},
        isPlaying: false,
      );
}
