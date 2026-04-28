import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _markNotificationsAsRead();
  }

  Future<void> _markNotificationsAsRead() async {
    if (currentUser == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (querySnapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _deleteNotification(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in', style: TextStyle(color: Colors.white)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('receiverId', isEqualTo: currentUser!.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error: ${snapshot.error}', 
                        style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5C7A)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[800]),
                        const SizedBox(height: 16),
                        const Text('No notifications yet', 
                          style: TextStyle(color: Color(0xFF8E93A8), fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final String title = data['title'] ?? 'Update';
                    final String body = data['body'] ?? '';
                    final bool isRead = data['isRead'] ?? false;
                    
                    final Timestamp? time = data['createdAt'] as Timestamp?;
                    final String formattedTime = time != null 
                        ? DateFormat('MMM d, h:mm a').format(time.toDate()) 
                        : '';

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) => _deleteNotification(doc.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171A2A),
                          borderRadius: BorderRadius.circular(16),
                          border: isRead == false 
                              ? Border.all(color: const Color(0xFFFF5C7A).withOpacity(0.5), width: 1)
                              : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: isRead == false 
                                  ? const Color(0xFFFF5C7A) 
                                  : const Color(0xFF2A2E43),
                              child: Icon(
                                data['type'] == 'booking' ? Icons.confirmation_number : Icons.event,
                                color: Colors.white, 
                                size: 20
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: isRead == false ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(color: Color(0xFF8E93A8), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    body,
                                    style: const TextStyle(color: Color(0xFFB8B8C7), fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}