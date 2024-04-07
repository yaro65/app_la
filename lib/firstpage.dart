import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({Key? key}) : super(key: key);

  @override
  _FirstpageState createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> image = [];
  var pageformat = "A4";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          image.isEmpty
              ? Center(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Sélectionner une image depuis l'appareil photo ou la galerie",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : PdfPreview(
                  maxPageWidth: 1000,
                  canChangeOrientation: true,
                  canDebug: false,
                  build: (format) => generateDocument(
                    format,
                    image.length,
                    image,
                  ),
                ),
          Align(
            alignment: const Alignment(-0.5, 0.8),
            child: FloatingActionButton(
              elevation: 0.0,
              child: const Icon(
                Icons.image,
              ),
              backgroundColor: Colors.grey[600],
              onPressed: getImageFromGallery,
            ),
          ),
          Align(
            alignment: const Alignment(0.5, 0.8),
            child: FloatingActionButton(
              elevation: 0.0,
              child: const Icon(
                Icons.camera,
              ),
              backgroundColor: Colors.grey[600],
              onPressed: getImageFromcamera,
            ),
          ),
        ],
      ),
    );
  }

  getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image.add(File(pickedFile.path));
      } else {
        if (kDebugMode) {
          print('No image selected');
        }
      }
    });
  }

  getImageFromcamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image.add(File(pickedFile.path));
      } else {
        if (kDebugMode) {
          print('No image selected');
        }
      }
    });
  }

  Future<Uint8List> generateDocument(
      PdfPageFormat format, imagelenght, image) async {
    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    for (var im in image) {
      final showimage = pw.MemoryImage(im.readAsBytesSync());

      doc.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: format.copyWith(
              marginBottom: 0,
              marginLeft: 0,
              marginRight: 0,
              marginTop: 0,
            ),
            orientation: pw.PageOrientation.portrait,
            theme: pw.ThemeData.withFont(
              base: font1,
              bold: font2,
            ),
          ),
          build: (context) {
            return pw.Center(
              child: pw.Image(showimage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return await doc.save();
  }
}
