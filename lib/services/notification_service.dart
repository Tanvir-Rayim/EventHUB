import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static Future<void> notifyOrganizerAboutBooking({
    required String organizerId,
    required String eventTitle,
    required String userName,
  }) async {
    await _db.collection('notifications').add({
      'receiverId': organizerId,
      'title': 'New Booking! 🎉',
      'body': '$userName just booked a ticket for $eventTitle.',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'booking',
    });
  }

  static Future<void> notifyAllUsersAboutNewEvent({
    required String eventTitle,
    required String organizerName,
  }) async {
    try {
      final usersSnap = await _db
          .collection('users')
          .where('role', isNotEqualTo: 'organizer')
          .get();

      WriteBatch batch = _db.batch();
      int count = 0;

      for (var doc in usersSnap.docs) {
        if (doc.id == FirebaseAuth.instance.currentUser?.uid) continue;
        final notifRef = _db.collection('notifications').doc();
        
        batch.set(notifRef, {
          'receiverId': doc.id, 
          'title': 'New Event Added! 🎫',
          'body': '$organizerName just added a new event: $eventTitle. Book your spot now!',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'new_event',
        });

        count++;
        
        if (count == 490) {
          await batch.commit();
          batch = _db.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      print("Error sending mass notifications: $e");
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}