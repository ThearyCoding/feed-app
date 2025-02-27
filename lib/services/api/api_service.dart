import '../../core/constants.dart';

class ApiService {
  static final List<String> _videos = [
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video01.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video02.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video03.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video04.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video05.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video06.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video07.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video08.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video09.mp4",
    //
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video10.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video11.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video12.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video13.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video14.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video15.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video16.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video17.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video18.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video19.mp4",
    //
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video20.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video21.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video22.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video23.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video24.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video25.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video26.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video27.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video28.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video29.mp4",
    //
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video30.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video31.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video32.mp4",
    "https://raw.githubusercontent.com/duythien0912/sample_short_video/main/mp4/video33.mp4",
  ];

  /// Simulate api call
  static Future<List<String>> getVideos({int id = 0}) async {
    // No more videos
    if ((id >= _videos.length)) {
      return [];
    }

    await Future.delayed(const Duration(seconds: kLatency));

    if ((id + kNextLimit >= _videos.length)) {
      return _videos.sublist(id, _videos.length);
    }

    return _videos.sublist(id, id + kNextLimit);
  }
}
