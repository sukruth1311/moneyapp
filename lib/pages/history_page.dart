import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: uid == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .doc(uid)
                  .collection('history')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No transactions found"));
                }

                final transactions = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      title: Text(
                          "${transaction['type']} - ${transaction['amount']} points"),
                      subtitle: Text(
                        transaction['type'] == 'Credit'
                            ? "From: ${transaction['sender']}"
                            : "To: ${transaction['recipient']}",
                      ),
                      trailing: Text(
                        (transaction['timestamp'] as Timestamp)
                            .toDate()
                            .toString(),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
