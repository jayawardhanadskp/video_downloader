import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/custom_colors.dart';
import '../widgets/my_thumbnail.dart';

class DownloadScreen extends StatefulWidget {

  final List<VideoData> videoData;
  final List<FileSystemEntity> downloads;
  final VoidCallback onVideoDeleted;
  final ValueChanged<int> onCardTap;

  DownloadScreen({
    super.key,
    required this.videoData,
    required this.downloads,
    required this.onVideoDeleted,
    required this.onCardTap,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {

  _showAlertDialog(BuildContext context, int index) {
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
        child: Text(
          'Cancel',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: CustomColors.primary,
            fontWeight: FontWeight.w500,
          ),
        )
    );

    Widget continueButton = TextButton(
        onPressed: () async{
          try {
            final file = File(widget.downloads[index].path);
            await file.delete();
          } catch (e) {
            debugPrint(e.toString());
          }
          Navigator.of(context, rootNavigator: true).pop('dialog');

          widget.onVideoDeleted();
        },
        child: Text(
          'Delete',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: CustomColors.primary,
            fontWeight: FontWeight.w500,
          ),
        )
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: CustomColors.backGround,
      title: Text(
        'Delete Confirmation',
        style: GoogleFonts.poppins(
          fontSize: 22,
          color: CustomColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        'Are you sure want to delete this video',
        style: GoogleFonts.poppins(
          fontSize: 18,
          color: CustomColors.white,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        }
    );

  }

  @override
  Widget build(BuildContext context) {
    return widget.downloads.isNotEmpty
    ? Padding(
      padding: EdgeInsets.all(10.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_outlined,
            size: 50.w,
            color: CustomColors.primary,
          ),
          SizedBox(height: 10.h,),
          Text(
            'Hmm... it seems like you have downloaded videos',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: CustomColors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    )
        : SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: widget.downloads.length,
          padding: EdgeInsets.symmetric(vertical: 5.h),
          itemBuilder: (context, index) {
          int _revereseIndex = widget.downloads.length - 1 - index;
            return InkWell(
              onTap: () {
                widget.onCardTap(index);
              },
              child: MyThumbnail(
                path: widget.downloads[_revereseIndex].path,
                data: widget.videoData[_revereseIndex],
                onVideoDeleted: () {
                  _showAlertDialog(context, _revereseIndex);
                },
              ),
            );
          }),
    );
  }
}
