class Alternatif {
  final String idAlternatif;
  final String namaAlternatif;

  Alternatif({
    required this.idAlternatif,
    required this.namaAlternatif,
  });

  factory Alternatif.fromMap(Map<String, dynamic> map) {
    return Alternatif(
      idAlternatif: map['id_alternatif'],
      namaAlternatif: map['nama_alternatif'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alternatif': idAlternatif,
      'nama_alternatif': namaAlternatif,
    };
  }
}
