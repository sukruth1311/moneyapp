import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyapp/auth/login_page.dart';
import 'package:moneyapp/pages/home_page.dart';
// Import LoginPage

class RegistrationPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  void register(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'rollNumber': rollNumberController.text.trim(),
        'pin': pinController.text.trim(),
        'department': departmentController.text.trim(),
        'points': 0, // Initial points
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true, // Hide password for security
            ),
            TextField(
              controller: rollNumberController,
              decoration: const InputDecoration(labelText: "Roll Number"),
            ),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(labelText: "Payment PIN"),
              obscureText: true, // Hide PIN for security
            ),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: "Department"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => register(context),
              child: const Text("Register"),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(), // Navigate to LoginPage
                    ),
                  );
                },
                child: const Text(
                  "Already have an account? Login here",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
