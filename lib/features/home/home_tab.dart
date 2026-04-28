import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';
import '../home/create_event_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  late Stream<DocumentSnapshot> _userStream;
  Stream<QuerySnapshot>? _eventsStream;
  bool? _wasOrganizer;

  final List<String> _categories = [
    'All',
    'Music',
    'Tech',
    'Sports',
    'Arts',
    'Food',
    'Business'
  ];

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(
        child: Text('Please log in', style: TextStyle(color: Colors.white)),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting && !userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final bool isOrganizer = userData['role'] == 'organizer';
        final String fullName = userData['fullName'] ?? 'User';

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: isOrganizer
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateEventScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFFFF5C7A),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // We now pass both the name and the role to the header
              _buildHeader(fullName, isOrganizer),
              _buildSearchBar(),
              _buildCategories(),
              Expanded(
                child: _buildEventList(isOrganizer, currentUser!.uid),
              ),
            ],
          ),
        );
      },
    );
  }

  // Updated to accept the role and format the text dynamically
  Widget _buildHeader(String name, bool isOrganizer) {
    final String greeting = isOrganizer ? '$name,' : 'Hello, $name 👋';
    final String subtitle = isOrganizer ? "Let's organise new events." : 'Find Amazing Events';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: Color(0xFF8E93A8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase(); 
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for events...',
          hintStyle: const TextStyle(color: Color(0xFF8E93A8)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8E93A8)),
          suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF8E93A8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF171A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16), 
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF5C7A) : const Color(0xFF171A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8E93A8),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList(bool isOrganizer, String userId) {
    if (_eventsStream == null || _wasOrganizer != isOrganizer) {
      _wasOrganizer = isOrganizer;
      Query query = FirebaseFirestore.instance.collection('events');
      
      if (isOrganizer) {
        query = query.where('organizer', isEqualTo: userId);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }
      
      _eventsStream = query.snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _eventsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              isOrganizer ? 'You have no active events.' : 'No events available right now.',
              style: const TextStyle(color: Color(0xFF8E93A8)),
            ),
          );
        }

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? 'General').toString();

          final matchesSearch = _searchQuery.isEmpty || title.contains(_searchQuery);
          final matchesCategory = _selectedCategory == 'All' || category == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(
            child: Text(
              'No events match your search.',
              style: TextStyle(color: Color(0xFF8E93A8)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 80),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            final event = EventModel(
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

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EventCard(
                event: event,
                onEdit: isOrganizer 
                    ? () {
                        // TODO: Navigate to Edit Event Screen
                      } 
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}