import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'HomePage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? profile;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    supabase.auth.onAuthStateChange.listen((event) {
      if (event != null) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          _fetchProfile();
        } else {
          setState(() {
            profile = null;
          });
        }
      }
    });
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .execute();

      if (response.status == 200 && response.data != null) {
        if (response.data.isNotEmpty) {
          setState(() {
            profile = response.data.first as Map<String, dynamic>?;
          });
        } else {
          setState(() {
            profile = {
              'id': user.id,
              'full_name': '',
              'username': '',
              'avatar_url': ''
            };
          });
          await supabase.from('profiles').insert({
            'id': user.id,
            'full_name': '',
            'username': '',
            'avatar_url': ''
          }).execute();
        }
      } else if (response.status != null && response.status != 200) {
        print('Error fetching profile: ${response.status}');
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      String? imageUrl = await _uploadImage(imageFile);
      if (imageUrl != null) {
        setState(() {
          profile!['avatar_url'] = imageUrl;
        });
      }
    }
  }

  Future<String?> _uploadImage(File image) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final fileName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final response = await supabase.storage.from('avatars').upload(fileName, image);

      if (response != null) {
        final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
        return publicUrl;
      } else {
        print('Error uploading image: Response is null');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (newPassword == confirmPassword) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          final response = await supabase.auth.updateUser(UserAttributes(password: newPassword));
          if (response.user == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully!')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.user}')));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('profiles')
            .update({
          'full_name': profile!['full_name'],
          'username': profile!['username'],
          'avatar_url': profile!['avatar_url']
        })
            .eq('id', user.id)
            .execute();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF21899C),
      ),
      body: profile == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profile!['avatar_url'] != null &&
                          profile!['avatar_url'].isNotEmpty
                          ? NetworkImage(profile!['avatar_url'])
                          : null,
                      child: profile!['avatar_url'] == null ||
                          profile!['avatar_url'].isEmpty
                          ? Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _pickImage,
                    child: Text(
                      'Edit Photo',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: Color(0xFFFF7248),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Email',
                  initialValue: supabase.auth.currentUser?.email,
                  readOnly: true,
                ),
                _buildTextField(
                  label: 'Full Name',
                  initialValue: profile!['full_name'],
                  onSaved: (value) {
                    setState(() {
                      profile!['full_name'] = value;
                    });
                  },
                ),
                _buildTextField(
                  label: 'Username',
                  initialValue: profile!['username'],
                  onSaved: (value) {
                    setState(() {
                      profile!['username'] = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF21899C),
                    ),
                    onPressed: _saveProfile,
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF21899C),
                          ),
                          onPressed: _changePassword,
                          child: Text(
                            'Change Password',
                            style: GoogleFonts.inter(
                              fontSize: 14.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF21899C),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              break; // Sudah di halaman ProfilePage
            case 2:
              supabase.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextEditingController? controller,
    bool readOnly = false,
    bool obscureText = false,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        readOnly: readOnly,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
