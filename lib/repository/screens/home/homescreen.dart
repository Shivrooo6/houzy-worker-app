import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Replace with your actual ImageKit private API key (DO NOT share this in public apps)
  static const String _imageKitPrivateKey = 'private_yAss1el231dUVKnmNcqEvjC0Mt0=';
  // Note: This key is just a placeholder. Use your actual ImageKit private key.

  // Sample assigned house data
  List<Map<String, String>> assignedHouses = [
    {
      'id': '001',
      'address': 'Villa 21, Palm Jumeirah',
      'date': '2025-06-17',
      'timeSlot': '10:00 AM - 12:00 PM'
    },
    {
      'id': '002',
      'address': 'Apartment 9B, Downtown Dubai',
      'date': '2025-06-17',
      'timeSlot': '2:00 PM - 4:00 PM'
    },
  ];

  // Show image source picker (camera or gallery)
  void _showImageSourcePicker(String houseId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Open Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickImage('camera', houseId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage('gallery', houseId);
            },
          ),
        ],
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(String source, String houseId) async {
    final PermissionStatus cameraPermission = await Permission.camera.request();
    final PermissionStatus storagePermission = await Permission.photos.request();

    if (cameraPermission.isGranted && storagePermission.isGranted) {
      final pickedFile = await _picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        await _uploadToImageKit(File(pickedFile.path), houseId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera or gallery permission denied")),
      );
    }
  }

  // Upload to ImageKit
  Future<void> _uploadToImageKit(File image, String houseId) async {
    const String uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
    final String authHeader = 'Basic ${base64Encode(utf8.encode('$_imageKitPrivateKey:'))}';

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['fileName'] = 'house_$houseId.jpg'
      ..fields['folder'] = '/houzy_worker_uploads'
      ..fields['useUniqueFileName'] = 'true'
      ..files.add(await http.MultipartFile.fromPath('file', image.path))
      ..headers['Authorization'] = authHeader;

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      final imageUrl = data['url'];
      print('Image uploaded: $imageUrl');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploaded: $imageUrl")),
      );
    } else {
      print('Upload failed: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Houzy Worker Home'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignedHouses.length,
        itemBuilder: (context, index) {
          final house = assignedHouses[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              house['address'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('ID: ${house['id']}'),
                            Text('Date: ${house['date']}'),
                            Text('Time: ${house['timeSlot']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showImageSourcePicker(house['id']!),
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Pic'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
