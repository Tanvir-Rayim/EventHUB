import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;  
  final String title;
  final String category;
  final String date;
  final String location;
  final String price;
  final String organiser;
  final String description;
  final String imageUrl;

  EventModel({
    required this.id,  
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.price,
    required this.organiser,
    required this.description,
    required this.imageUrl,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,  
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      date: data['date'] ?? '',
      location: data['location'] ?? '',
      price: data['price'] ?? '',
      organiser: data['organiser'] ?? '', // Note: Fixed 'organizer' to match your variable name
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // ADDED THIS: To easily save data TO Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date,
      'location': location,
      'price': price,
      'organiser': organiser,
      'description': description,
      'imageUrl': imageUrl,
      // We don't save the 'id' here because Firestore uses it as the Document ID itself
    };
  }
}