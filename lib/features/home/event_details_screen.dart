import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'booking_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  Future<void> _handleBooking(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book this event')),
      );
      return;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(event: event),
        ),
      );

      await FirebaseFirestore.instance.collection('notifications').add({
        'receiverId': event.organiser, 
        'title': 'New Event Booking',
        'body': 'Someone has just booked your event: ${event.title}',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'senderName': currentUser.displayName ?? 'A user',
        'type': 'booking',
      });
      
    } catch (e) {
      debugPrint('Error during booking notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Event Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B0F1A),
              Color(0xFF12182A),
              Color(0xFF0B0F1A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: event.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(event.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: event.imageUrl.isEmpty
                        ? const LinearGradient(
                            colors: [Color(0xFFFF5C7A), Color(0xFF7C5CFF)],
                          )
                        : null,
                  ),
                  child: event.imageUrl.isEmpty
                      ? const Center(
                          child: Icon(Icons.event, size: 70, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5C7A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF5C7A), width: 1),
                  ),
                  child: Text(
                    event.category,
                    style: const TextStyle(
                      color: Color(0xFFFF5C7A),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date & Time',
                  value: event.date,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: event.location,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.attach_money,
                  title: 'Price',
                  value: event.price,
                ),
                
                const SizedBox(height: 28),
                const Text(
                  'About Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: const TextStyle(
                    color: Color(0xFFB8B8C7),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF12182A),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: ElevatedButton(
          onPressed: () => _handleBooking(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5C7A),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171A2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF111425),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFF5C7A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFF8E93A8), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}