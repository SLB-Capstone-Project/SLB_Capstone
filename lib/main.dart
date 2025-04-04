import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart' as barcode_scan;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

String globalToken = '';
const String apiUsername = "Admin";
const String apiPassword = "123456";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    globalToken = await fetchAuthToken();
    print('Token successfully obtained. Length: ${globalToken.length}');
    print('Token successfully obtained: ${globalToken}...');
    runApp(const MyApp());
  } catch (e) {
    print('Failed to get token: $e');
    runApp(const TokenErrorApp());
  }
}

class TokenErrorApp extends StatelessWidget {
  const TokenErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Unaccessible, network connection error\n: $globalToken'),
        ),
      ),
    );
  }
}

Future<String> fetchAuthToken() async {
  final url = Uri.parse('http://172.191.111.81:8081/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'employee_name': apiUsername,
      'password': apiPassword,
    }),
  );

  print('Raw token response: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data'] ?? '';
  } else {
    throw Exception('Failed to get token: ${response.statusCode}');
  }
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
  int? currentPartId;

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

    // Convert to integer to remove leading zeros
    int partId = int.parse(componentId);

    print('DEBUG: Scanned barcode - Category: $categoryId, PartID: $partId');
    print('DEBUG: Current token: $globalToken');

    setState(() {
      isLoading = true;
      scanResultMessage = 'Barcode scanned: $categoryId $componentId';
      scanResultColor = Colors.green;
      currentPartId = int.parse(componentId);
      _historyRecords.add('${_historyRecords.length + 1}. $categoryId $componentId');
      isLoading = false;
    });
  }

  Future<void> borrowItem() async {
    print('DEBUG: Attempting borrow with PartID: $currentPartId, Token: $globalToken');
    if (currentPartId == null) {
      setState(() {
        scanResultMessage = 'Please scan a barcode first';
        scanResultColor = Colors.red;
      });
      return;
    }

    setState(() {
      isLoading = true;
      scanResultMessage = 'Processing borrow...';
      scanResultColor = Colors.blue;
    });

    final url = Uri.parse('http://172.191.111.81:8081/api/activities/borrow');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': globalToken,
        // 'Authorization': globalToken,
      },
      body: jsonEncode({
        'part_id': currentPartId,
        // 'employee_id': 2,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        scanResultMessage = 'Borrow operation successful';
        scanResultColor = Colors.green;
      });
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> returnItem() async {
    print('DEBUG: Attempting borrow with PartID: $currentPartId, Token: $globalToken');
    if (currentPartId == null) {
      setState(() {
        scanResultMessage = 'Please scan a barcode first';
        scanResultColor = Colors.red;
      });
      return;
    }

    setState(() {
      isLoading = true;
      scanResultMessage = 'Processing return...';
      scanResultColor = Colors.blue;
    });

    final url = Uri.parse('http://172.191.111.81:8081/api/activities/return');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${globalToken.trim()}',
        'Authorization': globalToken,
      },
      body: jsonEncode({
        'part_id': currentPartId,
        // 'employee_id': 2,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        scanResultMessage = 'Return operation successful';
        scanResultColor = Colors.green;
      });
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Start scanning barcode'),
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
                      onPressed: isLoading ? null : borrowItem,
                      child: const Text('Borrow'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48),
                      ),
                      onPressed: isLoading ? null : returnItem,
                      child: const Text('Return'),
                    ),
                  ],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                  child: const Text('History'),
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
  @override _ManualInputPageState createState() => _ManualInputPageState();
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
      scanResultMessage = 'Barcode accepted';
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Confirm'),
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
  @override _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  String _selectedText = '';

  void _clearHistory() => setState(() => widget.historyRecords.clear());
  void _scrollToTop() => _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  void _scrollToBottom() => _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  void _copyAllText() {
    Clipboard.setData(ClipboardData(text: widget.historyRecords.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All content copied to clipboard')));
  }
  void _copySelectedText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected content copied to clipboard')));
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
        actions: [IconButton(icon: const Icon(Icons.copy), tooltip: 'Copy all', onPressed: _copyAllText)],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          IconButton(icon: const Icon(Icons.arrow_upward, color: Colors.white), onPressed: _scrollToTop),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: SelectableText.rich(
                  TextSpan(children: widget.historyRecords.map((record) => TextSpan(text: '$record\n', style: const TextStyle(fontSize: 18, color: Colors.white))).toList()),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.arrow_downward, color: Colors.white), onPressed: _scrollToBottom),
          if (_selectedText.isNotEmpty)
            ElevatedButton(
              onPressed: () => _copySelectedText(_selectedText),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
              child: const Text('Copy Selected'),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white, minimumSize: const Size(120, 48)),
                child: const Text('Return'),
              ),
              ElevatedButton(
                onPressed: _clearHistory,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white, minimumSize: const Size(120, 48)),
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}