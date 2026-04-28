import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

// Import the notification service
import '../../services/notification_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedCategory;
  File? _eventImage;

  bool _isLoading = false;

  final _categories = ['Music', 'Party', 'Food', 'Sports', 'Business'];

  // Pick event image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _eventImage = File(pickedFile.path); 
      });
    }
  }

  // Handle event creation
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload the event image to Firebase Storage
      String imageUrl = '';
      if (_eventImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('event_images')
            .child(DateTime.now().toString());
        await ref.putFile(_eventImage!);  
        imageUrl = await ref.getDownloadURL();
      }

      final user = FirebaseAuth.instance.currentUser;

      // Save event data to Firestore
      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'price': _priceController.text.trim(),
        'date': _dateController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150',
        'organizer': user?.uid ?? 'Unknown', 
        'createdAt': Timestamp.now(),
      });

      // --- SEND NOTIFICATION TO ALL USERS ---
      // 1. Get the Organizer's name safely
      String organizerName = user?.displayName ?? 'An Organizer';
      try {
        if (user != null) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (userDoc.exists && userDoc.data()!.containsKey('fullName')) {
            organizerName = userDoc.data()!['fullName'];
          }
        }
      } catch (e) {
        debugPrint('Failed to fetch organizer name for notification: $e');
      }

      // 2. Trigger the notification batch
      await NotificationService.notifyAllUsersAboutNewEvent(
        eventTitle: _titleController.text.trim(),
        organizerName: organizerName,
      );
      // --------------------------------------

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully')),
      );

      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Event Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter event title',
                      hintStyle: TextStyle(color: Color(0xFFB8B8C7)),
                      prefixIcon: Icon(Icons.event, color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an event title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Event Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Event Description',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter event description',
                      hintStyle: TextStyle(color: Color(0xFFB8B8C7)),
                      prefixIcon: Icon(Icons.description, color: Colors.white),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an event description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Event Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter event location',
                      hintStyle: TextStyle(color: Color(0xFFB8B8C7)),
                      prefixIcon: Icon(Icons.location_on, color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an event location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Event Price
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter event price',
                      hintStyle: TextStyle(color: Color(0xFFB8B8C7)),
                      prefixIcon: Icon(Icons.attach_money, color: Colors.white),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter event price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Event Date & Time
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Event Date & Time',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: 'Enter event date & time',
                      hintStyle: TextStyle(color: Color(0xFFB8B8C7)),
                      prefixIcon: Icon(Icons.date_range, color: Colors.white),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter event date & time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Event Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Event Category',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Color(0xFFB8B8C7)),
                      prefixIcon: Icon(Icons.category, color: Colors.white),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an event category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Pick Event Image
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(
                      _eventImage == null
                          ? 'Pick an Event Banner'
                          : 'Change Event Banner',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display the selected event image
                  _eventImage == null
                      ? const SizedBox()
                      : Image.file(
                          File(_eventImage!.path),
                          height: 150,
                        ),
                  const SizedBox(height: 24),
                  // Create Event Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Event'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}