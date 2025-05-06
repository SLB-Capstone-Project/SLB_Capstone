import 'package:flutter/material.dart';

class EditPartPage extends StatefulWidget {
  final String id;
  final String name;
  final String category;
  final String type;

  const EditPartPage({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.type,
  });

  @override
  State<EditPartPage> createState() => _EditPartPageState();
}

class _EditPartPageState extends State<EditPartPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late String selectedType;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.id);
    nameController = TextEditingController(text: widget.name);
    categoryController = TextEditingController(text: widget.category);
    selectedType = widget.type;
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    categoryController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              buildTextField(controller: idController, label: 'Part ID'),
              const SizedBox(height: 16),
              buildTextField(controller: nameController, label: 'Part Name'),
              const SizedBox(height: 16),
              buildTextField(controller: categoryController, label: 'Category'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: Colors.grey[900],
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: const TextStyle(color: Colors.white),
                items: ['Product', 'Part'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedType = value);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('Updated ID: ${idController.text}');
                    print('Updated Name: ${nameController.text}');
                    print('Updated Category: ${categoryController.text}');
                    print('Updated Type: $selectedType');
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B544C),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
