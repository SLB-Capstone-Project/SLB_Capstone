// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Check-In Page',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const CheckInPage(),
//     );
//   }
// }
//
// class CheckInPage extends StatefulWidget {
//   const CheckInPage({Key? key}) : super(key: key);
//
//   @override
//   State<CheckInPage> createState() => _CheckInPageState();
// }
//
// class _CheckInPageState extends State<CheckInPage> {
//   String scannedBarcode = 'not scanned yet';
//
//   Future<void> scanBarcode() async {
//     try {
//       var result = await BarcodeScanner.scan();
//       setState(() {
//         scannedBarcode = result.rawContent;
//       });
//     } catch (e) {
//       setState(() {
//         scannedBarcode = 'scan error: $e';
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Check-In Page'),
//         toolbarHeight: 60.0,
//         titleTextStyle: const TextStyle(
//           fontSize: 30.0,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//
//         centerTitle: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const SizedBox(height: 16.0),
//
//             // Camera Feed Preview Button
//             ElevatedButton.icon(
//               icon: const Icon(Icons.camera_alt),
//               label: const Text('Camera Feed Preview'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white10,
//                 foregroundColor: Colors.purple,
//               ),
//               onPressed: () {
//
//               },
//             ),
//
//             // // empty container for camera feed
//             // Expanded(
//             //   child: Container(
//             //     margin: const EdgeInsets.symmetric(vertical: 16.0),
//             //     width: double.infinity,
//             //     decoration: BoxDecoration(
//             //       color: Colors.grey[300],
//             //       borderRadius: BorderRadius.circular(12.0),
//             //     ),
//             //     child: const Center(
//             //       child: Text(
//             //         'Camera Feed\n(Placeholder)',
//             //         textAlign: TextAlign.center,
//             //         style: TextStyle(color: Colors.black54),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // Expanded(
//             //   child: Container(
//             //     margin: const EdgeInsets.symmetric(vertical: 16.0),
//             //     width: double.infinity,
//             //     decoration: BoxDecoration(
//             //       borderRadius: BorderRadius.circular(12.0),
//             //       // 如果想保留背景顏色或邊框，可以加 BoxDecoration
//             //       // 但實際上如果顯示相機預覽，通常就直接顯示預覽即可
//             //     ),
//             //     child: const ClipRRect(
//             //       // 為了實現圓角效果，可用 ClipRRect 包住
//             //       borderRadius: BorderRadius.all(Radius.circular(12.0)),
//             //       child: CameraFeedPage(), // 這裡放你的 Camera Widget
//             //     ),
//             //   ),
//             // ),
//
//             ElevatedButton(
//               onPressed: scanBarcode,
//               child: const Text('Start scanning barcode'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             ),
//
//             // two buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Cancel Button
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(120, 48),
//                   ),
//                   onPressed: () {
//
//                   },
//                   child: const Text('Cancel'),
//                 ),
//                 // Scan Button
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(120, 48),
//                   ),
//                   onPressed: () {
//
//                   },
//                   child: const Text('Scan'),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16.0),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart' as barcode_scan;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check-In Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CheckInPage(),
    );
  }
}

class CheckInPage extends StatefulWidget {
  const CheckInPage({Key? key}) : super(key: key);

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  String scannedBarcode = 'not scanned yet';
  String scanResultMessage = '';
  Color scanResultColor = Colors.transparent;

  Future<void> scanBarcode() async {
    try {
      var result = await barcode_scan.BarcodeScanner.scan();
      setState(() {
        scannedBarcode = result.rawContent;
      });
      await processBarcode(scannedBarcode);
    } catch (e) {
      setState(() {
        scanResultMessage = 'Scan error: $e';
        scanResultColor = Colors.red;
      });
    }
  }

  Future<void> scanBarcodeFromImage() async {
    // 暂时清空功能
    setState(() {
      scanResultMessage = 'Scan from image is currently unavailable';
      scanResultColor = Colors.red;
    });
  }

  Future<void> processBarcode(String barcode) async {
    if (barcode.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(barcode)) {
      setState(() {
        scanResultMessage = 'Invalid barcode: must be 10 digits';
        scanResultColor = Colors.red;
      });
      return;
    }

    String categoryId = barcode.substring(0, 4);
    String componentId = barcode.substring(4);

    int categoryIdNum = int.parse(categoryId);
    int componentIdNum = int.parse(componentId);

    await sendPostRequest(categoryIdNum, componentIdNum);

    setState(() {
      scanResultMessage = 'Scan correct';
      scanResultColor = Colors.green;
    });
  }

  Future<void> sendPostRequest(int categoryId, int componentId) async {
    final url = Uri.parse('http://172.191.111.81:8081/');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'category_id': categoryId,
        'component_id': componentId,
      }),
    );

    if (response.statusCode == 200) {
      print('POST request successful');
    } else {
      print('Failed to send POST request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Page'),
        toolbarHeight: 60.0,
        titleTextStyle: const TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 16.0),

            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Barcode from Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.purple,
              ),
              onPressed: scanBarcodeFromImage,
            ),

            ElevatedButton(
              onPressed: scanBarcode,
              child: const Text('Start scanning barcode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            Text(
              scanResultMessage,
              style: TextStyle(
                color: scanResultColor,
                fontSize: 16.0,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                  onPressed: () {
                    // Cancel logic
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManualInputPage()),
                    );
                  },
                  child: const Text('Scan'),
                ),
              ],
            ),

            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class ManualInputPage extends StatefulWidget {
  @override
  _ManualInputPageState createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final TextEditingController _barcodeController = TextEditingController();
  String scanResultMessage = '';
  Color scanResultColor = Colors.transparent;

  Future<void> sendPostRequest(int categoryId, int componentId) async {
    final url = Uri.parse('http://172.191.111.81:8081/');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'category_id': categoryId,
        'component_id': componentId,
      }),
    );

    if (response.statusCode == 200) {
      print('POST request successful');
    } else {
      print('Failed to send POST request');
    }
  }

  void processManualInput() {
    final barcode = _barcodeController.text;
    if (barcode.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(barcode)) {
      setState(() {
        scanResultMessage = 'Invalid barcode: must be 10 digits';
        scanResultColor = Colors.red;
      });
      return;
    }

    String categoryId = barcode.substring(0, 4);
    String componentId = barcode.substring(4);

    int categoryIdNum = int.parse(categoryId);
    int componentIdNum = int.parse(componentId);

    sendPostRequest(categoryIdNum, componentIdNum);

    setState(() {
      scanResultMessage = 'Scan correct';
      scanResultColor = Colors.green;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Input'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Barcode',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 10,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: processManualInput,
              child: const Text('Confirm'),
            ),
            Text(
              scanResultMessage,
              style: TextStyle(
                color: scanResultColor,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



