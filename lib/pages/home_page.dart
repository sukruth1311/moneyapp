import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyapp/pages/history_page.dart';
import 'package:moneyapp/pages/recharge_page.dart';
import 'package:moneyapp/pages/transfer_page.dart';
import 'package:moneyapp/pages/profile_page.dart'; // Import ProfilePage
// Import TransactionHistoryPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int points = 0; // Tracks the user's points
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchPoints(); // Fetch the initial points when the page loads
  }

  /// Fetch the user's points from Firestore
  Future<void> _fetchPoints() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          points = userDoc.data()!['points'] ?? 0; // Fetch 'points' field
        });
      }
    }
  }

  /// Update points in the UI when coming back from another page
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPoints(); // Refresh points when dependencies change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person), // Profile icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfilePage(), // Navigate to ProfilePage
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text(
              "Available CampusPoints: $points",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RechargePage(),
                ),
              ).then((_) => _fetchPoints()), // Refresh points after returning
              child: const Text("Recharge"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransferPage(),
                ),
              ).then((_) => _fetchPoints()), // Refresh points after returning
              child: const Text("Transfer Points"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionHistoryPage(),
                ),
              ),
              child: const Text("View Transaction History"),
            ),
          ],
        ),
      ),
    );
  }
}
