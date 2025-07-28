import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BecomeCreatorScreen extends StatefulWidget {
  const BecomeCreatorScreen({super.key});

  @override
  State<BecomeCreatorScreen> createState() => _BecomeCreatorScreenState();
}

class _BecomeCreatorScreenState extends State<BecomeCreatorScreen> {
  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _becomeCreator() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isCreator': true,
        'creatorSince': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are now a creator!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Creator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Creator Terms & Conditions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'By becoming a creator on Rovify, you agree to the following terms:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            _buildTermItem('1. You are responsible for the events you create.'),
            _buildTermItem('2. All events must comply with our community guidelines.'),
            _buildTermItem('3. You must provide accurate information about your events.'),
            _buildTermItem('4. Rovify may take a commission on ticket sales.'),
            _buildTermItem('5. You must respond to attendee inquiries in a timely manner.'),
            const SizedBox(height: 30),
            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I agree to the terms and conditions of becoming a Rovify creator',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _becomeCreator,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'BECOME A CREATOR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}