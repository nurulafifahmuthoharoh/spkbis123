import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'HomePage.dart';
import 'ProfilePage.dart';
import 'models/kriteria.dart';

class DataKriteriaPage extends StatefulWidget {
  @override
  _DataKriteriaPageState createState() => _DataKriteriaPageState();
}

class _DataKriteriaPageState extends State<DataKriteriaPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Kriteria> kriteriaList = [];

  @override
  void initState() {
    super.initState();
    _fetchKriteria();
  }

  Future<void> _fetchKriteria() async {
    final response = await supabase
        .from('kriteria')
        .select()
        .execute();

    final data = response.data as List<dynamic>;

    setState(() {
      kriteriaList = data.map((item) => Kriteria.fromMap(item)).toList();
    });
  }

  Future<void> _addKriteria(Kriteria kriteria) async {
    try {
      final response = await supabase
          .from('kriteria')
          .insert(kriteria.toMap())
          .execute();
      _fetchKriteria();
    } on PostgrestException catch (e) {
      print('Error: ${e.message}');
    }
  }

  Future<void> _updateKriteria(Kriteria kriteria) async {
    try {
      final response = await supabase
          .from('kriteria')
          .update(kriteria.toMap())
          .eq('id_kriteria', kriteria.idKriteria)
          .execute();

      setState(() {
        final index = kriteriaList.indexWhere((item) =>
        item.idKriteria == kriteria.idKriteria);
        if (index != -1) {
          kriteriaList[index] = kriteria;
        }
      });
    } on PostgrestException catch (e) {
      print('Error: ${e.message}');
    }
  }

  Future<void> _deleteKriteria(String idKriteria) async {
    try {
      final response = await supabase
          .from('kriteria')
          .delete()
          .eq('id_kriteria', idKriteria)
          .execute();
      _fetchKriteria();
    } on PostgrestException catch (e) {
      print('Error: ${e.message}');
    }
  }

  void _showKriteriaDialog({Kriteria? kriteria}) {
    final idKriteriaController = TextEditingController(
        text: kriteria?.idKriteria ?? '');
    final jenisController = TextEditingController(text: kriteria?.jenis ?? '');
    final attributeController = TextEditingController(
        text: kriteria?.attribute ?? '');
    final bobotController = TextEditingController(
        text: kriteria?.bobot.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF0F4F8),
          title: Text(
            kriteria == null ? 'Tambah Kriteria' : 'Edit Kriteria',
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
                    controller: idKriteriaController,
                    label: 'ID Kriteria',
                    enabled: false,
                  ),
                  SizedBox(height: 8),
                  _buildTextField(
                    controller: jenisController,
                    label: 'Jenis Kriteria',
                  ),
                  SizedBox(height: 8),
                  _buildTextField(
                    controller: attributeController,
                    label: 'Attribute',
                  ),
                  SizedBox(height: 8),
                  _buildTextField(
                    controller: bobotController,
                    label: 'Bobot',
                    keyboardType: TextInputType.number,
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
                final newKriteria = Kriteria(
                  idKriteria: kriteria?.idKriteria ??
                      'C${kriteriaList.length + 1}',
                  jenis: jenisController.text,
                  attribute: attributeController.text,
                  bobot: double.parse(bobotController.text),
                );

                if (kriteria == null) {
                  _addKriteria(newKriteria);
                } else {
                  _updateKriteria(newKriteria);
                }
                Navigator.pop(context);
              },
              child: Text(
                kriteria == null ? 'Tambah' : 'Simpan',
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
          'Data Kriteria',
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
            columnSpacing: 5.0,
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
                  'ID',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Jenis Kriteria',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Attribute',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Bobot',
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
            rows: kriteriaList.map((kriteria) {
              int index = kriteriaList.indexOf(kriteria) + 1;
              return DataRow(
                cells: [
                  DataCell(
                      Text(index.toString(), style: TextStyle(fontSize: 12))),
                  DataCell(Text(
                      kriteria.idKriteria, style: TextStyle(fontSize: 12))),
                  DataCell(
                      Text(kriteria.jenis, style: TextStyle(fontSize: 12))),
                  DataCell(
                      Text(kriteria.attribute, style: TextStyle(fontSize: 12))),
                  DataCell(Text(kriteria.bobot.toString(),
                      style: TextStyle(fontSize: 12))),
                  DataCell(
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) =>
                      [
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
                          _showKriteriaDialog(kriteria: kriteria);
                        } else if (value == 'delete') {
                          _deleteKriteria(kriteria.idKriteria);
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
          _showKriteriaDialog(); // Membuka dialog untuk menambah kriteria baru
        },
        child: Icon(
          Icons.add,
          color: Colors.white, // Mengubah warna ikon "+" menjadi putih
        ),
        backgroundColor: Color(0xFF21899C),
      ),
    );
  }
}
