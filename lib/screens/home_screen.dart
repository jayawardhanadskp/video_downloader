import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_downloader/models/video_download_model.dart';
import 'package:video_downloader/repository/video_downloader_repository.dart';
import 'package:video_downloader/utils/custom_colors.dart';

import '../models/video_quality_model.dart';
import '../widgets/video_quality_card.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, required this.onDownloadCompleted});

  final VoidCallback onDownloadCompleted;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  var _progressValue = 0.0;
  var _isDownloading = false;
  List<VideoQualityModel>? _qualites = [];
  VideoDownloadModel? _video;
  bool _isLoading = false;
  int _selectedQualityIndex = 0;
  String _fileName = '';
  bool _isSearching = false;
  VideoType _videoType = VideoType.none;

  IconData? get _getBrandIcon {
    switch (_videoType) {
      case VideoType.facebook:
        return FontAwesome.facebook;
      case VideoType.twitter:
        return FontAwesome.twitter;
      case VideoType.youtube:
        return FontAwesome.youtube_play;
      case VideoType.instagram:
        return FontAwesome.instagram;
      case VideoType.tiktok:
        return IconData(0xf058c, fontFamily: 'MaterialIcons');
      default:
        return null;
    }
  }

  String? get _getFilePrefix {
    switch (_videoType) {
      case VideoType.facebook:
        return 'Facebook';
      case VideoType.twitter:
        return 'Twitter';
      case VideoType.youtube:
        return 'YouTube';
      case VideoType.instagram:
        return 'Instagram';
      case VideoType.tiktok:
        return 'TikTok';
      default:
        return null;
    }
  }

  void _setVideoType(String url) {
    if (url.isEmpty) {
      setState(() => _videoType = VideoType.none);
    } else if (url.contains('facebook.com') || url.contains('fb.watch')) {
      setState(() => _videoType = VideoType.facebook);
    } else if (url.contains('youtube.com') || url.contains('youtu.be')) {
      setState(() => _videoType = VideoType.youtube);
    } else if (url.contains('twitter.com')) {
      setState(() => _videoType = VideoType.twitter);
    } else if (url.contains('instagram.com')) {
      setState(() => _videoType = VideoType.instagram);
    } else if (url.contains('tiktok.com')) {
      setState(() => _videoType = VideoType.tiktok);
    } else {
      setState(() => _videoType = VideoType.none);
    }
  }

  _showSnackBar(String title, int duration) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: duration),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.w),
        ),
        margin: EdgeInsets.all(15.w),
        backgroundColor: CustomColors.primary,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: CustomColors.white,
              size: 30.w,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
                child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: CustomColors.white,
                fontWeight: FontWeight.w500,
              ),
            ))
          ],
        )));
  }

  Future<void> _performDownloading(String url) async {
    Dio dio = Dio();
    var permissions = await [Permission.storage].request();

    if (permissions[Permission.storage]!.isGranted) {
      var dir = await getApplicationDocumentsDirectory();

      setState(() {
        _fileName =
            '/$_getFilePrefix-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.mp4';
      });

      var path = dir.path + _fileName;

      try {
        setState(() => _isDownloading = true);
        await dio.download(
          url,
          path,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() => _progressValue = (received / total * 100));
            }
          },
          deleteOnError: true,
        ).then((_) async {
          widget.onDownloadCompleted();

          setState(() {
            _isDownloading = false;
            _progressValue = 0.0;
            _videoType = VideoType.none;
            _isLoading = false;
            _qualites = [];
            _video = null;
          });
          _controller.text = '';
          _showSnackBar('Video downloaded successfully.', 2);
        });
      } on DioError catch (e) {
        setState(() {
          _videoType = VideoType.none;
          _isDownloading = false;
          _qualites = [];
          _video = null;
        });
        _showSnackBar('Oops! ${e.message}', 2);
      }
    } else {
      _showSnackBar('No permission to read & write.', 2);
    }
  }

  Future<void> _onLinkPasted(String url) async {
    var _response = await VideoDownloaderRepository().getAvalableVideos(url);
    setState(() => _video = _response);
    if (_video != null) {
      for (var _quality in _video!.videos!) {
        _qualites!.add(_quality);
      }
      _showBottomModal();
    } else {
      _qualites = null;
    }
    setState(() => _isSearching = false);
  }

  _showBottomModal() {
    showBottomSheet(
      context: context,
      backgroundColor: CustomColors.appBar,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.w),
          topRight: Radius.circular(15.w),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Video Quality',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: CustomColors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: CustomColors.primary,
                          size: 26.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.w),
                        child: Image.network(
                          _video!.thumbnail!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      Icon(
                        _getBrandIcon!,
                        color: CustomColors.primary,
                        size: 26.w,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        'Downloading From ${_getFilePrefix ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: CustomColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    children: [
                      Icon(
                        FontAwesome.video,
                        color: CustomColors.primary,
                        size: 26.w,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: Text(
                          _video!.title!,
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: CustomColors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Wrap(
                    children: List.generate(
                      _qualites!.length,
                          (index) => VideoQualityCard(
                        isSelected: _selectedQualityIndex == index,
                        model: _qualites![index],
                        onTap: () async {
                          setState(() => _selectedQualityIndex = index);
                        },
                        type: _videoType,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_isDownloading) {
                        _showSnackBar(
                          'Try again later! Downloading in progress.',
                          2,
                        );
                      } else {
                        Navigator.pop(context);
                        await _performDownloading(
                          _qualites![_selectedQualityIndex].url!,
                        );
                      }
                    },
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0.h),
                        child: Text(
                          'Download This Video',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: CustomColors.appBar,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        CustomColors.primary,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 5.h),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter URL here',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: CustomColors.white,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            TextField(
              controller: _controller,
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              enabled: false,
              cursorWidth: 1.w,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  filled: true,
                  fillColor: CustomColors.appBar,
                  suffixIcon: Icon(
                    _getBrandIcon,
                    color: CustomColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.w),
                  )),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    if (_isSearching) {
                      _showSnackBar(
                          'Try again later! Searching in progress', 2);
                    } else if (_isDownloading) {
                      _showSnackBar(
                          'Try again later! Downloading in progress', 2);
                    } else {
                      Clipboard.getData(Clipboard.kTextPlain)
                          .then((value) async {
                        bool _hasString = await Clipboard.hasStrings();
                        if (_hasString) {
                          if (_controller.text == value!.text) {
                            _showBottomModal();
                          } else {
                            setState(() {
                              _selectedQualityIndex = 0;
                              _videoType = VideoType.none;
                              _isLoading = false;
                              _qualites = [];
                              _video = null;
                              _isLoading = true;
                            });
                            _controller.text = '';
                            _controller.text = value.text!;

                            if (value.text!.isEmpty ||
                                _controller.text.isEmpty) {
                              _showSnackBar('Please Enter Video URL', 2);
                            } else {
                              _setVideoType(value.text!);
                              setState(() => _isSearching = true);
                              await _onLinkPasted(value.text!);
                            }
                          }
                        } else {
                          _showSnackBar(
                              'Empty content pasted! Please try again', 2);
                        }
                        setState(() => _isLoading = false);
                      });
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.h),
                      child: Text(
                        'Paste Link',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: CustomColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        CustomColors.primary,
                      ),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.w),
                      ))),
                )),
                SizedBox(
                  width: 20.w,
                ),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    if (_isDownloading) {
                      _showSnackBar(
                          'Try again later! Downloading in progress.', 2);
                    } else {
                      setState(() {
                        _selectedQualityIndex = 0;
                        _videoType = VideoType.none;
                        _isLoading = false;
                        _qualites = [];
                        _video = null;
                      });
                      _controller.text = '';
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.h),
                      child: Text(
                        'Clear Link',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: CustomColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        CustomColors.primary,
                      ),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.w),
                      ))),
                ))
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : !_isDownloading
                    ? (_qualites != null && _qualites!.isNotEmpty)
                        ? Container()
                        : _qualites == null
                            ? Text(
                                'hmm, this link looks not supported',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: CustomColors.white,
                                ),
                              )
                            : Container()
                    : Container(),
            _isDownloading
                ? Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.0.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.downloading,
                                        color: CustomColors.primary,
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Text(
                                        'Downloading',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: CustomColors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6.w,
                                  ),
                                  Text(
                                    _fileName.substring(1),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: CustomColors.white,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                '${_progressValue.toStringAsFixed(0)}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: CustomColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 6.h,
                          ),
                          LinearProgressIndicator(
                            value: (_progressValue / 100),
                            minHeight: 6.h,
                          )
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.w),
                      color: CustomColors.appBar,
                    ),
                  )
                : Container(),
            _isDownloading
                ? SizedBox(
                    height: 20.h,
                  )
                : Container(),
            SizedBox(
              height: 20.h,
            )
          ],
        ),
      ),
    );
  }
}

enum VideoType { youtube, facebook, twitter, instagram, tiktok, none }
