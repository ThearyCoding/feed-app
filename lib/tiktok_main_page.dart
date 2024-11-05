import 'dart:developer';
import 'package:better_player/better_player.dart';
import '../../upload_video.dart';
import 'package:flutter/material.dart';
import 'video_page.dart';

class TikTokStyleApp extends StatefulWidget {
  const TikTokStyleApp({super.key});

  @override
  TikTokStyleAppState createState() => TikTokStyleAppState();
}

class TikTokStyleAppState extends State<TikTokStyleApp> {
  int _selectedIndex = 0;

  BetterPlayerController?
      _currentController;

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _currentController?.pause();
    }
    
    setState(() {
      _selectedIndex = index;
    });
    if(_selectedIndex == 0){
      _currentController!.play();

      log("Player video selected");
    }
  }

  @override
  void dispose() {
    _currentController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: _buildBottomNavigationBar(),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              VideoPage(
                onControllerChanged: (controller) {
                  _currentController = controller;
                },
              ),
              const Placeholder(),
              const UploadVideo(),
              const Placeholder(),
              const Placeholder(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Friends'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box, size: 32), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
