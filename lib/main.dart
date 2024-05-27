import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_downloader/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 360),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, widget) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),

        builder: (context, widget) {
          ScreenUtil.registerToBuild(context);

          return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!);
        },
      ),
    );
  }
}

