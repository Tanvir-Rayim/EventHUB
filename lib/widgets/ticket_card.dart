import 'package:flutter/material.dart';
import '../models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const TicketCard({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = ticket.status == 'Active';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.eventTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFF5C7A)
                      : const Color(0xFF2A2E43),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ticket.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.date,
            style: const TextStyle(
              color: Color(0xFFB8B8C7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.location,
            style: const TextStyle(
              color: Color(0xFFB8B8C7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${ticket.ticketType} • ${ticket.quantity} ticket(s)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: BDT ${ticket.totalPrice}',
            style: const TextStyle(
              color: Color(0xFFFF5C7A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF111425),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2A2E43),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_2,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}