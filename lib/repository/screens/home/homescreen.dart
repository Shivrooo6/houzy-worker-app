import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _location = "";
  final TextEditingController _searchController = TextEditingController();
  bool _locationFetched = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final Placemark place = placemarks[0];

    setState(() {
      _location = "${place.locality}, ${place.administrativeArea}";
      _locationFetched = true;
    });
  }

  final List<Map<String, dynamic>> testimonials = [
    {"name": "Mike Chen", "text": "Love the convenience and quality. They work around my schedule perfectly.", "stars": 5},
    {"name": "Emily Davis", "text": "The deep cleaning was incredible. Every corner of my home sparkles now!", "stars": 4},
    {"name": "Emily Davis", "text": "The deep cleaning was incredible. Every corner of my home sparkles now!", "stars": 4},
    {"name": "Emily Davis", "text": "The deep cleaning was incredible. Every corner of my home sparkles now!", "stars": 4},
    {"name": "Emily Davis", "text": "The deep cleaning was incredible. Every corner of my home sparkles now!", "stars": 3},
  ];

  Widget _buildTopHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 62),
                child: SizedBox(
                  width: 130,
                  height: 45,
                  child: Image.asset("assets/images/houzylogoimage.png"),
                ),
              ),
              IconButton(
                icon: Image.asset('assets/images/notebook.png', height: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
              GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            "Professional",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const Text(
            "House Cleaning",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0XFFF54A00),
            ),
          ),
          Row(
            children: const [
              Text(
                "Service You Can ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Trust",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 255, 96),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Book trusted, top-rated cleaners in your area. Flexible scheduling, eco-friendly products, and 100% satisfaction guaranteed.",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xFFE6F4EA),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: Color(0XFFF54A00), size: 13),
                    SizedBox(width: 2),
                    Flexible(
                      child: Text("Insured & Bonded", style: TextStyle(fontSize: 9, color: Colors.black54), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
              Container(
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xFFE6F4EA),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Color(0XFFF54A00), size: 14),
                    SizedBox(width: 2),
                    Flexible(
                      child: Text("4.9★ Avgerage Rating", style: TextStyle(fontSize: 9, color: Colors.black54), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xFFE6F4EA),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                child: Row(
                  children: [
                    Icon(Icons.flash_on, color: Color(0XFFF54A00), size: 13),
                    SizedBox(width: 2),
                    Flexible(
                      child: Text("Same Day Booking", style: TextStyle(fontSize: 9, color: Colors.black54), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/servicesimage.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Text(
                  "Choose Your Cleaning Service",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Select the perfect cleaning service for your needs"),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "What Our Customers Say",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: testimonials.map((t) => _TestimonialCard(
                    name: t['name'],
                    text: t['text'],
                    stars: t['stars'],
                  )).toList(),
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Column(
                  children: [
                    ElevatedButton(onPressed: null, child: Text("Add Image")),
                    SizedBox(height: 10),
                    ElevatedButton(onPressed: null, child: Text("Upload Images")),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: const [
                    Text("Houzy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                    Text("Professional cleaning services you can trust"),
                    SizedBox(height: 8),
                    Text("Privacy Policy    Terms of Service    Contact Us", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String text;
  final int stars;

  const _TestimonialCard({
    required this.name,
    required this.text,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(stars, (_) => const Icon(Icons.star, color: Colors.amber, size: 16)),
            ),
            const SizedBox(height: 8),
            Text('"$text"'),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
