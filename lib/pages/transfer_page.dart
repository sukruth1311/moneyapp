import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransferPage extends StatelessWidget {
  final TextEditingController recipientRollController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  void transfer(BuildContext context) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) throw "User not logged in.";

      // Fetch sender data
      final senderDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!senderDoc.exists) throw "Sender not found.";

      final recipientQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('rollNumber', isEqualTo: recipientRollController.text.trim())
          .get();

      if (recipientQuery.docs.isEmpty) throw "Recipient not found.";

      final senderPoints = senderDoc['points'];
      final amount = int.tryParse(amountController.text.trim()) ?? 0;

      if (amount <= 0) throw "Invalid amount.";
      if (senderPoints < amount) throw "Insufficient points.";

      // Verify PIN
      final storedPin = senderDoc['pin'];
      if (storedPin != pinController.text.trim()) throw "Invalid PIN.";

      // Update balances and record transaction
      final recipientDoc = recipientQuery.docs.first;
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction
            .update(senderDoc.reference, {'points': senderPoints - amount});
        transaction.update(recipientDoc.reference, {
          'points': recipientDoc['points'] + amount,
        });

        // Add transaction history for sender
        transaction.set(
          FirebaseFirestore.instance
              .collection('transactions')
              .doc(senderDoc.id)
              .collection('history')
              .doc(),
          {
            'type': 'Debit',
            'amount': amount,
            'recipient': recipientDoc['rollNumber'],
            'timestamp': FieldValue.serverTimestamp(),
          },
        );

        // Add transaction history for recipient
        transaction.set(
          FirebaseFirestore.instance
              .collection('transactions')
              .doc(recipientDoc.id)
              .collection('history')
              .doc(),
          {
            'type': 'Credit',
            'amount': amount,
            'sender': senderDoc['rollNumber'],
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transfer Successful!")),
      );

      // Clear input fields
      recipientRollController.clear();
      amountController.clear();
      pinController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transfer Points")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: recipientRollController,
              decoration:
                  const InputDecoration(labelText: "Recipient Roll Number"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(labelText: "PIN"),
              obscureText: true, // Secure PIN input
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => transfer(context),
              child: const Text("Transfer"),
            ),
          ],
        ),
      ),
    );
  }
}
