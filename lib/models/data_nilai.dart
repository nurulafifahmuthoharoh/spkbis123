class DataNilai {
  String idAlternatif;
  String idKriteria;
  double nilai;

  DataNilai({
    required this.idAlternatif,
    required this.idKriteria,
    required this.nilai,
  });

  factory DataNilai.fromMap(Map<String, dynamic> map) {
    return DataNilai(
      idAlternatif: map['id_alternatif'],
      idKriteria: map['id_kriteria'],
      nilai: map['nilai'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alternatif': idAlternatif,
      'id_kriteria': idKriteria,
      'nilai': nilai,
    };
  }
}
