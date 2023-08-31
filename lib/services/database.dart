import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseServices({this.uid});

  // Collection references
  CollectionReference get userCollection => _firestore.collection('studentUsers');
  CollectionReference get staffCollection => _firestore.collection('staffUsers');
  CollectionReference get paymentCollection => _firestore.collection('studentPayments');

  // Adds new users to the system after registrations
  Future<void> addStudentUserDataToDB(String email, String name, String degree, String id, String photoUrl) async {
    final userData = {
      'email': email,
      'name': name,
      'degree': degree,
      'id': id,
      'imgUrl': photoUrl,
    };

    await userCollection.doc(id).set(userData);
  }

  Future<void> addStaffUserDataToDB(String email, String name, String id, String photoUrl) async {
    final userData = {
      'email': email,
      'name': name,
      'id': id,
      'imgUrl': photoUrl,
    };

    await staffCollection.doc(id).set(userData);
  }

  Future<void> storeUserPayments(String transaction, String name, String id, String amount, String bank) async {
    final paymentData = {
      'paymentType': transaction,
      'name': name,
      'id': id,
      'amount': amount,
      'bankName': bank,
    };

    await paymentCollection.doc(uid).set(paymentData);
  }

  Future<void> storeUserNumber(String phoneNum, String id) async {
    final userData = {
      'studentPhoneNum': phoneNum,
    };

    await userCollection.doc(id).set(userData, SetOptions(merge: true));
  }

  Future<void> storeUserProfile(String photoUrl, String id) async {
    final userData = {
      'imgUrl': photoUrl,
    };

    await userCollection.doc(id).set(userData, SetOptions(merge: true));
  }
}
