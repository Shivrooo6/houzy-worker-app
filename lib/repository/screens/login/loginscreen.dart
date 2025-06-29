import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:houzy/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:houzy/repository/widgets/uihelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _employeePasswordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final empId = prefs.getString('employeeId');
    if (empId != null && empId.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    }
  }

  Future<void> _handleEmployeeLogin() async {
    final empId = _employeeIdController.text.trim();
    final password = _employeePasswordController.text.trim();

    if (empId.isEmpty || password.isEmpty) {
      _showError("Please enter both Employee ID and Password.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://houzy-ozer.vercel.app/api/v1/mobile/worker/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': empId,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save login session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('employeeId', empId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavScreen()),
        );
      } else {
        _showError(data['message'] ?? "Invalid credentials.");
      }
    } catch (e) {
      _showError("Login failed. Please try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  const Positioned(top: -2, left: 12, child: Icon(Icons.star, color: Color(0xFFFE600E), size: 18)),
                  const Positioned(top: -3, right: 20, child: Icon(Icons.star, color: Color(0xFFFE600E), size: 20)),
                  const Positioned(bottom: 0, left: 0, child: Icon(Icons.star, color: Color(0xFFFE600E), size: 16)),
                  const Positioned(bottom: 0, right: 10, child: Icon(Icons.star, color: Color(0xFFFE600E), size: 14)),
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
                    padding: const EdgeInsets.all(16.0),
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
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleEmployeeLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFE600E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: const TextStyle(fontSize: 12),
                            children: [
                              TextSpan(text: 'T&C', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
      
    );
  }
}
