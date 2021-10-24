import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  

  const TextComposer({Key? key, required this.sendMessage}) : super(key: key);


  final Function({String?  text, XFile? file}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _sendText = TextEditingController();

  bool _iscomposing = false;


  void _reset(){
    widget.sendMessage(text:_sendText.text);
    _sendText.clear();
    setState(() {
      _iscomposing = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton( 
          icon: const Icon(Icons.image_outlined),
          onPressed: () async {

          final XFile? imageFile = await ImagePicker.platform.getImage(source: ImageSource.camera);
          if(imageFile == null) return;
          widget.sendMessage(file: imageFile);

          },
          ),
          Expanded(
            child: TextField(
              controller: _sendText,
              decoration: const InputDecoration.collapsed(hintText: 'Enviar uma mensagem'),
              onChanged: (texto){
                  setState(() {
                    _iscomposing= texto.isNotEmpty;
                  });
              },
              onSubmitted: (texto){
                  _reset();
              },
            )
            ),
            IconButton(
              icon: const Icon(Icons.send_sharp),
              onPressed: _iscomposing ? (){
                  _reset();
              } : null,
              )
        ],
      ),
    );
  }
}