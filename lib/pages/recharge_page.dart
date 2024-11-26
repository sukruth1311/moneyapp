import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  late Razorpay _razorpay;
  final TextEditingController _amountController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  void _startPayment(int amount) {
    var options = {
      'key': 'rzp_live_6pghNx8JyHM5eA', // Replace with your Razorpay API Key
      'amount': amount * 100, // Amount in paise
      'name': 'Campus App',
      'description': 'Recharge CampusPoints',
      'prefill': {
        'email': currentUser?.email,
        'contact': '', // Add user's contact if available
      },
      'currency': 'INR',
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      int amount = int.parse(_amountController.text);
      // Update the user's points in Firestore
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);

      await userDoc.update({
        'points': FieldValue.increment(amount), // Increment points by amount
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Payment Successful! ${amount} CampusPoints added.")),
      );

      _amountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating points: $e")),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet selected: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recharge CampusPoints")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Amount (INR)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int? amount = int.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  _startPayment(amount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter a valid amount.")),
                  );
                }
              },
              child: const Text("Recharge"),
            ),
          ],
        ),
      ),
    );
  }
}
