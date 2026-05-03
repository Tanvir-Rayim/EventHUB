import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// IMPORTANT: Make sure this path matches your project structure
import '../../models/event_model.dart';
import '../../services/notification_service.dart';

class CreateEventScreen
    extends StatefulWidget {
  final EventModel?
  event; // ADDED: Optional event parameter for editing

  // ADDED: this.event to constructor
  const CreateEventScreen({
    super.key,
    this.event,
  });

  @override
  _CreateEventScreenState
  createState() =>
      _CreateEventScreenState();
}

class _CreateEventScreenState
    extends State<CreateEventScreen> {
  final _formKey =
      GlobalKey<FormState>();
  final _titleController =
      TextEditingController();
  final _descriptionController =
      TextEditingController();
  final _locationController =
      TextEditingController();
  final _priceController =
      TextEditingController();
  final _dateController =
      TextEditingController();

  String? _selectedCategory;
  File? _eventImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'Music',
    'Tech',
    'Sports',
    'Arts',
    'Food',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    // ADDED: If an event is passed in, pre-fill the fields for editing!
    if (widget.event != null) {
      _titleController.text =
          widget.event!.title;
      _descriptionController.text =
          widget.event!.description;
      _locationController.text =
          widget.event!.location;
      _priceController.text =
          widget.event!.price;
      _dateController.text =
          widget.event!.date;

      // Ensure the category exists in the list to avoid dropdown errors
      if (_categories.contains(
        widget.event!.category,
      )) {
        _selectedCategory =
            widget.event!.category;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker
        .pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );

    if (pickedFile != null) {
      setState(() {
        _eventImage = File(
          pickedFile.path,
        );
      });
    }
  }

  Future<void> _saveEvent() async {
    // Renamed to _saveEvent to handle both Create and Edit
    if (!_formKey.currentState!
        .validate())
      return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth
          .instance
          .currentUser;
      if (user == null)
        throw Exception(
          "User not logged in",
        );

      // Keep existing image URL if editing and no new image is selected
      String imageUrl =
          widget.event?.imageUrl ??
          'https://via.placeholder.com/150';

      if (_eventImage != null) {
        final ref = FirebaseStorage
            .instance
            .ref()
            .child('event_images')
            .child(
              '${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
        await ref.putFile(_eventImage!);
        imageUrl = await ref
            .getDownloadURL();
      }

      // Prepare the data
      Map<String, dynamic> eventData = {
        'title': _titleController.text
            .trim(),
        'description':
            _descriptionController.text
                .trim(),
        'location': _locationController
            .text
            .trim(),
        'price': _priceController.text
            .trim(),
        'date': _dateController.text
            .trim(),
        'category': _selectedCategory,
        'imageUrl': imageUrl,
        'organizer': user.uid,
      };

      if (widget.event != null) {
        // EDIT MODE: Update existing document
        await FirebaseFirestore.instance
            .collection('events')
            .doc(
              widget.event!.id,
            ) // Assumes your EventModel has an 'id' field
            .update(eventData);

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Event updated successfully!',
            ),
          ),
        );
      } else {
        // CREATE MODE: Add new document
        eventData['createdAt'] =
            FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('events')
            .add(eventData);

        // Only notify users on creation, not on edit
        String organizerName =
            'An Organizer';
        try {
          final userDoc =
              await FirebaseFirestore
                  .instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
          if (userDoc.exists) {
            organizerName =
                userDoc
                    .data()?['fullName'] ??
                user.displayName ??
                'An Organizer';
          }
        } catch (e) {
          debugPrint(
            'Failed to fetch organizer name: $e',
          );
        }

        await NotificationService.notifyAllUsersAboutNewEvent(
          eventTitle: _titleController
              .text
              .trim(),
          organizerName: organizerName,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Event created successfully!',
            ),
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save event: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF8E93A8),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF5C7A),
      ),
      filled: true,
      fillColor: const Color(
        0xFF171A2A,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFFF5C7A),
          width: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are in Edit mode or Create mode
    final isEditing =
        widget.event != null;

    return Scaffold(
      backgroundColor: const Color(
        0xFF0B0F1A,
      ),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing
              ? 'Edit Event'
              : 'Create New Event',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF171A2A,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                    // Show new file image if picked, otherwise show existing network image if editing
                    image:
                        _eventImage !=
                            null
                        ? DecorationImage(
                            image: FileImage(
                              _eventImage!,
                            ),
                            fit: BoxFit
                                .cover,
                          )
                        : (isEditing &&
                              widget
                                  .event!
                                  .imageUrl
                                  .isNotEmpty &&
                              widget.event!.imageUrl !=
                                  'https://via.placeholder.com/150')
                        ? DecorationImage(
                            image: NetworkImage(
                              widget
                                  .event!
                                  .imageUrl,
                            ),
                            fit: BoxFit
                                .cover,
                          )
                        : null,
                  ),
                  child:
                      (_eventImage ==
                              null &&
                          (!isEditing ||
                              widget.event!.imageUrl ==
                                  'https://via.placeholder.com/150'))
                      ? const Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .add_a_photo_outlined,
                              color: Colors
                                  .white,
                              size: 40,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Add Event Banner',
                              style: TextStyle(
                                color: Colors
                                    .white54,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller:
                    _titleController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    _buildInputDecoration(
                      'Event Title',
                      Icons.title,
                    ),
                validator: (val) =>
                    val!.isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(
                height: 16,
              ),

              DropdownButtonFormField<
                String
              >(
                value:
                    _selectedCategory,
                dropdownColor:
                    const Color(
                      0xFF171A2A,
                    ),
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    _buildInputDecoration(
                      'Category',
                      Icons.category,
                    ),
                items: _categories
                    .map(
                      (
                        cat,
                      ) => DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: const TextStyle(
                            color: Colors
                                .white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(
                      () =>
                          _selectedCategory =
                              val,
                    ),
                validator: (val) =>
                    val == null
                    ? 'Select a category'
                    : null,
              ),
              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _locationController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                    _buildInputDecoration(
                      'Location',
                      Icons.location_on,
                    ),
                validator: (val) =>
                    val!.isEmpty
                    ? 'Location is required'
                    : null,
              ),
              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:
                          _dateController,
                      style:
                          const TextStyle(
                            color: Colors
                                .white,
                          ),
                      decoration:
                          _buildInputDecoration(
                            'Date/Time',
                            Icons
                                .calendar_today,
                          ),
                      validator: (val) =>
                          val!.isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller:
                          _priceController,
                      style:
                          const TextStyle(
                            color: Colors
                                .white,
                          ),
                      decoration:
                          _buildInputDecoration(
                            'Price',
                            Icons
                                .attach_money,
                          ),
                      keyboardType:
                          TextInputType
                              .number,
                      validator: (val) =>
                          val!.isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _descriptionController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                maxLines: 4,
                decoration:
                    _buildInputDecoration(
                      'Description',
                      Icons.notes,
                    ),
                validator: (val) =>
                    val!.isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(
                height: 30,
              ),

              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _saveEvent, // Now uses _saveEvent
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                        0xFFFF5C7A,
                      ),
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors
                              .white,
                          strokeWidth:
                              2,
                        ),
                      )
                    : Text(
                        isEditing
                            ? 'Update Event'
                            : 'Publish Event',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
