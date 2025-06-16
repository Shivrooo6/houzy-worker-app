import 'package:flutter/material.dart';
import 'package:houzy/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:houzy/repository/widgets/uihelper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _employeePasswordController = TextEditingController();

  // 🚫 Temporarily bypass login logic
  void _handleEmployeeLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNavScreen()),
    );
  }

  void _handleForgotPassword() {
    String empId = '';
    String newPassword = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => empId = value.trim(),
              decoration: const InputDecoration(labelText: 'Employee ID'),
            ),
            TextField(
              onChanged: (value) => newPassword = value.trim(),
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // This block is not changed – it handles actual password reset
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password updated (mocked)")),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 350,
                      height: 80,
                      child: UiHelper.CustomImage(img: "houzylogoimage.png"),
                    ),
                    const Positioned(
                      top: -2,
                      left: 12,
                      child: Icon(Icons.star, color: Color(0xFFFE600E), size: 18),
                    ),
                    const Positioned(
                      top: -3,
                      right: 20,
                      child: Icon(Icons.star, color: Color(0xFFFE600E), size: 20),
                    ),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      child: Icon(Icons.star, color: Color(0xFFFE600E), size: 16),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 10,
                      child: Icon(Icons.star, color: Color(0xFFFE600E), size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                UiHelper.CustomText(
                  text: "Professional House Cleaning Service",
                  color: const Color(0xFFFE600E),
                  fontweight: FontWeight.bold,
                  fontsize: 10,
                  fontfamily: "bold",
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0XFFe7dfdd),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Center(
                            child: UiHelper.CustomText(
                              text: "Login",
                              color: Colors.black,
                              fontweight: FontWeight.w500,
                              fontsize: 20,
                              fontfamily: "bold",
                            ),
                          ),
                          const SizedBox(height: 20),
                          Transform.translate(
                            offset: const Offset(33, 0),
                            child: UiHelper.CustomImage(img: "customerimage.png"),
                          ),
                          TextField(
                            controller: _employeeIdController,
                            decoration: const InputDecoration(
                              labelText: "Employee ID",
                              prefixIcon: Icon(Icons.badge),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _employeePasswordController,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text("Forgot Password?"),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleEmployeeLogin,
                              child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFE600E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              text: 'By continuing, you agree to our ',
                              style: const TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: 'T&C',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const TextSpan(text: ' policy.'),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
