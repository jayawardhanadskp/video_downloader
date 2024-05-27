import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../utils/custom_colors.dart';


class MyThumbnail extends StatefulWidget {
  final String path;
  final VideoData data;
  final VoidCallback onVideoDeleted;

  const MyThumbnail({
    Key? key,
    required this.path,
    required this.data,
    required this.onVideoDeleted,
  }) : super(key: key);

  @override
  State<MyThumbnail> createState() => _MyThumbnailState();
}

class _MyThumbnailState extends State<MyThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {}); // Update the state once the controller is initialized
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            SizedBox(height: 10.h),
            Text(
              widget.data.title ?? 'Untitled',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Duration: ${widget.data.duration ?? "Unknown"}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            SizedBox(height: 5.h),
            Text(
              'Size: ${filesize(File(widget.path).lengthSync())}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
