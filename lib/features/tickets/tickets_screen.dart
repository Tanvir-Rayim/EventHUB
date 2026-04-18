import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../widgets/ticket_card.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'Please log in to view tickets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load tickets: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final tickets = docs.map((doc) {
          return TicketModel.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList();

        final activeTickets =
            tickets.where((ticket) => ticket.status == 'Active').toList();

        final pastTickets =
            tickets.where((ticket) => ticket.status != 'Active').toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'My Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'View your active and past event tickets here.',
                style: TextStyle(
                  color: Color(0xFFB8B8C7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Active Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              if (activeTickets.isEmpty)
                const _EmptyTicketSection(message: 'No active tickets yet.')
              else
                ...activeTickets.map((ticket) => TicketCard(ticket: ticket)),
              const SizedBox(height: 10),
              const Text(
                'Past Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              if (pastTickets.isEmpty)
                const _EmptyTicketSection(message: 'No past tickets yet.')
              else
                ...pastTickets.map((ticket) => TicketCard(ticket: ticket)),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyTicketSection extends StatelessWidget {
  final String message;

  const _EmptyTicketSection({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171A2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB8B8C7),
          fontSize: 14,
        ),
      ),
    );
  }
}