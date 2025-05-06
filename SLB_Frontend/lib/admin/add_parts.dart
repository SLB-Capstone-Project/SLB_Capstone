import 'package:flutter/material.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _selectedType = 'Part';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add Product / Part',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_idController, 'Part ID'),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Part Name'),
              const SizedBox(height: 16),
              _buildTextField(_categoryController, 'Category'),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B544C),
                  minimumSize: const Size(double.infinity, 50),
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
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items:
          ['Product', 'Part']
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _selectedType = value!),
      decoration: InputDecoration(
        labelText: 'Type',
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dropdownColor: Colors.grey[900],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'id': _idController.text,
        'name': _nameController.text,
        'category': _categoryController.text,
        'type': _selectedType,
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}