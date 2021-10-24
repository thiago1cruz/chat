import 'dart:io';

import 'package:chat/text_compose.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_menssage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  User? _currentUser;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
     setState(() {
        _currentUser = user;
     });
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = result.user;
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> _sendMenssage({String? text, XFile? file}) async {
    final User? user = await _getUser();

    if (user == null) {
     _scaffoldkey.currentState!.showSnackBar(const SnackBar(
            content: Text('Não foi possível fazer o login'),
            backgroundColor: Colors.red,
          ));
    }

    Map<String, dynamic> data = {
      'uid': user?.uid,
      'senderName': user?.displayName,
      'sendPhotoUrl': user?.photoURL,
      'time': Timestamp.now()
    };

    if (file != null) {
      Reference ref = FirebaseStorage.instance
          .ref().child(_currentUser!.uid)
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      UploadTask uploadTask = ref.putFile(File(file.path));
      setState(() {
        _isloading = true;
      });
      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();

      data['imgUrl'] = url;

      setState(() {
        _isloading = false;
      });
    }

    if (text != null) data['text'] = text;
    FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(   
        centerTitle: true,         
        title:  Text(
         _currentUser != null ? _currentUser!.displayName as String : 'Chat App'
        ),
        actions: [
           _currentUser != null ? IconButton(
             onPressed: (){
               FirebaseAuth.instance.signOut();
               googleSignIn.signOut();
                _scaffoldkey.currentState!.showSnackBar(const SnackBar(
            content: Text('Você saiu co sucesso'),
            backgroundColor: Colors.green,
          ));
             }, icon: const Icon(Icons.exit_to_app_rounded)) : Container()
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('messages').orderBy('time').snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Container(
                    child: const CircularProgressIndicator(),
                  );
                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) { 
                        final data =  documents[index].data() as Map<String, dynamic> ;                 
                        return ChatMenssage(
                          data: data,
                          mine: data['uid'] == _currentUser?.uid );
                      });
              }
            },
          )),
          _isloading ? LinearProgressIndicator() : Container(),
          TextComposer(
            sendMessage: _sendMenssage,
          ),
        ],
      ),
    );
  }
}
