import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'HomePage.dart';
import 'ProfilePage.dart';

class DataNilaiPage extends StatefulWidget {
  @override
  _DataNilaiPageState createState() => _DataNilaiPageState();
}

class _DataNilaiPageState extends State<DataNilaiPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> kriteria = [];
  List<Map<String, dynamic>> alternatif = [];
  Map<String, Map<String, double>> nilai = {};
  Map<String, double> normalizedWeights = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final responseKriteria = await supabase.from('kriteria').select().execute();
    final responseAlternatif = await supabase.from('alternatif').select().execute();
    final responseNilai = await supabase.from('datanilai').select().execute();

    setState(() {
      kriteria = List<Map<String, dynamic>>.from(responseKriteria.data);
      alternatif = List<Map<String, dynamic>>.from(responseAlternatif.data);

      for (var data in responseNilai.data) {
        String idAlternatif = data['id_alternatif'].toString();
        String idKriteria = data['id_kriteria'].toString();
        double value = data['nilai'].toDouble();

        if (!nilai.containsKey(idAlternatif)) {
          nilai[idAlternatif] = {};
        }
        nilai[idAlternatif]![idKriteria] = value;
      }
    });

    normalizeWeights();
  }

  void normalizeWeights() {
    double totalWeight = kriteria.fold(0, (sum, k) => sum + (k['bobot'] ?? 0.0));
    setState(() {
      for (var k in kriteria) {
        normalizedWeights[k['id_kriteria'].toString()] = (k['bobot'] ?? 0.0) / totalWeight;
      }
    });
  }

  Map<String, double> calculateMinMax(String idKriteria) {
    double min = double.infinity;
    double max = double.negativeInfinity;

    nilai.forEach((idAlternatif, nilaiMap) {
      double value = nilaiMap[idKriteria] ?? 0.0;
      if (value < min) min = value;
      if (value > max) max = value;
    });

    return {'min': min, 'max': max};
  }

  double calculateUtility(double value, double min, double max, String attribute) {
    double result;
    if (attribute == 'benefit') {
      result = (max - min) != 0 ? ((value - min) / (max - min)) : 0;
    } else { // cost
      result = (max - min) != 0 ? ((max - value) / (max - min)) : 0;
    }
    return result.isNaN ? 0 : result;
  }

  Future<void> saveResults() async {
    try {
      await supabase.from('datanilai').delete().neq('id', -1).execute();
      await supabase.from('hasil').delete().neq('id', -1).execute();

      List<Map<String, dynamic>> results = [];

      for (var alt in alternatif) {
        String idAlternatif = alt['id_alternatif'].toString();
        double finalScore = 0;

        for (var k in kriteria) {
          String idKriteria = k['id_kriteria'].toString();
          double value = nilai[idAlternatif]?[idKriteria] ?? 0.0;

          var minMax = calculateMinMax(idKriteria);
          double minValue = minMax['min'] ?? 0.0;
          double maxValue = minMax['max'] ?? 0.0;
          String attribute = k['attribute'];

          double utility = calculateUtility(value, minValue, maxValue, attribute);
          double normalizedWeight = normalizedWeights[idKriteria] ?? 0.0;
          finalScore += utility * normalizedWeight;
        }

        results.add({
          'nama_alternatif': alt['nama_alternatif'],
          'nilai_akhir': finalScore.isNaN ? 0 : finalScore,
        });

        for (var k in kriteria) {
          String idKriteria = k['id_kriteria'].toString();
          double value = nilai[idAlternatif]?[idKriteria] ?? 0.0;
          await supabase.from('datanilai').insert({
            'id_alternatif': idAlternatif,
            'id_kriteria': idKriteria,
            'nilai': value,
          }).execute();
        }
      }

      results.sort((a, b) => b['nilai_akhir'].compareTo(a['nilai_akhir']));

      for (int i = 0; i < results.length; i++) {
        results[i]['ranking'] = i + 1;
      }

      for (var result in results) {
        await supabase.from('hasil').insert(result).execute();
      }

      fetchData();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Sukses",
              style: GoogleFonts.inter(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF21899C)),
            ),
            content: Text("Data berhasil disimpan.", style: GoogleFonts.inter(fontSize: 16.0, color: Color(0xFF151624))),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK", style: GoogleFonts.inter(fontSize: 14.0, color: Color(0xFFFF7248), fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Error",
              style: GoogleFonts.inter(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF21899C)),
            ),
            content: Text("Terjadi kesalahan: $e", style: GoogleFonts.inter(fontSize: 16.0, color: Color(0xFF151624))),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK", style: GoogleFonts.inter(fontSize: 14.0, color: Color(0xFFFF7248), fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      );
    }
  }

  void updateNilai(String idAlternatif, String idKriteria, double newValue) {
    setState(() {
      if (!nilai.containsKey(idAlternatif)) {
        nilai[idAlternatif] = {};
      }
      nilai[idAlternatif]![idKriteria] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Nilai',
          style: GoogleFonts.inter(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF21899C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: kriteria.isEmpty || alternatif.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: MaterialStateProperty.resolveWith((states) => Color(0xFF21899C)),
                    headingRowHeight: 50,
                    dataRowHeight: 40,
                    columns: [
                      DataColumn(label: Text('No', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))),
                      DataColumn(label: Text('Alternatif', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))),
                      ...kriteria.map((k) {
                        return DataColumn(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                k['id_kriteria'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              ),
                              Text(
                                k['jenis'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    rows: alternatif.map((alt) {
                      String idAlternatif = alt['id_alternatif'].toString();
                      return DataRow(
                        cells: [
                          DataCell(Text(alt['id_alternatif'], style: GoogleFonts.inter(fontSize: 12))),
                          DataCell(Text(alt['nama_alternatif'], style: GoogleFonts.inter(fontSize: 12))),
                          ...kriteria.map((k) {
                            String idKriteria = k['id_kriteria'].toString();
                            return DataCell(
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  initialValue: nilai[idAlternatif]?[idKriteria]?.toString() ?? '',
                                  keyboardType: TextInputType.number,
                                  onChanged: (newValue) {
                                    double? parsedValue = double.tryParse(newValue);
                                    if (parsedValue != null) {
                                      updateNilai(idAlternatif, idKriteria, parsedValue);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveResults,
        backgroundColor: Color(0xFF21899C),
        child: Icon(
          Icons.save,
          color: Colors.white, // Warna ikon menjadi putih
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
