import 'package:flutter/material.dart';
import "../globals.dart" as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditEmployeePage extends StatefulWidget {
  final String id;
  final String name;
  final String department;
  final String type;

  const EditEmployeePage({
    super.key,
    required this.id,
    required this.name,
    required this.department,
    required this.type,
  });

  @override
  State<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController departmentController;
  late TextEditingController passwordController;
  late String selectedType;

  Future<void> _edit() async {
    if (globals.token == "") {
      print("No token found");
      return;
    }
    if (nameController.text.isEmpty ||
        departmentController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required, including password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = "http://4.227.176.4:8081/api/employee/";

    final body = {
      "employee_id": int.tryParse(idController.text) ?? 0,
      "employee_name": nameController.text,
      "password": passwordController.text,
      "department": departmentController.text,
      "user_type": selectedType,
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody["code"] == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Edit Success!")));
        Navigator.pop(context);
      } else {
        throw Exception('Failed to edit employee: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.id);
    nameController = TextEditingController(text: widget.name);
    departmentController = TextEditingController(text: widget.department);
    passwordController = TextEditingController();
    selectedType = widget.type;
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    departmentController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Edit Employee',
          style: TextStyle(color: Colors.white),
        ),
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
              buildTextField(
                controller: nameController,
                label: 'Employee Name',
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: departmentController,
                label: 'Department',
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: passwordController,
                label: 'Password',
                obscure: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: Colors.grey[900],
                decoration: InputDecoration(
                  labelText: 'User Type',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                items:
                    ['Admin', 'Regular User'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedType = value);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _edit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B544C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
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
