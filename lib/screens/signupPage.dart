import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studysesshhhh/screens//LoginPage.dart';
import 'package:studysesshhhh/screens//profilePage.dart';
import 'package:studysesshhhh/services/auth.dart';
import 'dart:io';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final formKey = GlobalKey<FormState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final programmeController = TextEditingController();
  String imageUrl = '';
  List<String> progammeItems = [
    'Information Technology',
    'Engineering',
    'Medicine',
    'Computer Science',
    'Education',
    'Business'
  ];
  String? selectedItem = 'Information Technology';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "UniNow",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Student Register",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 22.0,
                ),
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 30),
                      child: const CircleAvatar(
                        radius: 71,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                    Positioned(
                        top: 120,
                        left: 110,
                        child: RawMaterialButton(
                          elevation: 2,
                          fillColor: const Color(0xFF016E8B),
                          padding: const EdgeInsets.all(15),
                          shape: const CircleBorder(),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Choose option',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF016E8B),
                                      ),
                                    ),
                                    content: SingleChildScrollView(
                                        child: ListBody(
                                      children: [
                                        InkWell(
                                          splashColor: const Color(0xFF016E8B),
                                          onTap: () async {
                                            ImagePicker pick = ImagePicker();
                                            XFile? file = await pick.pickImage(
                                                source: ImageSource.gallery);
                                            Reference refer =
                                                FirebaseStorage.instance.ref();
                                            Reference referImage =
                                                refer.child("images");
                                            Reference refImageUpload =
                                                referImage.child(file!.path);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Image uploaded and will be visible once signed-up')),
                                            );

                                            try {
                                              await refImageUpload
                                                  .putFile(File(file.path));
                                              imageUrl = await refImageUpload
                                                  .getDownloadURL();

                                            } catch (error) {
                                              if (kDebugMode) {
                                                print(error.toString());
                                              }
                                            }
                                          },
                                          child: Row(
                                            children: const [
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.photo,
                                                  color: Color(0xFF016E8B),
                                                ),
                                              ),
                                              Text(
                                                "Gallery",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                                  );
                                });
                          },
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.white,
                          ),
                        ))
                  ],
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      hintText: "Student Email",
                      prefixIcon: Icon(Icons.mail, color: Color(0xFF016E8B))),
                  validator: (value) {
                    if (value!.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)){
                    return "Enter correct email";
                    }
                    return null;
                   },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF016E8B))),
                  validator: (value) {
                    if (value!.isEmpty){
                      return "Enter correct password";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                      hintText: "Full Name",
                      prefixIcon: Icon(Icons.person, color: Color(0xFF016E8B))),
                  validator: (value) {
                    if (value!.isEmpty || !RegExp(r'^[a-z A-Z]').hasMatch(value!)) {
                      return "Enter Correct name";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: idController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      hintText: "Student ID..SUKDXX",
                      prefixIcon: Icon(Icons.person, color: Color(0xFF016E8B))),
                  validator: (value){
                    if (value!.isEmpty || !RegExp(r'^[D-S]').hasMatch(value!)){
                      return "Must start with SUKD";
                    }
                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 13,
                    ),
                    const Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFF016E8B),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Row(
                      children: [
                        DropdownButton(
                          value: selectedItem,
                          items: progammeItems
                              .map((progammeItems) => DropdownMenuItem<String>(
                                    value: progammeItems,
                                    child: Text(
                                      progammeItems,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (progammeItems) =>
                              setState(() => selectedItem = progammeItems),
                        ),
                      ],
                    )
                  ],
                ),
                GestureDetector(
                  child: const Center(
                      child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline),
                  )),
                  onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage())),
                ),
                const SizedBox(
                  height: 45.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RawMaterialButton(
                    fillColor: const Color(0xFF016E8B),
                    elevation: 0.0,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        User? user = await AuthServices.signupUsingEmailPassword(
                            email: emailController.text,
                            password: passwordController.text,
                            name: nameController.text,
                            uid: idController.text,
                            degree: selectedItem!,
                            photoUrl: imageUrl!,
                            context: context);
                        user!.updateDisplayName(nameController.text);
                        user.reload();
                        if (kDebugMode) {
                          print(user);
                        }
                        if (user != null) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => const ProfilePage()));
                        }
                      }

                    },
                    child: const Text(
                      "Signup",
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
