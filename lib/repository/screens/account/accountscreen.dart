import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:houzy/repository/widgets/uihelper.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actionsIconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Image.asset(
              'assets/images/houzylogoimage.png',
              height: 50,
            ),
            const Spacer(),
            IconButton(
              icon: UiHelper.CustomImage(img: 'notebook.png'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => _ongoingSubscriptionSheet(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                // Handle cart logic here
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? "No email",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.subscriptions, color: Color(0xFFF54A00)),
              title: const Text("My Plans"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to My Plans
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Color(0xFFF54A00)),
              title: const Text("My Ratings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to Ratings
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Color(0xFFF54A00)),
              title: const Text("Manage Payment Methods"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to payment method screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFFF54A00)),
              title: const Text("About Us"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  isScrollControlled: true,
                  builder: (context) => _aboutUsSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _ongoingSubscriptionSheet() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Currently Ongoing Subscription",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text("All Current ongoing subscriptions come here"),
            const SizedBox(height: 12),
            ...List.generate(3, (index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Service Name"),
                      SizedBox(height: 15),
                      Text("Card Content", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF54A00),
                      minimumSize: Size(80, 32),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text("Detailed View", style: TextStyle(fontSize: 12)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
}

Widget _aboutUsSheet() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About Us",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
          "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
          "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi "
          "ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit "
          "in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint "
          "occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
