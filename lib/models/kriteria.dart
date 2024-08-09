class Kriteria {
  final String idKriteria;
  final String jenis;
  final String attribute;
  final double bobot;

  Kriteria({
    required this.idKriteria,
    required this.jenis,
    required this.attribute,
    required this.bobot,
  });

  factory Kriteria.fromMap(Map<String, dynamic> map) {
    return Kriteria(
      idKriteria: map['id_kriteria'],
      jenis: map['jenis'],
      attribute: map['attribute'],
      bobot: map['bobot'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_kriteria': idKriteria,
      'jenis': jenis,
      'attribute': attribute,
      'bobot': bobot,
    };
  }
}
