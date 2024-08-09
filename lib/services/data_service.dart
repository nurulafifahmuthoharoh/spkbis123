import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kriteria.dart';
import '../models/alternatif.dart';
import '../models/data_nilai.dart';

class DataService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Kriteria>> fetchKriteria() async {
    final response = await supabase.from('kriteria').select().execute();
    final data = response.data as List<dynamic>;
    return data.map((item) => Kriteria.fromMap(item)).toList();
  }

  Future<List<Alternatif>> fetchAlternatif() async {
    final response = await supabase.from('alternatif').select().execute();
    final data = response.data as List<dynamic>;
    return data.map((item) => Alternatif.fromMap(item)).toList();
  }

  Future<List<DataNilai>> fetchDataNilai() async {
    final response = await supabase.from('data_nilai').select().execute();
    final data = response.data as List<dynamic>;
    return data.map((item) => DataNilai.fromMap(item)).toList();
  }
}
