import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SpinKitFadingCircle(
          color: Colors.white,
        )
        /*
        SpinKitPulse(
          color: Colors.white,
          size: 50.0,
        ),


         */
      ),
    );
  }
}
