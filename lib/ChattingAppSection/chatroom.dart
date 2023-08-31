import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom({Key? key, this.userMap, this.chatRoomId}) : super(key: key);

  final Map<String, dynamic>? userMap;
  final String? chatRoomId;

  @override
  Widget build(BuildContext context) {
    final TextEditingController msgController = TextEditingController();
    final size = MediaQuery.of(context).size;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    void onMessageSend() async {
      if (msgController.text.isNotEmpty) {
        Map<String, dynamic> messages = {
          "sentBy": auth.currentUser!.displayName,
          "message": msgController.text,
          "timeStamp": FieldValue.serverTimestamp(),
        };
        await firestore
            .collection("chatRoom")
            .doc(chatRoomId)
            .collection("chats")
            .add(messages);
        msgController.clear();
      } else {
        print("Enter Message");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(userMap!["name"]),
        centerTitle: true,
        backgroundColor: const Color(0xFF016E8B),
      ),
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("chatRoom")
                  .doc(chatRoomId)
                  .collection("chats")
                  .orderBy("timeStamp", descending: false)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> map = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return messages(size, map);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Container(
            color: Colors.grey[100],
            height: size.height / 10,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 12,
              width: size.width / 1.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      maxLines: null, // Allow multiple lines
                      decoration: InputDecoration(
                        hintText: "Send a message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onMessageSend,
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF016E8B),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map) {
    FirebaseAuth auth = FirebaseAuth.instance;
    return Container(
      width: size.width,
      alignment: map["sentBy"] == auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              map["message"],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF016E8B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              // Display timestamp here
              map["timeStamp"] != null
                  ? (map["timeStamp"] as Timestamp).toDate().toString()
                  : '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
