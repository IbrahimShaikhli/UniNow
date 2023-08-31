import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key, required this.resultPage}) : super(key: key);
  final String resultPage;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final CollectionReference resultCollection =
  FirebaseFirestore.instance.collection("studentResults");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resultPage),
        backgroundColor: const Color(0xFF016E8B),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: resultCollection
            .doc(widget.resultPage.toString())
            .collection(FirebaseAuth.instance.currentUser!.displayName.toString())
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        child: Row(
                          children: const <Widget>[
                            Icon(
                              Icons.add_chart,
                              color: Color(0xFF016E8B),
                            ),
                            Text(
                              'Course Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF016E8B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey[100]),
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                'Course Name',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF016E8B),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                documentSnapshot['courseName'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey[100]),
                        child: Row(
                          children: [
                            const Text(
                              'Credit Hours',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF016E8B),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                documentSnapshot['creditHours'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey[100]),
                        child: Row(
                          children: [
                            const Text(
                              'GPA',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF016E8B),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                documentSnapshot['gPA'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          } else if (streamSnapshot.hasError) {
            // Error handling
            return Center(
              child: Text('Error fetching data: ${streamSnapshot.error}'),
            );
          } else {
            // Loading state
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
