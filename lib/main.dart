
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'bloc/preload_bloc.dart';
import 'core/build_context.dart';
import 'core/constants.dart';
import 'injection.dart';
import 'services/api/api_service.dart';
import 'services/api/navigation_service.dart';
import 'tiktok_main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjection(Environment.prod);
  runApp(MyApp());
}

/// Isolate to fetch videos in the background so that the video experience is not disturbed.
/// Without isolate, the video will be paused whenever there is an API call
/// because the main thread will be busy fetching new video URLs.
///
/// https://blog.codemagic.io/understanding-flutter-isolates/
Future createIsolate(int index) async {
  // Set loading to true
  BlocProvider.of<PreloadBloc>(context, listen: false)
      .add(const PreloadEvent.setLoading());

  ReceivePort mainReceivePort = ReceivePort();

  Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  ReceivePort isolateResponseReceivePort = ReceivePort();

  isolateSendPort.send([index, isolateResponseReceivePort.sendPort]);

  final isolateResponse = await isolateResponseReceivePort.first;
  final urls = isolateResponse;

  // Update new urls
  BlocProvider.of<PreloadBloc>(context, listen: false)
      .add(PreloadEvent.updateUrls(urls));
}

void getVideosTask(SendPort mySendPort) async {
  ReceivePort isolateReceivePort = ReceivePort();

  mySendPort.send(isolateReceivePort.sendPort);

  await for (var message in isolateReceivePort) {
    if (message is List) {
      final int index = message[0];

      final SendPort isolateResponseSendPort = message[1];

      final List<String> urls =
          await ApiService.getVideos(id: index + kPreloadLimit);

      isolateResponseSendPort.send(urls);
    }
  }
}

class MyApp extends StatelessWidget {
  final NavigationService _navigationService = getIt<NavigationService>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PreloadBloc>()..add(const PreloadEvent.getVideosFromApi()),
      child: MaterialApp(
        key: _navigationService.navigationKey,
        debugShowCheckedModeBanner: false,
        home: const TikTokStyleApp(),
      ),
    );
  }
}


// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'pages/homePage.dart';
// import 'style/style.dart';

// void main() {
//   /// 自定义报错页面
//   if (kReleaseMode) {
//     ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
//       debugPrint(flutterErrorDetails.toString());
//       return const Material(
//         child: Center(
//             child: Text(
//           "发生了没有处理的错误\n请通知开发者",
//           textAlign: TextAlign.center,
//         )),
//       );
//     };
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Tiktok',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         hintColor: Colors.white,
//         // accentColor: Colors.white,
//         primaryColor: ColorPlate.orange,
//         // primaryColorBrightness: Brightness.dark,
//         scaffoldBackgroundColor: ColorPlate.back1,
//         dialogBackgroundColor: ColorPlate.back2,
//         // accentColorBrightness: Brightness.light,
//         textTheme: const TextTheme(
//           bodyLarge: StandardTextStyle.normal,
//         ),
//       ),
//       home: HomePage(),
//     );
//   }
// }
