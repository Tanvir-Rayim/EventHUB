import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final EventModel event;

  const BookingScreen({
    super.key,
    required this.event,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int quantity = 1;

  int _extractPrice(String priceText) {
    final numeric = priceText.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numeric) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final int unitPrice = _extractPrice(widget.event.price);
    final int totalPrice = unitPrice * quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Event'),
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171A2A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.event.date,
                        style: const TextStyle(
                          color: Color(0xFFB8B8C7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.event.location,
                        style: const TextStyle(
                          color: Color(0xFFB8B8C7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Organiser: ${widget.event.organiser}',
                        style: const TextStyle(
                          color: Color(0xFFB8B8C7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Quantity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171A2A),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tickets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.white,
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Booking Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171A2A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Price per ticket',
                        value: widget.event.price,
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Quantity',
                        value: quantity.toString(),
                      ),
                      const Divider(
                        color: Color(0xFF2A2E43),
                        height: 28,
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: 'BDT $totalPrice',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                    onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) return;

                        try {
                        await FirebaseFirestore.instance.collection('bookings').add({
                            'userId': user.uid,
                            'eventTitle': widget.event.title,
                            'date': widget.event.date,
                            'location': widget.event.location,
                            'ticketType': 'General Entry',
                            'status': 'Active',
                            'quantity': quantity,
                            'totalPrice': totalPrice,
                            'createdAt': Timestamp.now(),
                        });

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                            content: Text('Booking confirmed and saved'),
                            ),
                        );

                        Navigator.pop(context);
                        } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                            content: Text('Failed to save booking'),
                            ),
                        );
                        }
                    },
                    child: const Text('Confirm Booking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : const Color(0xFFB8B8C7),
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}