// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:go_router/go_router.dart';

// class ProfileUpdatePage extends StatefulWidget {
//   const ProfileUpdatePage({super.key});

//   @override
//   State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
// }

// class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
//   final _formKey = GlobalKey<FormState>();

//   final _displayNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _avatarUrlController = TextEditingController();

//   String _walletAddress = '';
//   List<String> _interests = [];
//   bool _isCreator = false;
//   String? _userId;
//   bool _isUploading = false;
//   bool _isSaving = false; // Added loading state for save

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   @override
//   void dispose() {
//     _displayNameController.dispose();
//     _emailController.dispose();
//     _avatarUrlController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _userId = user.uid;
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(_userId).get();
//       if (doc.exists) {
//         final data = doc.data()!;
//         if (mounted) {
//           setState(() {
//             _displayNameController.text = data['displayName'] ?? '';
//             _emailController.text = data['email'] ?? '';
//             _avatarUrlController.text = data['avatarUrl'] ?? '';
//             _interests = List<String>.from(data['interests'] ?? []);
//             _walletAddress = data['walletAddress'] ?? '';
//             _isCreator = data['isCreator'] ?? false;
//           });
//         }
//       }
//     }
//   }

//   Future<void> _pickAndUploadImage() async {
//     if (_isUploading || _userId == null) return;

//     setState(() => _isUploading = true);

//     try {
//       final picker = ImagePicker();
//       final pickedImage = await picker.pickImage(source: ImageSource.gallery);

//       if (pickedImage != null) {
//         final file = File(pickedImage.path);
//         final fileName =
//             'avatars/${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         final ref = FirebaseStorage.instance.ref().child(fileName);

//         await ref.putFile(file);
//         final downloadUrl = await ref.getDownloadURL();

//         if (mounted) {
//           setState(() => _avatarUrlController.text = downloadUrl);
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image upload failed: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isUploading = false);
//       }
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate() || _userId == null || _isSaving) return;

//     setState(() => _isSaving = true);

//     try {
//       await FirebaseFirestore.instance.collection('users').doc(_userId).update({
//         'displayName': _displayNameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'avatarUrl': _avatarUrlController.text.trim(),
//         'interests': _interests,
//         'isCreator': _isCreator,
//       });

//       if (!mounted) return;
      
//       // Show success message and navigate back
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Profile updated successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
      
//       // Navigate back to previous screen after successful update
//       context.pop();
      
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update profile: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isSaving = false);
//       }
//     }
//   }

//   void _showInterestDialog() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add Interest'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter an interest'),
//           textCapitalization: TextCapitalization.words,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               final newInterest = controller.text.trim();
//               if (newInterest.isNotEmpty && !_interests.contains(newInterest)) {
//                 setState(() => _interests.add(newInterest));
//               }
//               Navigator.pop(context);
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final avatar = _avatarUrlController.text.isNotEmpty
//         ? NetworkImage(_avatarUrlController.text)
//         : null;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Update Profile',
//           style: TextStyle(
//             fontFamily: 'Onest',
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: const Color(0xFFF5F5F5),
//         elevation: 0.5,
//         centerTitle: true,

//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             if (context.canPop()) {
//               context.pop();
//             } else {
//               // Fallback navigation - go to home
//               context.go('/home');
//             }
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: _isSaving 
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Icons.save),
//             onPressed: _isSaving ? null : _updateProfile,
//             tooltip: 'Save Changes',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Avatar with edit button
//               Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: Colors.grey[300],
//                       backgroundImage: avatar,
//                       child: avatar == null
//                           ? const Icon(Icons.person,
//                               size: 50, color: Colors.grey)
//                           : null,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           color: Colors.blue,
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           icon: _isUploading
//                               ? const SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Icon(Icons.edit, color: Colors.white, size: 20),
//                           onPressed: _isUploading ? null : _pickAndUploadImage,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Display Name
//               TextFormField(
//                 controller: _displayNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Display Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Enter name' : null,
//               ),
//               const SizedBox(height: 16),

//               // Email
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Enter email';
//                   if (!value.contains('@')) return 'Invalid email';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Interests
//               const Text('Interests',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 children: [
//                   ..._interests.map(
//                     (interest) => Chip(
//                       label: Text(interest),
//                       onDeleted: () =>
//                           setState(() => _interests.remove(interest)),
//                     ),
//                   ),
//                   ActionChip(
//                     avatar: const Icon(Icons.add, color: Colors.blue),
//                     label: const Text('Add Interest',
//                         style: TextStyle(color: Colors.blue)),
//                     onPressed: _showInterestDialog,
//                   )
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Wallet Address
//               const Text('Wallet Address',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.account_balance_wallet, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Text(
//                       _walletAddress.isNotEmpty
//                           ? '${_walletAddress.substring(0, 6)}...${_walletAddress.substring(_walletAddress.length - 4)}'
//                           : 'Not connected',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Creator switch
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.amber),
//                     const SizedBox(width: 8),
//                     const Text('Creator Account',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const Spacer(),
//                     Switch(
//                       value: _isCreator,
//                       onChanged: (value) => setState(() => _isCreator = value),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Submit
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isSaving ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: _isSaving
//                       ? const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                             SizedBox(width: 8),
//                             Text('Saving...'),
//                           ],
//                         )
//                       : const Text('Save Changes'),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  String _walletAddress = '';
  List<String> _interests = [];
  bool _isCreator = false;
  String? _userId;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _displayNameController.text = data['displayName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _avatarUrlController.text = data['avatarUrl'] ?? '';
          _interests = List<String>.from(data['interests'] ?? []);
          _walletAddress = data['walletAddress'] ?? '';
          _isCreator = data['isCreator'] ?? false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploading || _userId == null) return;

    setState(() => _isUploading = true);

    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileName = 'avatars/${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);

        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();

        setState(() => _avatarUrlController.text = downloadUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'displayName': _displayNameController.text.trim(),
        'email': _emailController.text.trim(),
        'avatarUrl': _avatarUrlController.text.trim(),
        'interests': _interests,
        'isCreator': _isCreator,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  void _showInterestDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter an interest'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newInterest = controller.text.trim();
              if (newInterest.isNotEmpty) {
                setState(() => _interests.add(newInterest));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatarUrlController.text.isNotEmpty
        ? NetworkImage(_avatarUrlController.text)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _updateProfile)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with edit button
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: avatar,
                      child: avatar == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: _pickAndUploadImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Display Name
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interests
              const Text('Interests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._interests.map(
                    (interest) => Chip(
                      label: Text(interest),
                      onDeleted: () => setState(() => _interests.remove(interest)),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.add, color: Colors.blue),
                    label: const Text('Add Interest', style: TextStyle(color: Colors.blue)),
                    onPressed: _showInterestDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Wallet Address
              const Text(
                'Wallet Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _walletAddress.isNotEmpty
                    ? '${_walletAddress.substring(0, 6)}...${_walletAddress.substring(_walletAddress.length - 4)}'
                    : 'Not connected',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Creator switch
              Row(
                children: [
                  const Text(
                    'Creator Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isCreator,
                    onChanged: (value) => setState(() => _isCreator = value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _updateProfile, child: const Text('Save Changes')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}