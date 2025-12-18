import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parents_app/controller/auth_controller.dart';
import 'package:parents_app/pages/HomeScreen/navigation_bar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  void _handleSignup() async {
    String email = _emailController.text.trim();
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();
    String confirm = _confirmPasswordController.text.trim();

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Invalid Email");
      return;
    }
    if (password != confirm) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    bool success = await _authController.signUpWithEmail(email, password, name);
    if (success) {
      Get.offAll(() => const MyHomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
               const Icon(Icons.person_add, size: 80, color: Colors.green),
               const SizedBox(height: 20),
               TextField(
                 controller: _nameController,
                 decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
               ),
               const SizedBox(height: 15),
               TextField(
                 controller: _emailController,
                 decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                 keyboardType: TextInputType.emailAddress,
               ),
               const SizedBox(height: 15),
               TextField(
                 controller: _passwordController,
                 decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                 obscureText: true,
               ),
               const SizedBox(height: 15),
               TextField(
                 controller: _confirmPasswordController,
                 decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder()),
                 obscureText: true,
               ),
               const SizedBox(height: 25),
               Obx(() => _authController.isLoading.value 
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("SIGN UP", style: TextStyle(color: Colors.white)),
                      ),
                    )
               )
            ],
          ),
        ),
      ),
    );
  }
}
