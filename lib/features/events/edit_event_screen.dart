import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // Make sure to import dart:io for File

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();

    final eventData = eventDoc.data();
    if (eventData != null) {
      _titleController.text = eventData['title'];
      _descriptionController.text = eventData['description'];
      _locationController.text = eventData['location'];
      _priceController.text = eventData['price'];
      _dateController.text = eventData['date'];
      _selectedCategory = eventData['category'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _eventImage = File(pickedFile.path); // Convert XFile to File
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload event image to Firebase Storage
      String imageUrl = '';
      if (_eventImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('event_images')
            .child(DateTime.now().toString());
        await ref.putFile(
          _eventImage!,   // Corrected for Firebase Storage
        );
        imageUrl = await ref.getDownloadURL();
      }

      // Save event data to Firestore
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'price': _priceController.text.trim(),
        'date': _dateController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : null,
        'organizer': user?.displayName ?? 'Unknown',
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteEvent() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171A2A),
        title: const Text(
          'Delete Event?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action will permanently delete the event.',
          style: TextStyle(color: Color(0xFFB8B8C7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('events').doc(widget.eventId).delete();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEvent,
          ),
        ],
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
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(
                      _eventImage == null
                          ? 'Pick an Event Banner'
                          : 'Change Event Banner',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _eventImage == null
                      ? const SizedBox()
                      : Image.file(
                          File(_eventImage!.path),
                          height: 150,
                        ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveEvent,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Event'),
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