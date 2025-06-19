import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool showOnlyToday = false;

  final String imageKitUploadUrl = "https://upload.imagekit.io/api/v1/files/upload";
  final String imageKitPublicKey = "public_5IFyWDvjUjnWuGDkuaMN7LMJm4E=";
  final String imageKitPrivateKey = "private_yAss1el231dUVKnmNcqEvjC0Mt0=";

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final status = await Permission.camera.request();
                if (!status.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Camera permission denied")));
                  return;
                }
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => selectedImage = File(pickedFile.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(imageKitUploadUrl));
      request.fields['fileName'] = 'worker_upload.jpg';
      request.fields['publicKey'] = imageKitPublicKey;
      request.fields['useUniqueFileName'] = 'true';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final auth = base64Encode(utf8.encode('$imageKitPrivateKey:'));
      request.headers['Authorization'] = 'Basic $auth';

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Image uploaded")));
        setState(() => selectedImage = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Upload failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  bool isTodayBooking(Timestamp timestamp) {
    final bookingDate = timestamp.toDate();
    final now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

  String _formatDate(dynamic date) {
    if (date == null) return "Not set";
    final ts = date as Timestamp;
    return "${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}";
  }

  Widget buildHeader() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("⚠️ User not logged in", style: TextStyle(color: Colors.red)),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('employees').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text("⚠️ Employee record not found", style: TextStyle(color: Colors.red)),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unknown';
        final employeeId = data['employeeId'] ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
          child: Row(
            children: [
              Image.asset('assets/images/houzylogoimage.png', height: 40),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('ID: $employeeId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : const AssetImage('assets/images/placeholder.png') as ImageProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Center(child: Text("No bookings available"));

                final bookings = snapshot.data!.docs;
                final filteredBookings = showOnlyToday
                    ? bookings.where((doc) => isTodayBooking(doc['date'])).toList()
                    : bookings;

                return ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${_formatDate(booking['date'])}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Time: ${booking['timeSlot']}"),
                            Text("Duration: ${booking['duration']}"),
                            Text("Workers: ${booking['workers']}"),
                            Text("Pet Friendly: ${booking['isPetFriendly'] ? 'Yes' : 'No'}"),
                            Text("Instructions: ${booking['instructions']}"),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: pickImage,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text("Upload Work Image"),
                            ),
                            if (selectedImage != null) ...[
                              const SizedBox(height: 12),
                              const Text("Preview Selected Image:",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(selectedImage!, height: 200),
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
