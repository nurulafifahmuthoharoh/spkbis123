import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'HomePage.dart';
import 'ProfilePage.dart';
import 'models/alternatif.dart';

class DataAlternatifPage extends StatefulWidget {
  @override
  _DataAlternatifPageState createState() => _DataAlternatifPageState();
}

class _DataAlternatifPageState extends State<DataAlternatifPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Alternatif> alternatifList = [];

  @override
  void initState() {
    super.initState();
    _fetchAlternatif();
  }

  Future<void> _fetchAlternatif() async {
    final response = await supabase
        .from('alternatif')
        .select()
        .execute();

    final data = response.data as List<dynamic>;

    setState(() {
      alternatifList = data.map((item) => Alternatif.fromMap(item)).toList();
    });
  }

  Future<void> _addAlternatif(Alternatif alternatif) async {
    try {
      final response = await supabase
          .from('alternatif')
          .insert(alternatif.toMap())
          .execute();
      _fetchAlternatif();
    } on PostgrestException catch (e) {
      print('Error: ${e.message}');
    }
  }

  Future<void> _updateAlternatif(Alternatif alternatif) async {
    try {
      final response = await supabase
          .from('alternatif')
          .update(alternatif.toMap())
          .eq('id_alternatif', alternatif.idAlternatif)
          .execute();

      setState(() {
        final index = alternatifList.indexWhere((item) => item.idAlternatif == alternatif.idAlternatif);
        if (index != -1) {
          alternatifList[index] = alternatif;
        }
      });
    } on PostgrestException catch (e) {
      print('Error: ${e.message}');
    }
  }

  Future<void> _deleteAlternatif(String idAlternatif) async {
    try {
      final response = await supabase
          .from('alternatif')
          .delete()
          .eq('id_alternatif', idAlternatif)
          .execute();
      _fetchAlternatif();
    } on PostgrestException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void _showAlternatifDialog({Alternatif? alternatif}) {
    final idAlternatifController = TextEditingController(text: alternatif?.idAlternatif ?? '');
    final namaAlternatifController = TextEditingController(text: alternatif?.namaAlternatif ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF0F4F8),
          title: Text(
            alternatif == null ? 'Tambah Alternatif' : 'Edit Alternatif',
            style: GoogleFonts.inter(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF21899C),
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: idAlternatifController,
                    label: 'ID Alternatif',
                    enabled: false,
                  ),
                  SizedBox(height: 8),
                  _buildTextField(
                    controller: namaAlternatifController,
                    label: 'Nama Alternatif',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: Color(0xFF969AA8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newAlternatif = Alternatif(
                  idAlternatif: alternatif?.idAlternatif ?? 'A${alternatifList.length + 1}',
                  namaAlternatif: namaAlternatifController.text,
                );

                if (alternatif == null) {
                  _addAlternatif(newAlternatif);
                } else {
                  _updateAlternatif(newAlternatif);
                }
                Navigator.pop(context);
              },
              child: Text(
                alternatif == null ? 'Tambah' : 'Simpan',
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: Color(0xFFFF7248),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: Colors.black,
            height: 1.0,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(
            fontSize: 18.0,
            color: Color(0xFF151624),
          ),
          maxLines: 1,
          keyboardType: keyboardType,
          cursorColor: Color(0xFF151624),
          enabled: enabled,
          decoration: InputDecoration(
            hintText: 'Masukan $label',
            hintStyle: GoogleFonts.inter(
              fontSize: 14.0,
              color: Color(0xFFABB3BB),
              height: 1.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Alternatif',
          style: GoogleFonts.inter(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF21899C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            headingRowColor:
            MaterialStateProperty.resolveWith((states) => Color(0xFF21899C)),
            columns: const [
              DataColumn(
                label: Text(
                  'No',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'ID Alternatif',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Nama Alternatif',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Aksi',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
            rows: alternatifList.map((alternatif) {
              int index = alternatifList.indexOf(alternatif) + 1;
              return DataRow(
                cells: [
                  DataCell(Text(index.toString(), style: TextStyle(fontSize: 12))),
                  DataCell(Text(alternatif.idAlternatif, style: TextStyle(fontSize: 12))),
                  DataCell(Text(alternatif.namaAlternatif, style: TextStyle(fontSize: 12))),
                  DataCell(
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAlternatifDialog(alternatif: alternatif);
                        } else if (value == 'delete') {
                          _deleteAlternatif(alternatif.idAlternatif);
                        }
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAlternatifDialog(); // Membuka dialog untuk menambah alternatif baru
        },
        child: Icon(
          Icons.add,
          color: Colors.white, // Mengubah warna ikon "+" menjadi putih
        ),
        backgroundColor: Color(0xFF21899C),

      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF21899C),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xFF21899C),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Color(0xFF21899C),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else if (index == 2) {

          }
        },
      ),
    );
  }
}
