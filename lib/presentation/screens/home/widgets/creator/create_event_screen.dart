import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatorDashboardScreen extends StatelessWidget {
  final String userId;

  const CreatorDashboardScreen({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _fetchEvents() async {
    final events = await FirebaseFirestore.instance
        .collection('events')
        .where('hostID', isEqualTo: userId)
        .get();

    return events.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Dashboard')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("You haven’t created any events yet."));
          }

          final events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(event['thumbnailUrl'] ?? ''),
                ),
                title: Text(event['title']),
                subtitle: Text("Tickets: (placeholder)"), // Replace with actual count if you track tickets
              );
            },
          );
        },
      ),
    );
  }
}