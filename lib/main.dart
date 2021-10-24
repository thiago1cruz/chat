import 'package:chat/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
 runApp(const MyApp());  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
 

  @override
  Widget build(BuildContext context) {     
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       iconTheme: const IconThemeData(
         color: Colors.blue
       ),
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}


 