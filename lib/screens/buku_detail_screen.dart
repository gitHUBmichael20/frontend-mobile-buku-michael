import 'package:flutter/material.dart';
import 'package:front_end_mobile/models/book_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:front_end_mobile/config/api_config.dart';

class BukuDetailScreen extends StatefulWidget {
  final Book book;

  const BukuDetailScreen({super.key, required this.book});

  @override
  State<BukuDetailScreen> createState() => _BukuDetailScreenState();
}

class _BukuDetailScreenState extends State<BukuDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _judulController;
  late TextEditingController _penulisController;
  late TextEditingController _deskripsiController;
  late TextEditingController _tahunController;
  late TextEditingController _sampulController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _judulController = TextEditingController(text: widget.book.judulBuku);
    _penulisController = TextEditingController(text: widget.book.penulis);
    _deskripsiController =
        TextEditingController(text: widget.book.deskripsiBuku);
    _tahunController =
        TextEditingController(text: widget.book.tahunTerbit.toString());
    _sampulController = TextEditingController(text: widget.book.sampulBuku);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _deskripsiController.dispose();
    _tahunController.dispose();
    _sampulController.dispose();
    super.dispose();
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset form if canceling edit
        _initControllers();
      }
    });
  }

  // Update book data
  Future<void> _updateBook() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      _showMessage('Silakan login untuk mengubah buku');
      setState(() => _isLoading = false);
      return;
    }

    // Validate required fields
    if (_judulController.text.isEmpty ||
        _penulisController.text.isEmpty ||
        _tahunController.text.isEmpty) {
      _showMessage('Judul, penulis, dan tahun terbit tidak boleh kosong');
      setState(() => _isLoading = false);
      return;
    }

    final url =
        Uri.parse('${ApiConfig.baseUrl}/buku/update/${widget.book.idBuku}');

    // Prepare request body
    final bookData = {
      'judul_buku': _judulController.text,
      'penulis': _penulisController.text,
      'deskripsi_buku': _deskripsiController.text,
      'tahun_terbit': _tahunController.text,
      'sampul_buku': _sampulController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bookData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update local book object with new data
        final updatedBook = Book(
          idBuku: widget.book.idBuku,
          judulBuku: _judulController.text,
          penulis: _penulisController.text,
          deskripsiBuku: _deskripsiController.text,
          tahunTerbit:
              int.tryParse(_tahunController.text) ?? widget.book.tahunTerbit,
          sampulBuku: _sampulController.text,
        );

        setState(() {
          // Update widget.book with new values (requires passing back to parent)
          // For now, just exit edit mode
          _isEditing = false;
        });

        _showMessage(data['message'] ?? 'Buku berhasil diubah');

        // Return to previous screen with updated data
        Navigator.pop(context, updatedBook);
      } else {
        _showMessage(data['message'] ?? 'Gagal mengubah buku');
      }
    } catch (e) {
      _showMessage('Kesalahan: Tidak dapat terhubung ke server');
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteBook() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      _showMessage('Silakan login untuk menghapus buku');
      return;
    }

    final url =
        Uri.parse('${ApiConfig.baseUrl}/buku/delete/${widget.book.idBuku}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showMessage(data['message'] ?? 'Buku berhasil dihapus');
        Navigator.pop(context); // Kembali ke layar sebelumnya
      } else {
        final data = jsonDecode(response.body);
        _showMessage(data['message'] ?? 'Gagal menghapus buku');
      }
    } catch (e) {
      _showMessage('Kesalahan: Tidak dapat terhubung ke server');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Buku'),
          content: const Text('Apakah Anda yakin ingin menghapus buku ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _buildAppBarActions(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? _buildEditForm()
              : _buildBookDetails(),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isEditing) {
      return [
        TextButton(
          onPressed: _toggleEditMode,
          child: Text('Batal',
              style: GoogleFonts.poppins(color: Colors.grey[700])),
        ),
        TextButton(
          onPressed: _updateBook,
          child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.blue)),
        ),
        const SizedBox(width: 8),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: _toggleEditMode,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: _showDeleteConfirmation,
        ),
        const SizedBox(width: 8),
      ];
    }
  }

  Widget _buildBookDetails() {
    final size = MediaQuery.of(context).size;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCoverImage(size),
                const SizedBox(height: 24),
                Text(
                  widget.book.judulBuku,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.book.penulis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      ' • ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      widget.book.tahunTerbit.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildDescriptionCard(),
        ),
      ],
    );
  }

  Widget _buildCoverImage(Size size) {
    return Container(
      height: size.height * 0.33,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.book.sampulBuku,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            alignment: Alignment.center,
            child:
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '#${widget.book.idBuku}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Deskripsi Buku',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.book.deskripsiBuku,
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormTitle('Edit Buku'),
          const SizedBox(height: 20),
          _buildTextField('Judul Buku', _judulController),
          _buildTextField('Penulis', _penulisController),
          _buildTextField('Tahun Terbit', _tahunController,
              keyboardType: TextInputType.number),
          _buildTextField('URL Sampul', _sampulController),
          _buildTextField('Deskripsi', _deskripsiController, maxLines: 5),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[400]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
