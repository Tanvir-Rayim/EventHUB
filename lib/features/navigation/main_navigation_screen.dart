import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_tab.dart';
import '../profile/profile_screen.dart';
import '../tickets/tickets_screen.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F1A),
        body: Center(
          child: Text('Please log in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B0F1A),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final role = userData['role'] ?? 'regular';
        final isOrganizer = role == 'organizer';

        final List<Widget> screens = [
          const HomeTab(),
          isOrganizer
              ? PastEventsTab(userId: user.uid)
              : const TicketsScreen(),
          const ProfileScreen(),
        ];
        final safeIndex = _selectedIndex >= screens.length ? 0 : _selectedIndex;

        return Scaffold(
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
              child: screens[safeIndex],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: _onItemTapped,
            backgroundColor: const Color(0xFF171A2A),
            selectedItemColor: const Color(0xFFFF5C7A),
            unselectedItemColor: const Color(0xFF8E93A8),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              if (isOrganizer)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'Past Events',
                )
              else
                const BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  activeIcon: Icon(Icons.confirmation_number),
                  label: 'Tickets',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class PastEventsTab extends StatelessWidget {
  final String userId;
  const PastEventsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('organizer', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No past events found.',
              style: TextStyle(color: Color(0xFF8E93A8), fontSize: 16),
            ),
          );
        }

        final allEvents = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return EventModel(
            id: doc.id,
            title: data['title'] ?? 'Untitled Event',
            category: data['category'] ?? 'General',
            date: data['date'] ?? 'TBA',
            location: data['location'] ?? 'TBA',
            price: data['price'] ?? 'Free',
            organiser: data['organizer'] ?? 'Unknown',
            description: data['description'] ?? '',
            imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
          );
        }).toList();

        final pastEvents = allEvents; 

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Event History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (pastEvents.isEmpty)
                const Center(
                  child: Text(
                    'You have no previous events.',
                    style: TextStyle(color: Color(0xFF8E93A8)),
                  ),
                ),
              for (var event in pastEvents) ...[
                EventCard(
                  event: event,
                  onEdit: null, 
                ),
                const SizedBox(height: 14),
              ]
            ],
          ),
        );
      },
    );
  }
}