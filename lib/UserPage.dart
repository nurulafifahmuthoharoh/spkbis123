import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'HomePage.dart';
import 'ProfilePage.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await supabase
        .from('profiles')
        .select()
        .execute();

    if (response.status == 200 && response.data != null) {
      setState(() {
        users = response.data as List<dynamic>;
      });
    } else {
      print('Error fetching users: ${response.status}');
      print('Response data: ${response.data}');
    }
  }

  Future<void> _deleteUser(String userId) async {
    final response = await supabase
        .from('profiles')
        .delete()
        .eq('id', userId)
        .execute();

    if (response.status == 200) {
      setState(() {
        users.removeWhere((user) => user['id'] == userId);
      });
    } else {
      print('Error deleting user: ${response.status}');
    }
  }

  void _editUser(Map<String, dynamic> user) {
    TextEditingController fullNameController = TextEditingController(text: user['full_name']);
    TextEditingController usernameController = TextEditingController(text: user['username']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save', style: GoogleFonts.inter(color: Color(0xFF21899C))),
              onPressed: () async {
                await supabase
                    .from('profiles')
                    .update({
                  'full_name': fullNameController.text,
                  'username': usernameController.text
                })
                    .eq('id', user['id'])
                    .execute();
                Navigator.pop(context);
                _fetchUsers();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: GoogleFonts.inter(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF21899C),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['full_name']?.isNotEmpty == true ? user['full_name'] : 'No Name',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            subtitle: Text(user['username']?.isNotEmpty == true ? user['username'] : 'No Username'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFFFF7248)),
                  onPressed: () => _editUser(user),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(user['id']),
                ),
              ],
            ),
          );
        },
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
            case 2:
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
              break;
          }
        },
      ),
    );
  }
}
