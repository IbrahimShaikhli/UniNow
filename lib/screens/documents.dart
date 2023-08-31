import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DocumentTab extends StatefulWidget {
  const DocumentTab({Key? key}) : super(key: key);

  @override
  State<DocumentTab> createState() => _DocumentTabState();
}

class _DocumentTabState extends State<DocumentTab> {
  List<Reference> allFiles = [];
  List<Reference> filteredFiles = [];

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final result = await FirebaseStorage.instance.ref('/files').listAll();
    setState(() {
      allFiles = result.items;
      filteredFiles = allFiles;
    });
  }

  void filterFiles(String query) {
    setState(() {
      filteredFiles = allFiles.where((file) => file.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Future<void> downloadFile(Reference ref) async {
    final dir = await getExternalStorageDirectory();
    final pdfFile = File('${dir!.path}/${ref.name}');

    await ref.writeToFile(pdfFile);
    if (kDebugMode) {
      print('Path: ${pdfFile.path}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloaded ${ref.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF016E8B),
        centerTitle: true,
        title: const Text('Documents'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (query) {
                filterFiles(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFiles.length,
              itemBuilder: (context, index) {
                final pdfFile = filteredFiles[index];
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(pdfFile.name),
                        leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF016E8B)),
                        contentPadding: const EdgeInsets.all(8),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.download,
                            color: Colors.black,
                          ),
                          onPressed: () => downloadFile(pdfFile),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
