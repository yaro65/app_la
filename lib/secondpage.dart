import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';

class Secondpage extends StatefulWidget {
  const Secondpage({Key? key}) : super(key: key);

  @override
  _SecondpageState createState() => _SecondpageState();
}

class _SecondpageState extends State<Secondpage> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<Uint8List> image = [];
  var pageformat = "A4";
  File? _image;
  Uint8List? _byte, salida;
  String _versionOpenCV = 'OpenCV';
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _getOpenCVVersion();
  }

  testOpenCV({
    required String pathString,
    required CVPathFrom pathFrom,
    required double thresholdValue,
    required double maxThresholdValue,
    required int thresholdType,
  }) async {
    try {
      _byte = await Cv2.threshold(
        pathFrom: pathFrom,
        pathString: pathString,
        maxThresholdValue: maxThresholdValue,
        thresholdType: thresholdType,
        thresholdValue: thresholdValue,
      );

      // Mettre à jour la liste d'images et l'état de visibilité
      setState(() {
        image.add(_byte!);
        _visible = false;
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
      // Gérer l'erreur ici, par exemple afficher un message à l'utilisateur
    }
  }

  Future<void> _getOpenCVVersion() async {
    String? versionOpenCV = await Cv2.version();
    setState(() {
      _versionOpenCV = 'OpenCV: ' + versionOpenCV!;
    });
  }

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
                            height: 20,
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
              onPressed: getImageFromCamera,
            ),
          ),
        ],
      ),
    );
  }

  getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);

      testOpenCV(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: _image!.path,
        thresholdValue: 130,
        maxThresholdValue: 200,
        thresholdType: Cv2.THRESH_BINARY,
      );
    }
  }

  getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      testOpenCV(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: imageFile.path,
        thresholdValue: 130,
        maxThresholdValue: 200,
        thresholdType: Cv2.THRESH_BINARY,
      );
      setState(() {
        _visible = true;
      });
    }
  }

  Future<Uint8List> generateDocument(
      PdfPageFormat format, int imageLength, List<Uint8List> image) async {
    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    for (var im in image) {
      final showimage = pw.MemoryImage(im);

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('_versionOpenCV', _versionOpenCV));
    properties.add(DiagnosticsProperty<bool>('_visible', _visible));
  }
}
