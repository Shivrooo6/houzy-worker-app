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

  Future<void> _pickImage(String source, String houseId) async {
    PermissionStatus cameraPermission = await Permission.camera.request();
    PermissionStatus storagePermission = await Permission.photos.request();

    if (cameraPermission.isGranted && storagePermission.isGranted) {
      final pickedFile = await _picker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _uploadToImageKit(File(pickedFile.path), houseId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permissions not granted")),
      );
    }
  }

  Future<void> _uploadToImageKit(File image, String houseId) async {
    const String uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
    const String publicKey = 'your_imagekit_public_api_key';
    const String privateKey = 'your_imagekit_private_api_key_base64_encoded';

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['fileName'] = 'house_$houseId.jpg'
      ..fields['folder'] = '/houzy_worker_uploads'
      ..fields['useUniqueFileName'] = 'true'
      ..files.add(await http.MultipartFile.fromPath('file', image.path))
      ..headers['Authorization'] = 'Basic $privateKey';

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      print('Image uploaded to: ${data['url']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploaded to: ${data['url']}")),
      );
    } else {
      print('Upload failed: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed")),
      );
    }
  }

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
              }),
          ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage('gallery', houseId);
              }),
        ],
      ),
    );
  }

  List<Map<String, String>> assignedHouses = [
    {'id': '001', 'address': 'Villa 21, Palm Jumeirah'},
    {'id': '002', 'address': 'Apartment 9B, Downtown Dubai'},
  ];

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
            child: ListTile(
              leading: const Icon(Icons.home, size: 40),
              title: Text('Assigned House: ${house['address']}'),
              subtitle: Text('ID: ${house['id']}'),
              trailing: ElevatedButton(
                onPressed: () => _showImageSourcePicker(house['id']!),
                child: const Text('Upload Pic'),
              ),
            ),
          );
        },
      ),
    );
  }
}
