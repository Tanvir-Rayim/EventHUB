import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final List<String> categories = [
      'Music',
      'Party',
      'Food',
      'Sports',
      'Business',
    ];

    final List<EventModel> events = [
      EventModel(
        title: 'Summer Beats Festival',
        category: 'Music',
        date: '12 April 2026 • 7:00 PM',
        location: 'Dhaka Arena',
        price: 'BDT 1200',
        organiser: 'EventHUB Live',
        description:
            'Enjoy a vibrant night of live music, lights, and performances with top artists and an energetic crowd. This festival brings together music lovers for an unforgettable evening.',
      ),
      EventModel(
        title: 'Neon Night Party',
        category: 'Party',
        date: '18 April 2026 • 9:00 PM',
        location: 'Gulshan Club',
        price: 'BDT 1800',
        organiser: 'Urban Nights',
        description:
            'Step into a colourful nightlife experience with music, dance, themed lighting, and a high-energy party atmosphere designed for an exciting night out.',
      ),
      EventModel(
        title: 'Street Food Carnival',
        category: 'Food',
        date: '22 April 2026 • 5:00 PM',
        location: 'Hatirjheel',
        price: 'BDT 500',
        organiser: 'Foodies BD',
        description:
            'Explore a wide variety of local and international street food stalls, fun hangout zones, and a lively festival environment perfect for food lovers.',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello',
                    style: TextStyle(
                      color: Color(0xFFB8B8C7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.displayName?.isNotEmpty == true
                        ? user!.displayName!
                        : 'EventHUB User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF171A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5C7A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Categories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xFFFF5C7A)
                        : const Color(0xFF171A2A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Featured Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          EventCard(event: events[0]),
          const SizedBox(height: 10),
          const Text(
            'Upcoming Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          EventCard(event: events[1]),
          EventCard(event: events[2]),
        ],
      ),
    );
  }
}