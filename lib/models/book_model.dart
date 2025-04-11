class Book {
  final int idBuku;
  final String judulBuku;
  final String deskripsiBuku;
  final String penulis;
  final int tahunTerbit;

  Book({
    required this.idBuku,
    required this.judulBuku,
    required this.deskripsiBuku,
    required this.penulis,
    required this.tahunTerbit,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      idBuku: json['id_buku'],
      judulBuku: json['judul_buku'],
      deskripsiBuku: json['deskripsi_buku'],
      penulis: json['penulis'],
      tahunTerbit: json['tahun_terbit'],
    );
  }
}