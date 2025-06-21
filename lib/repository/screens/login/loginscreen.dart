import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houzy/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:houzy/repository/widgets/uihelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('employee')
          .doc(empId)
          .get();

      if (!doc.exists) {
        _showError("Employee ID not found.");
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final storedPassword = data['password'];

      if (password != storedPassword) {
        _showError("Incorrect password.");
        return;
      }

      // ✅ Save login session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('employeeId', empId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
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
              if (empId.isEmpty || newPassword.isEmpty) {
                _showError("All fields are required.");
                return;
              }

              try {
                final doc = await FirebaseFirestore.instance
                    .collection('employee')
                    .doc(empId)
                    .get();

                if (!doc.exists) {
                  _showError("Employee ID not found.");
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('employee')
                    .doc(empId)
                    .update({'password': newPassword});

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated successfully")),
                );
              } catch (e) {
                _showError("Failed to reset password.");
              }
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
