class Hasil {
  final String namaAlternatif;
  final int rangking;
  final double nilaiAkhir;

  Hasil({
    required this.namaAlternatif,
    required this.rangking,
    required this.nilaiAkhir,

  });

  factory Hasil.fromMap(Map<String, dynamic> map) {
    return Hasil(
      namaAlternatif: map['nama_alternatif'] as String,
      nilaiAkhir: map['nilai_akhir'].toDouble(),
      rangking: map['ranking'] as int, // Fix the typo
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'nama_alternatif': namaAlternatif,
      'nilai_akhir': nilaiAkhir,
      'rangkig': rangking,
    };
  }
}
