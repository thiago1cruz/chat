import 'package:flutter/material.dart';

class ChatMenssage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool mine;

  const ChatMenssage({Key? key, required this.data, required this.mine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(        
        children: [
          !mine ?
          CircleAvatar(
            backgroundImage: NetworkImage(data['sendPhotoUrl']),
          ) : Container(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(                         
                crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  data['imgUrl'] != null
                      ? Image.network(data['imgUrl'], width: 250,)
                      : Text(
                          data['text'],
                          textAlign: mine ? TextAlign.end : TextAlign.start,
                          style: const TextStyle(fontSize: 16),                      
                        ),
                  Text(
                    data['senderName'],
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          mine ?
          CircleAvatar(
            backgroundImage: NetworkImage(data['sendPhotoUrl']),
          ) : Container(),
        ],
      ),
    );
  }
}
