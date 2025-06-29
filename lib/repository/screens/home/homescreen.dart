import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

      Future.microtask(() {
        setState(() {
          employeeId = empId;
          name = data['name'];
          profileImageUrl = data['profileImage'] ?? '';
        });
      });
    } catch (e) {
      print("Error loading employee info: $e");
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressed = await compressImage(File(pickedFile.path));
      if (compressed != null) {
        setState(() => selectedImage = File(compressed.path));
      } else {
        setState(() => selectedImage = File(pickedFile.path)); // fallback
      }
    }
  }

  Future<XFile?> compressImage(File file) async {
    final dir = await Directory.systemTemp.createTemp();
    final targetPath = '${dir.path}/temp_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return result;
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(imageKitUploadUrl));
      request.fields['fileName'] = 'worker_upload.jpg';
      request.fields['publicKey'] = imageKitPublicKey;
      request.fields['useUniqueFileName'] = 'true';
      request.files.add(await http.MultipartFile.fromPath(
        'file', imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
          Text('ID: ${employeeId ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pop(context),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Color.fromARGB(255, 255, 187, 0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      child: Row(
        children: [
          Image.asset('assets/images/houzylogoimage.png', height: 40),
          const Spacer(),
          GestureDetector(
            onTap: _showProfileDrawer,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage('assets/images/placeholder.png') as ImageProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: Column(
        children: [
          buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("📋 Today's Bookings",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    const Text("Only Today", style: TextStyle(fontSize: 14)),
                    Switch(
                      value: showOnlyToday,
                      activeColor: Colors.green,
                      onChanged: (val) => setState(() => showOnlyToday = val),
                    ),
                  ],
                ),
              ],
            ),
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
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(2, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📅 Date: ${_formatDate(data['date'])}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text("⏰ Time: ${data['timeSlot']}"),
                            Text("🧹 Duration: ${data['duration']}"),
                            Text("👷‍♂️ Workers: ${data['workers']}"),
                            Text("🐾 Pet Friendly: ${data['isPetFriendly'] == true ? 'Yes' : 'No'}"),
                            if (data.containsKey('instructions'))
                              Text("📝 Instructions: ${data['instructions']}"),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: selectedImage == null
                                  ? ElevatedButton.icon(
                                      key: const ValueKey("uploadButton"),
                                      onPressed: pickImage,
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text("Upload Work Image"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orangeAccent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                    )
                                  : Column(
                                      key: const ValueKey("previewImage"),
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(selectedImage!,
                                              height: 150, fit: BoxFit.cover),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () => uploadImage(selectedImage!),
                                              icon: const Icon(Icons.cloud_upload),
                                              label: const Text("Upload Now"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => setState(() => selectedImage = null),
                                              icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                            )
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
