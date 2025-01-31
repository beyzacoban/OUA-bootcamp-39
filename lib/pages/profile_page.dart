import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key); // Constructor

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for text input fields
  final _nameController = TextEditingController();
  final _interestsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isEditing = false; // Tracks whether the profile is in edit mode
  File? _profileImage; // Stores the selected profile image

  @override
  void initState() {
    super.initState();
    _loadProfileInfo(); // Load profile information when the widget is initialized
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load stored values or use empty strings if not found
      _nameController.text = prefs.getString('name') ?? '';
      _interestsController.text = prefs.getString('interests') ?? '';
      _languagesController.text = prefs.getString('languages') ?? '';
      _locationController.text = prefs.getString('location') ?? '';
      // Load the profile image if a path is stored
      String? imagePath = prefs.getString('profileImage');
      if (imagePath != null) {
        _profileImage = File(imagePath);
      }
    });
  }

  // Save profile data to SharedPreferences
  Future<void> _saveProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    // Save values from input controllers to SharedPreferences
    await prefs.setString('name', _nameController.text);
    await prefs.setString('interests', _interestsController.text);
    await prefs.setString('languages', _languagesController.text);
    await prefs.setString('location', _locationController.text);
    if (_profileImage != null) {
      // Save the image path if an image has been selected
      await prefs.setString('profileImage', _profileImage!.path);
    }
  }

  // Function to allow picking an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage =
            File(image.path); // Update the _profileImage with the selected file
      });
    }
  }

  // Dispose of controllers to avoid memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _interestsController.dispose();
    _languagesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        // Allow scrolling if the content is too long
        padding: const EdgeInsets.all(16.0),
        // Conditionally build either the edit form or the profile info based on the edit mode
        child: _isEditing ? _buildEditForm() : _buildProfileInfo(),
      ),
    );
  }

// Build the edit form for the profile
  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment
          .start, // Align items to the start (left) of the column
      children: [
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 60),
                        SizedBox(height: 8),
                        Text("Choose a photo from gallery")
                      ],
                    )
                  : null, // Don't show anything if an image is selected
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(_nameController, 'Name'),
        const SizedBox(height: 16),
        _buildTextField(_interestsController, 'Interests'),
        const SizedBox(height: 16),
        _buildTextField(_languagesController, 'Programming Languages'),
        const SizedBox(height: 16),
        _buildTextField(_locationController, 'Location'),
        const SizedBox(height: 32),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              _saveProfileInfo();
              setState(() {
                _isEditing = false;
              });
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profile Saved'),
                  content:
                      const Text('Your profile has been updated successfully.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.save,
              color: Color(0xFF37474F),
            ),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              textStyle: const TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      ],
    );
  }

// Build a single text field for the edit form
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
    );
  }

// Build the profile information display (view mode)
  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildProfileInfoRow('Name', _nameController.text),
        const SizedBox(height: 8),
        _buildProfileInfoRow('Interests', _interestsController.text),
        const SizedBox(height: 8),
        _buildProfileInfoRow(
            'Programming Languages', _languagesController.text),
        const SizedBox(height: 8),
        _buildProfileInfoRow('Location', _locationController.text),
      ],
    );
  }

// Build a single row of profile information
  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
