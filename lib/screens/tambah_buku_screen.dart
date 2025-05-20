import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:front_end_mobile/config/api_config.dart';

class TambahBukuScreen extends StatefulWidget {
  const TambahBukuScreen({super.key});

  @override
  State<TambahBukuScreen> createState() => _TambahBukuScreenState();
}

class _TambahBukuScreenState extends State<TambahBukuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _penulisCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _tahunCtrl = TextEditingController();
  final _sampulCtrl = TextEditingController();

  bool _isSubmitting = false;
  final _focusNodes = List.generate(5, (_) => FocusNode());

  // Color palette
  final Color primaryColor = const Color(0xFF213448);
  final Color accentColor = const Color(0xFF547792);
  final Color backgroundColor = const Color(0xFFF5F5F5);

  @override
  void dispose() {
    _judulCtrl.dispose();
    _penulisCtrl.dispose();
    _deskripsiCtrl.dispose();
    _tahunCtrl.dispose();
    _sampulCtrl.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _judulCtrl.clear();
    _penulisCtrl.clear();
    _deskripsiCtrl.clear();
    _tahunCtrl.clear();
    _sampulCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    final url = Uri.parse('${ApiConfig.baseUrl}/buku/simpan');
    final body = jsonEncode({
      'judul_buku': _judulCtrl.text,
      'penulis': _penulisCtrl.text,
      'deskripsi_buku': _deskripsiCtrl.text,
      'tahun_terbit': _tahunCtrl.text,
      'sampul_buku': _sampulCtrl.text,
    });

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          _showSnackBar('✅ Buku berhasil disimpan', isError: false);
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          _showSnackBar('❌ Gagal: ${res.statusCode}', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('⚠️ Network error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(),
      prefixIcon: Icon(icon, color: accentColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Tambah Buku',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.book_outlined,
                            color: primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Masukkan detail buku baru',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form fields
                  TextFormField(
                    controller: _judulCtrl,
                    focusNode: _focusNodes[0],
                    decoration: _getInputDecoration('Judul Buku', Icons.title),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _focusNodes[1].requestFocus(),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Judul tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _penulisCtrl,
                    focusNode: _focusNodes[1],
                    decoration: _getInputDecoration('Penulis', Icons.person),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _focusNodes[2].requestFocus(),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Penulis tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _deskripsiCtrl,
                    focusNode: _focusNodes[2],
                    decoration:
                        _getInputDecoration('Deskripsi', Icons.description),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _focusNodes[3].requestFocus(),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _tahunCtrl,
                    focusNode: _focusNodes[3],
                    decoration: _getInputDecoration(
                        'Tahun Terbit', Icons.calendar_today),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _focusNodes[4].requestFocus(),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Tahun tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _sampulCtrl,
                    focusNode: _focusNodes[4],
                    decoration: _getInputDecoration(
                        'URL Sampul Buku', Icons.image_outlined),
                    validator: (v) => v == null || v.isEmpty
                        ? 'URL sampul tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _clearForm,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.clear, size: 18),
                          label: Text('Bersihkan',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save, size: 18),
                          label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
