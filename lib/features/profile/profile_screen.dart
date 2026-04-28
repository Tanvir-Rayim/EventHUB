import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/profile_option_tile.dart';
import '../tickets/my_bookings_screen.dart';
import '../navigation/main_navigation_screen.dart';
import 'edit_profile_screen.dart';
import 'privacy_security_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'No user found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String displayName = user.displayName?.isNotEmpty == true
            ? user.displayName!
            : 'EventHUB User';
        String email = user.email ?? 'No email available';
        String phone = 'No phone number';
        bool isOrganizer = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = data['fullName'] ?? displayName;
          email = data['email'] ?? email;
          phone = data['phone'] ?? phone;
          isOrganizer = data['role'] == 'organizer';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF171A2A),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111425),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFFB8B8C7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Color(0xFFB8B8C7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ProfileOptionTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),

              isOrganizer
                  ? ProfileOptionTile(
                      icon: Icons.event_note_outlined,
                      title: 'My Events',
                      subtitle: 'Manage the events you have created',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              backgroundColor: const Color(0xFF0B0F1A),
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                iconTheme: const IconThemeData(color: Colors.white),
                              ),
                              body: PastEventsTab(userId: user.uid),
                            ),
                          ),
                        );
                      },
                    )
                  : ProfileOptionTile(
                      icon: Icons.confirmation_number_outlined,
                      title: 'My Bookings',
                      subtitle: 'View your ticket and booking history',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyBookingsScreen(),
                          ),
                        );
                      },
                    ),
              ProfileOptionTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              
              ProfileOptionTile(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                subtitle: 'Control account safety and privacy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacySecurityScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}