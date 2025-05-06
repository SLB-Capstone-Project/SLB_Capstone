import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class HistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> historyItems;

  const HistoryPage({super.key, required this.historyItems});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Operation History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(flex: 2, child: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                SizedBox(width: 40),
              ],
            ),
            const Divider(color: Colors.grey),

            Expanded(
              child: ListView.builder(
                itemCount: widget.historyItems.length,
                itemBuilder: (context, index) {
                  final item = widget.historyItems[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 2, child: Text(item['action'], style: const TextStyle(color: Colors.white))),
                          Expanded(flex: 3, child: Text(item['details'], style: const TextStyle(color: Colors.white))),
                          Expanded(flex: 2, child: Text(item['timestamp'].substring(0, 16), style: const TextStyle(color: Colors.white))),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            onPressed: () => _showItemActions(context, index),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Clear All History'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final partIds = widget.historyItems
        .where((item) => item['action'].toString().contains('Added'))
        .expand((item) {
      if (item['action'] == 'Added range') {
        final startId = item['params']['startId'];
        final endId = item['params']['endId'];
        final startNum = int.parse(startId.replaceAll('P', ''));
        final endNum = int.parse(endId.replaceAll('P', ''));
        return List.generate(endNum - startNum + 1,
                (i) => 'P${(startNum + i).toString().padLeft(3, '0')}');
      } else {
        return [item['params']['id']];
      }
    })
        .toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(10), // Apply margin here
            child: pw.GridView(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: partIds.map((id) => pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: id,
                width: 30,
                height: 30,
              )).toList(),
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'history-qrcodes.pdf',
    );
  }

  void _showItemActions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              // 实现编辑功能
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              setState(() {
                widget.historyItems.removeAt(index);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
