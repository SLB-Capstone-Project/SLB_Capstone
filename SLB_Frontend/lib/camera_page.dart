import 'package:flutter/material.dart';
//import 'package:camera/camera.dart';
import 'package:barcode_scan2/barcode_scan2.dart';


class CheckInPage extends StatefulWidget {
  const CheckInPage({Key? key}) : super(key: key);

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  String scannedBarcode = 'not scanned yet';

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        scannedBarcode = result.rawContent;
      });
    } catch (e) {
      setState(() {
        scannedBarcode = 'scan error: $e';
      });
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

            // Camera Feed Preview Button
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera Feed Preview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.purple,
              ),
              onPressed: () {

              },
            ),

            // // empty container for camera feed
            // Expanded(
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(vertical: 16.0),
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       color: Colors.grey[300],
            //       borderRadius: BorderRadius.circular(12.0),
            //     ),
            //     child: const Center(
            //       child: Text(
            //         'Camera Feed\n(Placeholder)',
            //         textAlign: TextAlign.center,
            //         style: TextStyle(color: Colors.black54),
            //       ),
            //     ),
            //   ),
            // ),
            // Expanded(
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(vertical: 16.0),
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(12.0),
            //       // 如果想保留背景顏色或邊框，可以加 BoxDecoration
            //       // 但實際上如果顯示相機預覽，通常就直接顯示預覽即可
            //     ),
            //     child: const ClipRRect(
            //       // 為了實現圓角效果，可用 ClipRRect 包住
            //       borderRadius: BorderRadius.all(Radius.circular(12.0)),
            //       child: CameraFeedPage(), // 這裡放你的 Camera Widget
            //     ),
            //   ),
            // ),

            ElevatedButton(
              onPressed: scanBarcode,
              child: const Text('Start scanning barcode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            // two buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                  onPressed: () {

                  },
                  child: const Text('Cancel'),
                ),
                // Scan Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                  onPressed: () {

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