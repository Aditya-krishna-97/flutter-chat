import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:messenger/models/db_helper.dart';
import 'package:messenger/screens/auth_screen.dart';
import 'package:messenger/screens/chat_screen.dart';
import 'package:messenger/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/db_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  void disableScreenshots() async{
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    print("Disabled screenshots");
  }
  checkpremissions() async{
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;
    var alwaysLocationStatus = await Permission.locationAlways.status;
    var inUseLocationStatus = await Permission.locationWhenInUse.status;
    var galleryPermission = await Permission.mediaLibrary.status;

    print("Always location status is $alwaysLocationStatus");
    print("InUseLocationStatus is $inUseLocationStatus");
    print("Microphone status is $microphoneStatus");
    print("Camera status is $cameraStatus");
    print("Gallery permission is $galleryPermission");

    if(!cameraStatus.isGranted)
      await Permission.camera.request();
    if(!microphoneStatus.isGranted)
      await Permission.microphone.request();
    if(!alwaysLocationStatus.isGranted)
      await Permission.locationAlways.request();

    if(await Permission.camera.isGranted){
      print("Camera Permission granted");
    }
    else{
      print("Camera permission is $cameraStatus");
      print("Microphone status is $microphoneStatus");
      print("Location status is $alwaysLocationStatus");
    }

  }



  @override
  void initState(){
    var now = DateTime.now();
    disableScreenshots();
    print("In main initstate");
  //  print("Calling db helper class");
    print("Current time is $now");
   // print("Inserting data into local database");
   // DBHelper.insert('places', {'id':now.toString(),'title':title});
    super.initState();
    checkpremissions();
  }


  bool _secureMode = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context,appSnapshot){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Messenger',
          theme: ThemeData(
            primarySwatch: Colors.pink,
            backgroundColor: Colors.pink,
            accentColor: Colors.grey[800],
            accentColorBrightness: Brightness.dark,
            buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Colors.pink,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen();
            }
            if (userSnapshot.hasData) {
              return ChatScreen();
            }
            return AuthScreen();
          }),
        );
      },
    );
  }
}