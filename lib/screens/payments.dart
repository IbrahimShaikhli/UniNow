import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studysesshhhh/services/database.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final formKey = GlobalKey<FormState>();
  final CollectionReference studUsers =
  FirebaseFirestore.instance.collection('studentUsers');
  final double coverHeight = 280;
  final double profileHeight = 144;
  int currentStep = 0;
  final itemController = TextEditingController();
  List<String> items = [
    'Outstanding Fees',
    'Change Course',
    'Visa Renewal',
    'Late Registry',
    'Exam Check'
  ];
  String? selectedItem = 'Outstanding Fees';
  List<String> bankitems = ['Affin Bank', 'CIMB', 'MayBank'];
  String? selectedBank = 'Affin Bank';
  String imageUrl = '';

  //method to launch any url
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch URL: $url';
    }
  }

  final String paymentSelectionTitle = 'Payment Selection';
  final String paymentAmountTitle = 'Payment Amount';
  final String bankSelectionTitle = 'Bank Selection';
  final String paymentReviewTitle = 'Payment Review';

  List<Step> getSteps() => [
    Step(
      isActive: currentStep >= 0,
      title: const Text('Payment Selection'),
      content: DropdownButton(
        value: selectedItem,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        )
            .toList(),
        onChanged: (item) => setState(() => selectedItem = item),
      ),
    ),
    Step(
      isActive: currentStep >= 1,
      title: const Text('Payment Amount'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: itemController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'Please enter a valid amount';
            } else if (value.startsWith('0')) {
              return 'Please enter a valid number';
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: 'Enter Amount',
            prefixIcon: Icon(Icons.money, color: Colors.blue),
          ),
        ),
      ),
    ),
    Step(
      isActive: currentStep >= 2,
      title: const Text('Bank Selection'),
      content: DropdownButton(
        value: selectedBank,
        items: bankitems
            .map(
              (bankitem) => DropdownMenuItem<String>(
            value: bankitem,
            child: Text(
              bankitem,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        )
            .toList(),
        onChanged: (bankitem) => setState(() => selectedBank = bankitem),
      ),
    ),
    Step(
      isActive: currentStep >= 3,
      title: const Text('Payment Review'),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type'),
              const SizedBox(
                width: 72,
              ),
              Text(selectedItem.toString(), textAlign: TextAlign.left),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Amount'),
              const SizedBox(
                width: 10,
              ),
              Text(
                '${itemController.text} RM',
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Bank'),
              const SizedBox(
                width: 10,
              ),
              Text(selectedBank.toString(), textAlign: TextAlign.left),
            ],
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: const Color(0xFF016E8B),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studUsers
            .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                final documentSnapshot = data.docs[index];
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
                            child: CircleAvatar(
                              radius: 71,
                              backgroundColor: const Color(0xFF016E8B),
                              backgroundImage:
                              NetworkImage(documentSnapshot['imgUrl']),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              documentSnapshot['name'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stepper(
                        type: StepperType.vertical,
                        steps: getSteps(),
                        currentStep: currentStep,
                        onStepContinue: () {
                          final isLastStep =
                              currentStep == getSteps().length - 1;
                          if (isLastStep) {
                            DatabaseServices().storeUserPayments(
                              selectedItem.toString(),
                              documentSnapshot['name'],
                              documentSnapshot['id'],
                              itemController.text,
                              selectedBank.toString(),
                            );

                            if (selectedBank == bankitems[0]) {
                              _launchURL('https://google.com');
                            } else if (selectedBank == bankitems[1]) {
                              _launchURL('https://cimbclicks.com.my');
                            } else {
                              _launchURL('https://maybank2u.com.my');
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment done')),
                            );
                          } else {
                            setState(() {
                              currentStep += 1;
                            });
                          }
                        },
                        onStepCancel: () {
                          currentStep == 0
                              ? null
                              : setState(() => currentStep -= 1);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget buildCoverImage() {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      height: coverHeight,
      child: Image.network(
        'https://upload.wikimedia .org/wikipedia/commons/c/c5/SEGi_University.jpg',
      ),
    );
  }
}