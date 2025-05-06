import 'package:flutter/material.dart';
import 'employee_management.dart';
import 'parts_management.dart';
import 'package:file_selector/file_selector.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:barcode_widget/barcode_widget.dart';

class ManagementSelectionPage extends StatelessWidget {
  const ManagementSelectionPage({super.key});

  Future<void> _printBarcodes(BuildContext context) async {
    try {
      // 1. Select Excel file
      const xlsxTypeGroup = XTypeGroup(
        label: 'Excel Files',
        extensions: ['xlsx', 'xls'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: [xlsxTypeGroup],
      );

      if (file == null) return;

      // 2. Read Excel data
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Get barcodes from first column
      final sheet = excel.tables.values.first;
      final barcodes = sheet.rows
          .where((row) => row.isNotEmpty && row[0] != null)
          .map((row) => row[0]!.value.toString())
          .toList();

      if (barcodes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No barcode data found in Excel')),
        );
        return;
      }

      // 3. Generate PDF with QR codes
      final pdf = pw.Document();

      // PDF layout parameters
      const qrSize = 80.0; // QR code size in points (1/72 inch)
      const margin = 20.0; // Page margins
      const spacing = 15.0; // Space between QR codes
      const columns = 4; // QR codes per row
      const rowsPerPage = 5; // Rows per page
      const qrCodesPerPage = columns * rowsPerPage;

      // Add text style
      final textStyle = pw.TextStyle(fontSize: 10);

      for (var i = 0; i < barcodes.length; i += qrCodesPerPage) {
        final pageBarcodes = barcodes.sublist(
            i,
            i + (i + qrCodesPerPage > barcodes.length ? barcodes.length - i : qrCodesPerPage)
        );

        pdf.addPage(
          pw.Page(
            margin: pw.EdgeInsets.all(margin),
            build: (context) {
              return pw.GridView(
                crossAxisCount: columns,
                childAspectRatio: 1,
                children: [
                  for (final barcode in pageBarcodes)
                    pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(
                          width: qrSize,
                          height: qrSize,
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(), // Using QR code format
                            data: barcode,
                            width: qrSize,
                            height: qrSize,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          barcode,
                          style: textStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      }

      // 4. Save and open PDF
      final outputDir = await getTemporaryDirectory();
      final outputFile = File('${outputDir.path}/qr_codes_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await outputFile.writeAsBytes(await pdf.save());
      await OpenFile.open(outputFile.path);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Management System'),
        backgroundColor: Colors.brown,
        toolbarHeight: 60,
        titleTextStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildManagementButton(
              'Employee Management',
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmployeePage()),
              ),
            ),
            const SizedBox(height: 30),
            _buildManagementButton(
              'Inventory Management',
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PartManagementPage()),
              ),
            ),
            const SizedBox(height: 30),
            _buildManagementButton(
              'Print QR Codes',
                  () => _printBarcodes(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}