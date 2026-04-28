import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// SCENARIO B: Notify a specific organizer when someone books their event
  static Future<void> notifyOrganizerAboutBooking({
    required String organizerId,
    required String eventTitle,
    required String userName,
  }) async {
    await _db.collection('notifications').add({
      'userId': organizerId,
      'title': 'New Booking! 🎉',
      'message': '$userName just booked a ticket for $eventTitle.',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'booking',
    });
  }

  /// SCENARIO A: Notify ALL regular users when an organizer creates a new event
  static Future<void> notifyAllUsersAboutNewEvent({
    required String eventTitle,
    required String organizerName,
  }) async {
    try {
      // Fetch all users who are NOT organizers
      final usersSnap = await _db
          .collection('users')
          .where('role', isNotEqualTo: 'organizer')
          .get();

      WriteBatch batch = _db.batch();
      int count = 0;

      for (var doc in usersSnap.docs) {
        final notifRef = _db.collection('notifications').doc();
        
        batch.set(notifRef, {
          'userId': doc.id, // The user receiving the notification
          'title': 'New Event Added! 🎫',
          'message': '$organizerName just added a new event: $eventTitle. Book your spot now!',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'new_event',
        });

        count++;
        
        // Firestore has a limit of 500 writes per batch. 
        // If we hit 490, we commit and start a new batch.
        if (count == 490) {
          await batch.commit();
          batch = _db.batch();
          count = 0;
        }
      }

      // Commit any remaining notifications in the final batch
      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      print("Error sending mass notifications: $e");
    }
  }

  /// Mark a notification as read
  static Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}