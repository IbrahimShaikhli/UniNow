import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studysesshhhh/ChattingAppSection/chatroom.dart';
import 'package:studysesshhhh/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  String chatRoomId(String myUser, String user) {
    if (myUser[0].toLowerCase().codeUnits[0] >
        user.toLowerCase().codeUnits[0]) {
      return "$myUser$user";
    } else {
      return "$user$myUser";
    }
  }

  void onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });

    try {
      final querySnapshot = await firestore
          .collection('studentUsers')
          .where('name', isEqualTo: searchController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userMap = querySnapshot.docs[0].data();
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No Results'),
              content: Text('No users found with the provided username.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while searching for users.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? myName = auth.currentUser!.displayName;

    return Scaffold(
      appBar: AppBar(
        title: Text('UniNow Chat'),
        centerTitle: true,
        backgroundColor: Color(0xFF016E8B),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF016E8B),
              ),
              onPressed: onSearch,
              child: Text('Search Username'),
            ),
            SizedBox(
              height: 20,
            ),
            userMap != null
                ? ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    String roomId = chatRoomId(
                      myName!,
                      userMap!["name"],
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoom(
                          chatRoomId: roomId,
                          userMap: userMap,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      userMap!["imgUrl"],
                    ),
                  ),
                  title: Text(
                    userMap!["name"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(userMap!["email"]),
                  trailing: Icon(
                    Icons.chat_bubble,
                    color: Color(0xFF016E8B),
                  ),
                );
              },
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
