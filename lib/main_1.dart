import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart' as barcode_scan;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scanner Page',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const CheckInPage(),
    );
  }
}

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});
 
  @override
  State<CheckInPage> createState() => _CheckInPageState();
}
 
class _CheckInPageState extends State<CheckInPage> {
  String scannedBarcode = 'not scanned yet';
  String scanResultMessage = '';
  Color scanResultColor = Colors.transparent;
  bool isLoading = false;
  final List<String> _historyRecords = [];
 
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
 
    setState(() {
      isLoading = true;
      scanResultMessage = 'Processing...';
      scanResultColor = Colors.blue;
    });
 
    try {
      final response = await sendPostRequest(categoryIdNum, componentIdNum);
 
      setState(() {
        _historyRecords.add('${_historyRecords.length + 1}. ${categoryId} ${componentId}');
        if (response['success'] == true) {
          scanResultMessage = 'Scan successful - ${response['message'] ?? 'Data saved'}';
          scanResultColor = Colors.green;
        } else {
          scanResultMessage = 'Error: ${response['message'] ?? 'Unknown error'}';
          scanResultColor = Colors.orange;
        }
      });
    } catch (e) {
      setState(() {
        scanResultMessage = 'Server error: ${e.toString()}';
        scanResultColor = Colors.red;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
 
  Future<Map<String, dynamic>> sendPostRequest(int categoryId, int componentId) async {
    final url = Uri.parse('http://172.191.111.81:8081/api/components');
 
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'category_id': categoryId,
        'component_id': componentId,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
 
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send data. Status code: ${response.statusCode}. Response: ${response.body}');
    }
  }
  
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: const Text('Scanner Page'),
        backgroundColor: Colors.brown, 
        toolbarHeight: 60.0,
        titleTextStyle: const TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Barcode from Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade300,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: scanBarcodeFromImage,
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : scanBarcode,
                  child: const Text('Start scanning barcode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                Text(
                  scanResultMessage,
                  style: TextStyle(
                    color: scanResultColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                scanResultMessage = '';
                                scanResultColor = Colors.transparent;
                              });
                            },
                      child: const Text('Clear'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManualInputPage(
                                    onBarcodeSubmitted: (barcode) {
                                      processBarcode(barcode);
                                    },
                                  ),
                                ),
                              );
                            },
                      child: const Text('Manual Input'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryPage(historyRecords: _historyRecords),
                            ),
                          );
                        },
                  child: const Text('History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
 
class ManualInputPage extends StatefulWidget {
  final Function(String)? onBarcodeSubmitted;
 
  const ManualInputPage({Key? key, this.onBarcodeSubmitted}) : super(key: key);
 
  @override
  _ManualInputPageState createState() => _ManualInputPageState();
}
 
class _ManualInputPageState extends State<ManualInputPage> {
  final TextEditingController _barcodeController = TextEditingController();
  String scanResultMessage = '';
  Color scanResultColor = Colors.transparent;
  bool isLoading = false;
 
  void processManualInput() {
    final barcode = _barcodeController.text;
    if (barcode.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(barcode)) {
      setState(() {
        scanResultMessage = 'Invalid barcode: must be 10 digits';
        scanResultColor = Colors.red;
      });
      return;
    }
 
    setState(() {
      isLoading = true;
      scanResultMessage = 'Processing...';
      scanResultColor = Colors.blue;
    });
 
    if (widget.onBarcodeSubmitted != null) {
      widget.onBarcodeSubmitted!(barcode);
    }
 
    setState(() {
      scanResultMessage = 'Scan correct';
      scanResultColor = Colors.green;
      isLoading = false;
    });
 
    Navigator.pop(context);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Manual Input'),
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        toolbarHeight: 60.0,
        titleTextStyle: const TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Barcode',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : processManualInput,
                  child: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  scanResultMessage,
                  style: TextStyle(
                    color: scanResultColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
 
class HistoryPage extends StatefulWidget {
  final List<String> historyRecords;
 
  const HistoryPage({Key? key, required this.historyRecords}) : super(key: key);
 
  @override
  _HistoryPageState createState() => _HistoryPageState();
}
 
class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  String _selectedText = '';
 
  void _clearHistory() {
    setState(() {
      widget.historyRecords.clear();
    });
  }
 
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
 
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
 
  void _copyAllText() {
    final allText = widget.historyRecords.join('\n');
    Clipboard.setData(ClipboardData(text: allText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All content copied to clipboard')),
    );
  }
 
  void _copySelectedText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected content copied to clipboard')),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.brown,
        titleTextStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy all',
            onPressed: _copyAllText,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward, color: Colors.white),
            onPressed: _scrollToTop,
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: SelectableText.rich(
                  TextSpan(
                    children: widget.historyRecords.map((record) {
                      return TextSpan(
                        text: '$record\n',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      );
                    }).toList(),
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, color: Colors.white),
            onPressed: _scrollToBottom,
          ),
          if (_selectedText.isNotEmpty)
            ElevatedButton(
              onPressed: () => _copySelectedText(_selectedText),
              child: const Text('Copy Selected'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Return'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 48),
                ),
              ),
              ElevatedButton(
                onPressed: _clearHistory,
                child: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
