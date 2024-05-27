import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_downloader/screens/download_screen.dart';
import 'package:video_downloader/utils/custom_colors.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

import 'home_screen.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {

  final PageController _pageController = PageController();
  final FileManagerController _controller = FileManagerController();
  List<VideoData> _videoData = [];
  List<FileSystemEntity> _downloads = [];
  int _selectIndex =0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  Future<void> _getDownloads() async {
    setState(() {
      _downloads = [];
      _videoData = [];
    });
    final videoInfo = FlutterVideoInfo();
    final  directory = await getApplicationCacheDirectory();
    final dir = directory.path;
    final myDir = Directory(dir);
    List<FileSystemEntity> _folders =
        myDir.listSync(recursive: true, followLinks: false);
    List<FileSystemEntity> _data = [];
    
    for (var item in _folders) {
      if (item.path.contains('mp4')) {
        _data.add(item);
        var _info = await videoInfo.getVideoInfo(item.path);
        _videoData.add(_info!);
      }  
    }
    setState(() {
      _downloads = _data;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backGround,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColors.backGround,
        elevation: 0,
        title: Text(
          'AB Video Downloader',
          style: GoogleFonts.poppins(
            fontSize: 26,
            color: CustomColors.white,
            fontWeight: FontWeight.w500
          ),
        ),
      ),

      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(
            onDownloadCompleted: () {
              _getDownloads();
              },
          ),
          
          DownloadScreen(
              videoData: _videoData,
              downloads: _downloads,
              onVideoDeleted: () => _getDownloads(),
              onCardTap: (index) {
                setState(() {
                  _selectIndex = 2;
                });
                _pageController.jumpToPage(_selectIndex);
              }
          ),
          SizedBox(),
          SizedBox(),
        ],
      ),

      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: CustomColors.backGround,
        bottomPadding: 12,
        waterDropColor: CustomColors.primary,
        inactiveIconColor: CustomColors.primary,
        iconSize: 28.w,

        selectedIndex: _selectIndex,
        onItemSelected: (index) {
          setState(() {
            _selectIndex = index;
          });

          _pageController.jumpToPage(_selectIndex);
        },
        barItems: [
          BarItem(
              filledIcon: Icons.home,
              outlinedIcon: Icons.home_outlined
          ),
          BarItem(
              filledIcon: Icons.file_download,
              outlinedIcon: Icons.file_download_outlined
          ),
          BarItem(
              filledIcon: Icons.video_library_rounded,
              outlinedIcon: Icons.video_library_outlined
          ),
          BarItem(
              filledIcon: Icons.info,
              outlinedIcon: Icons.info_outline
          ),
        ],
      ),

    );
  }
}
