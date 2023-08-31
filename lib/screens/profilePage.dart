import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studysesshhhh/ChattingAppSection/chattingHomeScreen.dart';
import 'package:studysesshhhh/screens//LoginPage.dart';
import 'package:studysesshhhh/screens/resultsPage.dart';
import 'package:studysesshhhh/services/database.dart';
import 'package:studysesshhhh/screens/documents.dart';
import 'package:studysesshhhh/screens//payments.dart';
import 'package:studysesshhhh/services/auth.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final CollectionReference studUsers =
  FirebaseFirestore.instance.collection('studentUsers');
  String imageUrl = "";
  final double coverHeight = 280;
  final double profileHeight = 144;
  TextEditingController phoneController = TextEditingController();
  List<String> items = [
    'Semester01',
    'Semester02',
    'Semester03',
    'Semester04',
    'Semester05',
    'Semester06',
    'Semester07',
    'Semester08'
  ];
  String? selectedItem = 'Semester01';

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF016E8B),
        centerTitle: true,
        elevation: 0.0,
        title: const Text('Profile Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF016E8B),
                image: DecorationImage(
                  image: AssetImage("assets/UniNow.png"),
                ),
              ),
              child: const Text(''),
            ),
            ListTile(
              title: const Text('Profile Page'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              title: const Text('UniNow Chat'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Payments Section'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PaymentPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Documents Section'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DocumentTab()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                AuthServices().signOutwithEmail().then((s) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studUsers.where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: bottom),
                            child: buildCoverImage(),
                          ),
                          Positioned(
                            top: top,
                            child: GestureDetector(
                              onTap: () async {
                                ImagePicker picker = ImagePicker();
                                XFile? file =
                                await picker.pickImage(source: ImageSource.gallery);
                                Reference refer = FirebaseStorage.instance.ref();
                                Reference referImage = refer.child("images");
                                Reference refImageUpload =
                                referImage.child(file!.path);

                                try {
                                  await refImageUpload.putFile(File(file.path));
                                  imageUrl =
                                  await refImageUpload.getDownloadURL();
                                } catch (error) {
                                  print(error.toString());
                                }

                                DatabaseServices()
                                    .storeUserProfile(imageUrl, documentSnapshot['id']);
                              },
                              child: CircleAvatar(
                                radius: 71,
                                backgroundColor: const Color(0xFF016E8B),
                                backgroundImage: NetworkImage(documentSnapshot["imgUrl"]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text('Welcome back'),
                      Text(
                        documentSnapshot['name'],
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.account_circle,
                            color: Color(0xFF016E8B),
                          ),
                          const Text(
                            'Basic Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF016E8B),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text('Name', textAlign: TextAlign.left),
                          ),
                          Expanded(
                            child: Text(documentSnapshot['name'], textAlign: TextAlign.right),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text('Student ID', textAlign: TextAlign.left),
                          ),
                          Expanded(
                            child: Text(documentSnapshot['id'], textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text('Programme', textAlign: TextAlign.left),
                            ),
                            Expanded(
                              child: Text(documentSnapshot['degree'], textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: const <Widget>[
                            Icon(
                              Icons.add,
                              color: Color(0xFF016E8B),
                            ),
                            Text(
                              'Update Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF016E8B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: formKey,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "Phone Number",
                          prefixIcon: Icon(Icons.phone_android, color: Color(0xFF016E8B)),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value)) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 26.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RawMaterialButton(
                          fillColor: const Color(0xFF016E8B),
                          elevation: 0.0,
                          padding: const EdgeInsets.symmetric(vertical: 25.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          onPressed: () async {
                            DatabaseServices().storeUserNumber(phoneController.text, documentSnapshot['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Phone number updated')),
                            );
                          },
                          child: const Text(
                            "Update",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Container(
                        child: Row(
                          children: const <Widget>[
                            Icon(
                              Icons.add_chart,
                              color: Color(0xFF016E8B),
                            ),
                            Text(
                              'Display Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF016E8B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownButton(
                        value: selectedItem,
                        items: items.map(
                              (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ).toList(),
                        onChanged: (item) => setState(() => selectedItem = item),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RawMaterialButton(
                          fillColor: const Color(0xFF016E8B),
                          elevation: 0.0,
                          padding: const EdgeInsets.symmetric(vertical: 25.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          onPressed: () async {
                            if (selectedItem == items[0]) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultPage(resultPage: selectedItem.toString()),
                                ),
                              );
                            } else if (selectedItem == items[1]) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultPage(resultPage: selectedItem.toString()),
                                ),
                              );
                            } else if (selectedItem == items[2]) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultPage(resultPage: selectedItem.toString()),
                                ),
                              );
                            } else if (selectedItem == items[3]) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultPage(resultPage: selectedItem.toString()),
                                ),
                              );
                            } else if (selectedItem == items[4]) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultPage(resultPage: selectedItem.toString()),
                                ),
                              );
                            } else if (selectedItem == items[5]) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultPage(resultPage: selectedItem.toString()),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Semester does not exist')),
                              );
                            }
                          },
                          child: const Text(
                            "View Results",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildCoverImage() {
    return Container(
      height: coverHeight,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/coverPic.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
