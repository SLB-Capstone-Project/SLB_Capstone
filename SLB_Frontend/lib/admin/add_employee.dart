import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart'; // Import for hashing
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;


class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String selectedType = 'Regular User';
  bool _obscurePassword = true;

  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hashed password
  }

  Future<void> _register() async {
    if (globals.token == "") {
      print("No token found");
      return;
    }
    if (idController.text.isEmpty || nameController.text.isEmpty || departmentController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required"), backgroundColor: Colors.red),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    final String apiUrl = "http://172.191.111.81:8081/api/employee/";

    // Hash the password before sending it to the server
    String hashedPassword = hashPassword(passwordController.text);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': globals.token, // Include JWT in header
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "employee_id": idController.text,
          "employee_name": nameController.text,
          "password": hashedPassword,
          "department": departmentController.text,
          "user_type": selectedType,
        }),
      );
      print(response.statusCode);
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Register Success!")),
        );

        Navigator.pop(context);
      } else {
        print(responseBody);
        throw Exception('Failed to add employees: ${response.statusCode}');
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Employee', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                controller: idController,
                label: 'Employee ID',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter an ID' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: nameController,
                label: 'Employee Name',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: departmentController,
                label: 'Department',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a department' : null,
              ),
              const SizedBox(height: 16),

              buildTextField(
                controller: passwordController,
                label: 'Password',
                obscureText: _obscurePassword,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a password' : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
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

                items: ['Admin', 'Regular User']

                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    _register();

                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B544C),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,

    bool obscureText = false,
    Widget? suffixIcon,

  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: validator,

      obscureText: obscureText,

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        suffixIcon: suffixIcon,
      ),
    );
  }
}

