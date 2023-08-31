import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:studysesshhhh/services/database.dart';

class AuthServices{
  final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<User?> signupUsingEmailPassword({required String email, required String password,required String name, required String uid, required String degree, required String photoUrl, required BuildContext context}) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? studentUser;
    try{
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      studentUser = userCredential.user;
      await studentUser?.reload();
      await studentUser!.updateDisplayName(name);


      await DatabaseServices(uid: studentUser.uid).addStudentUserDataToDB(email.toString(), name.toString(),degree.toString(), uid, photoUrl);

    } on FirebaseAuthException catch (e){
      if (e.code == "user-not-found") {
        if (kDebugMode) {
          print(e.toString());
        }
      }

    }

    return studentUser;
  }


  // static Future<User?> signupUsingEmailPasswordStaff({required String email, required String password,required String name, required String uid,required String photoUrl, required BuildContext context}) async{
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? staffUser;
  //   try{
  //     UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
  //     staffUser = userCredential.user;
  //     await staffUser?.reload();
  //     await staffUser!.updateDisplayName(name);
  //
  //
  //     await DatabaseServices(uid: staffUser.uid).addStaffUserDataToDB(email.toString(), name.toString(), uid, photoUrl);
  //
  //   } on FirebaseAuthException catch (e){
  //     if (e.code == "user-not-found") {
  //       if (kDebugMode) {
  //         print(e.toString());
  //       }
  //     }
  //
  //   }
  //
  //   return staffUser;
  // }

  Future<User?> loginUsingEmailPassword({required String email, required String password, required BuildContext context}) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    User? studentUser;
    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      studentUser = userCredential.user;
      await studentUser?.reload();



    } on FirebaseAuthException catch (e){
      if (e.code == "user-not-found") {
        if (kDebugMode) {
          print("No User found for that email");
        }
      }
    }

    return auth.currentUser;
  }

  signOutwithEmail() async{
    return await FirebaseAuth.instance.signOut();
  }

}