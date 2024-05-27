import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:video_downloader/utils/custom_colors.dart';

import 'app_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  AppUpdateInfo? _updateInfo;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  
  void _showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('text'),
        ),
      );
    }  
  }

  @override
  void initState() {
    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.performImmediateUpdate().catchError((e) {
        _showSnack(e.toString());
      });
    } else {
      Future.delayed(const Duration(seconds:  3), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const AppScreen(),
            ),
        );
      });
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backGround,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('AB',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 80,
                    color: CustomColors.primary,
                    fontWeight: FontWeight.w600
                  ),
                  ),
                  
                  Text('Video Downloader',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 35,
                    color: CustomColors.white,
                    fontWeight: FontWeight.w500,
                  ),)
                ],
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Very Fast, Secure & Private',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.white,
                  ),),

                  Text('Supports',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 50,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.primary,
                    ),),

                  Row(
                    children: [
                      Text('Multiple',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 35,
                          fontWeight: FontWeight.w300,
                          color: CustomColors.white,
                        ),),

                      Text('Source',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 45,
                          fontWeight: FontWeight.w700,
                          color: CustomColors.primary,
                        ),),
                    ],
                  ),
                  const SizedBox(height: 5,),

                  Text('Ab Video Downloader is the easiest application to download videos for multiple source',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: CustomColors.white,
                    ),),

                  const SizedBox(height: 10,)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
