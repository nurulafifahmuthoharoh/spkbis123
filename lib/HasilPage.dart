import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_fonts/google_fonts.dart';

import 'HomePage.dart';
import 'ProfilePage.dart';
import 'models/hasil.dart';

class HasilPage extends StatefulWidget {
  @override
  _HasilPageState createState() => _HasilPageState();
}

class _HasilPageState extends State<HasilPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Hasil> hasilList = [];

  @override
  void initState() {
    super.initState();
    _fetchHasil();
  }

  Future<void> _fetchHasil() async {
    final response = await supabase
        .from('hasil')
        .select('id, nama_alternatif, ranking, nilai_akhir')
        .execute();

    final data = response.data as List<dynamic>;

    setState(() {
      hasilList = data.map((item) => Hasil.fromMap(item)).toList();
    });
  }

  Future<void> _generatePdf() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SMARTBUSEVAL',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Aplikasi Pendukung Keputusan Kelayakan Kendaraan Dengan Metode SMART',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Divider(),
              pw.Text(
                'Laporan Data Kelayakan Kendaraan Pada PO Haryanto',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('21899C')),
                cellAlignment: pw.Alignment.center,
                headers: <String>['No', 'Nama Alternatif', 'Nilai Akhir', 'Ranking'],
                data: <List<String>>[
                  ...hasilList.map((hasil) => [
                    (hasilList.indexOf(hasil) + 1).toString(),
                    hasil.namaAlternatif,
                    hasil.nilaiAkhir.toString(),
                    hasil.rangking.toString(),
                  ])
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  void _showKriteriaDialog() {
    // Implement the logic to show a dialog for adding kriteria
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil Nilai Akhir',
          style: GoogleFonts.inter(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF21899C),
      ),
      body: hasilList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 25,
            headingRowColor: MaterialStateProperty.resolveWith((states) => Color(0xFF21899C)),
            columns: const [
              DataColumn(
                label: Text(
                  'No',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Nama Alternatif',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Nilai Akhir',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Ranking',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
            rows: hasilList.map((hasil) {
              int index = hasilList.indexOf(hasil) + 1;
              return DataRow(
                cells: [
                  DataCell(Text(index.toString(), style: TextStyle(fontSize: 12))),
                  DataCell(Text(hasil.namaAlternatif, style: TextStyle(fontSize: 12))),
                  DataCell(Text(hasil.nilaiAkhir.toString(), style: TextStyle(fontSize: 12))),
                  DataCell(Text(hasil.rangking.toString(), style: TextStyle(fontSize: 12))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePdf, // Fungsi untuk menghasilkan PDF
        child: Icon(
          Icons.print,
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
