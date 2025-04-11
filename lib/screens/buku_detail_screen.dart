import 'package:flutter/material.dart';
import 'package:front_end_mobile/models/book_model.dart';
import 'package:google_fonts/google_fonts.dart';

class BukuDetailScreen extends StatelessWidget {
  final Book book;

  const BukuDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Buku',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(),
                const SizedBox(height: 24),
                Text(
                  book.judulBuku,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Penulis', book.penulis),
                _buildDetailRow('Tahun Terbit', book.tahunTerbit.toString()),
                const SizedBox(height: 24),
                Text(
                  'Deskripsi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.deskripsiBuku,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('ID Buku', book.idBuku.toString()),
          const Divider(height: 16, thickness: 0.5),
          _buildInfoRow('Tahun Terbit', book.tahunTerbit.toString()),
          const Divider(height: 16, thickness: 0.5),
          _buildInfoRow('Penulis', book.penulis),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}