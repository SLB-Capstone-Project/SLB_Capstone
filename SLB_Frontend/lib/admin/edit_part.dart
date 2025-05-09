import 'package:flutter/material.dart';

class EditPartPage extends StatefulWidget {
  final int partNumber;
  final int partId;
  final String partName;
  final int borrowedEmployeeId;
  final String status;
  final int cost;
  final int productId;

  const EditPartPage({
    super.key,
    required this.partNumber,
    required this.partId,
    required this.partName,
    required this.borrowedEmployeeId,
    required this.status,
    required this.cost,
    required this.productId,
  });

  @override
  State<EditPartPage> createState() => _EditPartPageState();
}

class _EditPartPageState extends State<EditPartPage> {
  final _formKey = GlobalKey<FormState>();
  // late TextEditingController _partNumberController;
  // late TextEditingController _partIdController;
  late TextEditingController _partNameController;
  // late TextEditingController _borrowedEmployeeIdController;
  late TextEditingController _costController;
  late TextEditingController _productIdController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    // _partNumberController = TextEditingController(
    //   text: widget.partNumber.toString(),
    // );
    // _partIdController = TextEditingController(text: widget.partId.toString());
    _partNameController = TextEditingController(text: widget.partName);
    // _borrowedEmployeeIdController = TextEditingController(
    //   text: widget.borrowedEmployeeId.toString(),
    // );
    _costController = TextEditingController(text: widget.cost.toString());
    _productIdController = TextEditingController(
      text: widget.productId.toString(),
    );
    _selectedStatus = widget.status;
  }

  @override
  void dispose() {
    // _partNumberController.dispose();
    // _partIdController.dispose();
    _partNameController.dispose();
    // _borrowedEmployeeIdController.dispose();
    _costController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'partNumber': int.parse(widget.partNumber.toString()),
        'partId': int.parse(widget.partId.toString()),
        'partName': _partNameController.text,
        'borrowedEmployeeId': int.parse(widget.borrowedEmployeeId.toString()),
        'status': _selectedStatus,
        'cost': int.parse(_costController.text),
        'productId': int.parse(_productIdController.text),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Part', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // _buildNumberField(_partNumberController, 'Part Number'),
              // const SizedBox(height: 16),
              // _buildNumberField(_partIdController, 'Part ID'),
              const SizedBox(height: 16),
              _buildTextField(_partNameController, 'Part Name'),
              // const SizedBox(height: 16),
              // _buildNumberField(
              //   _borrowedEmployeeIdController,
              //   'Borrowed Employee ID',
              // ),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 16),
              _buildNumberField(_costController, 'Cost'),
              const SizedBox(height: 16),
              _buildNumberField(_productIdController, 'Product ID'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B544C),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7B544C), width: 1),
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) return 'Please enter $label';
        if (int.tryParse(value) == null) return 'Please enter a valid number';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7B544C), width: 1),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      items:
          ['available', 'borrow-out']
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
      onChanged: (String? value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      },
      dropdownColor: Colors.grey[900],
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
