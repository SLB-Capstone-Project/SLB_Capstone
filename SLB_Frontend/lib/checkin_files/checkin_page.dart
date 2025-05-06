import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart' as barcode_scan;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async'; // 用于 Duration
import '../globals.dart' as global;


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
    if (!RegExp(r'^[0-9]+$').hasMatch(barcode) || barcode.length > 6) {
      setState(() {
        scanResultMessage = 'Invalid barcode: must be up to 6 digits';
        scanResultColor = Colors.red;
      });
      return;
    }

    int partId = int.parse(barcode);

    print('DEBUG: Scanned PartID: $partId');
    print('DEBUG: Current token: ${global.token}');

    setState(() {
      isLoading = true;
      scanResultMessage = 'Part ID scanned: $partId';
      scanResultColor = Colors.green;
      currentPartId = partId;
      _historyRecords.add('${_historyRecords.length + 1}.   $partId'); // 添加序号和空格
      isLoading = false;
    });
  }


  Future<void> borrowItem() async {
    print('Attempting borrow with PartID: $currentPartId');

    // Validate input
    if (currentPartId == null) {
      setState(() {
        scanResultMessage = 'Please scan a barcode first';
        scanResultColor = Colors.red;
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      scanResultMessage = 'Processing borrow...';
      scanResultColor = Colors.blue;
    });

    try {
      final url = Uri.parse('http://172.191.111.81:8081/api/activities/borrow');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': global.token,
        },
        body: jsonEncode({'part_id': currentPartId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          scanResultMessage = 'Borrow successful';
          scanResultColor = Colors.green;
        });
      } else {
        setState(() {
          scanResultMessage = 'Server error: ${response.statusCode}';
          scanResultColor = Colors.orange;
        });
      }
    } catch (e) {
      setState(() {
        scanResultMessage = 'Error: ${e.toString().replaceAll('\n', ' ')}';
        scanResultColor = Colors.red;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> returnItem() async {
    print('Attempting return with PartID: $currentPartId');

    // Validate input
    if (currentPartId == null) {
      setState(() {
        scanResultMessage = 'Please scan a barcode first';
        scanResultColor = Colors.red;
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      scanResultMessage = 'Processing return...';
      scanResultColor = Colors.blue;
    });

    try {
      final url = Uri.parse('http://172.191.111.81:8081/api/activities/return');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': global.token,
        },
        body: jsonEncode({'part_id': currentPartId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          scanResultMessage = 'Return successful';
          scanResultColor = Colors.green;
        });
      } else {
        setState(() {
          scanResultMessage = 'Server error: ${response.statusCode}';
          scanResultColor = Colors.orange;
        });
      }
    } catch (e) {
      setState(() {
        scanResultMessage = 'Error: ${e.toString().replaceAll('\n', ' ')}';
        scanResultColor = Colors.red;
      });
    } finally {
      setState(() => isLoading = false);
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
                // 已完全移除 ElevatedButton.icon (Scan Barcode from Image 按钮)
                ElevatedButton(
                  onPressed: isLoading ? null : scanBarcode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
                      onPressed: isLoading ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualInputPage(
                              onPartIdSubmitted: (partId) {
                                setState(() {
                                  currentPartId = partId;
                                  scanResultMessage = '$partId'; // 直接显示数字
                                  scanResultColor = Colors.green;
                                  _historyRecords.add('${_historyRecords.length + 1}   $partId'); // 修改记录格式
                                });
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
  final Function(int)? onPartIdSubmitted;
  const ManualInputPage({Key? key, this.onPartIdSubmitted}) : super(key: key);
  @override _ManualInputPageState createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final TextEditingController _barcodeController = TextEditingController();
  String scanResultMessage = '';
  Color scanResultColor = Colors.transparent;
  bool isLoading = false;

  void processManualInput() {
    final input = _barcodeController.text;

    if (!RegExp(r'^[0-9]+$').hasMatch(input) || input.length > 6) {
      setState(() {
        scanResultMessage = 'Digit length should not be bigger than 6';
        scanResultColor = Colors.red;
      });
      return;
    }

    setState(() {
      isLoading = true;
      scanResultMessage = 'Dealing...';
      scanResultColor = Colors.blue;
    });

    int partId = int.parse(input);

    if (widget.onPartIdSubmitted != null) {
      widget.onPartIdSubmitted!(partId);
    }

    setState(() {
      scanResultMessage = '$partId';
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
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: const InputDecoration(
                    labelText: 'Input Digit (<=6)',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : processManualInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Confirm', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 20),
                Text(
                  scanResultMessage,
                  style: TextStyle(
                    color: scanResultColor,
                    fontSize: 24.0,
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
  String _searchQuery = '';

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
    final formattedText = widget.historyRecords.join('\n');
    Clipboard.setData(ClipboardData(text: formattedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All content copied to clipboard')),
    );
  }

  // 依照 _searchQuery 做篩選，但不會改動原本的 index
  List<String> get filteredRecords {
    if (_searchQuery.isEmpty) {
      return widget.historyRecords;
    } else {
      return widget.historyRecords.where((record) {
        // 你可改成只檢查 part_id 欄位
        // 但這裡為簡易示範，先對整個 record 做搜尋
        return record.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // DataTable 標題/儲存格文字樣式
    const headerStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    const cellStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('History'),
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
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜尋列
          Container(
            color: Colors.brown.shade300,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // DataTable
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  headingRowColor:
                  MaterialStateProperty.all(Colors.brown.shade300),
                  columns: const [
                    DataColumn(
                      label: Center(
                        child: Text('Index', style: headerStyle),
                      ),
                    ),
                    DataColumn(
                      label: Center(
                        child: Text('part_id', style: headerStyle),
                      ),
                    ),
                  ],
                  rows: filteredRecords.map((record) {
                    // 假設 record = "2   109"
                    // 以空白分割 => parts[0] = "2", parts[1] = "109"
                    final parts = record.split(RegExp(r'\s+'));
                    final indexStr = parts.isNotEmpty ? parts[0] : '';
                    final partIdStr = parts.length >= 2 ? parts[1] : '';

                    return DataRow(
                      cells: [
                        // Index 欄位: 置中顯示, 不可複製
                        DataCell(
                          Center(child: Text(indexStr, style: cellStyle)),
                        ),
                        // part_id 欄位: 置中顯示, 點擊可複製
                        DataCell(
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (partIdStr.isNotEmpty) {
                                  Clipboard.setData(ClipboardData(text: partIdStr));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Copied part_id: $partIdStr'),
                                    ),
                                  );
                                }
                              },
                              child: Text(partIdStr, style: cellStyle),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // 上/下箭頭
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                color: Colors.white,
                onPressed: _scrollToTop,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                color: Colors.white,
                onPressed: _scrollToBottom,
              ),
            ],
          ),

          // Return/Clear
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                  child: const Text('Return'),
                ),
                ElevatedButton(
                  onPressed: _clearHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}