import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool showOnlyToday = false;

  String? employeeId;
  String? name;
  String? profileImageUrl;

  final String imageKitUploadUrl = "https://upload.imagekit.io/api/v1/files/upload";
  final String imageKitPublicKey = "public_5IFyWDvjUjnWuGDkuaMN7LMJm4E=";
  final String imageKitPrivateKey = "private_yAss1el231dUVKnmNcqEvjC0Mt0=";

  @override
  void initState() {
    super.initState();
    _loadEmployeeInfo();
  }

  Future<void> _loadEmployeeInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final empId = prefs.getString('employeeId');

      if (empId == null) return;

      final doc = await FirebaseFirestore.instance.collection('employees').doc(empId).get();

      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      setState(() {
        employeeId = empId;
        name = data['name'];
        profileImageUrl = data['profileImage'] ?? '';
      });
    } catch (e) {
      print("Error loading employee info: $e");
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedImage = File(pickedFile.path));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(imageKitUploadUrl));
      request.fields['fileName'] = 'worker_upload.jpg';
      request.fields['publicKey'] = imageKitPublicKey;
      request.fields['useUniqueFileName'] = 'true';
      request.files.add(await http.MultipartFile.fromPath(
        'file', imageFile.path, contentType: MediaType('image', 'jpeg')));

      final auth = base64Encode(utf8.encode('$imageKitPrivateKey:'));
      request.headers['Authorization'] = 'Basic $auth';

      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Image uploaded")));
        setState(() => selectedImage = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Upload failed")));
      }
    } catch (e) {
      print("Upload error: $e");
    }
  }

  void _showProfileDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/images/placeholder.png') as ImageProvider,
          ),
          const SizedBox(height: 8),
          Text(name ?? 'No name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('ID: $employeeId', style: const TextStyle(color: Colors.grey)),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Profile Screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('employeeId');
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  bool isTodayBooking(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
      child: Row(
        children: [
          Image.asset('assets/images/houzylogoimage.png', height: 40),
          const Spacer(),
          GestureDetector(
            onTap: _showProfileDrawer,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!)
                  : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildHeader(),
          Row(
            children: [
              const SizedBox(width: 16),
              const Text("Show only today's bookings"),
              Switch(
                value: showOnlyToday,
                onChanged: (val) => setState(() => showOnlyToday = val),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filtered = showOnlyToday
                    ? docs.where((e) => isTodayBooking(e['date'])).toList()
                    : docs;

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final data = filtered[i].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📅 Date: ${_formatDate(data['date'])}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("⏰ Time: ${data['timeSlot']}"),
                            Text("🧹 Duration: ${data['duration']}"),
                            Text("👷‍♂️ Workers: ${data['workers']}"),
                            Text("🐾 Pet Friendly: ${data['isPetFriendly'] == true ? 'Yes' : 'No'}"),
                            Text("📝 Instructions: ${data['instructions']}"),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: pickImage,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text("Upload Work Image"),
                            ),
                            if (selectedImage != null) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(selectedImage!, height: 150),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () => uploadImage(selectedImage!),
                                icon: const Icon(Icons.cloud_upload),
                                label: const Text("Upload Now"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
