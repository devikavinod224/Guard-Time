import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parents_app/pages/HomeScreen/navigation_bar.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/models.dart';
import 'package:parents_app/utils/widgets.dart';

class LoginPage extends StatefulWidget {
  final String? mobileNumber;
  const LoginPage({super.key, this.mobileNumber});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  void onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Create a dummy user
    UserModel dummyUser = UserModel(
      id: "mock_user_id_123",
      firstName: "Test",
      lastName: "User",
      email: emailController.text.trim(),
      phone: "9999999999",
      isSignedIn: true,
      devices: [],
    );

    // Save to AppState
    AppState().user = dummyUser;

    setState(() {
      isLoading = false;
    });

    // Navigate to Home
    Get.offAll(() => const MyHomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.07,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.08,
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 80,
                    foregroundImage: AssetImage(
                      Get.isDarkMode
                          ? 'assets/images/TeenCareIcon.png'
                          : 'assets/images/TeenCareIcon.png',
                    ),
                  ),
                ),
              ),
              Text(
                "Welcome Back",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                "Login to continue",
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Center(
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButtonCustomized(
                          text: "Login",
                          color: Theme.of(context).primaryColor,
                          onPressed: onSubmit,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
