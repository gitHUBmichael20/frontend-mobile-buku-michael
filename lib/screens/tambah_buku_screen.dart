import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class TambahBukuScreen extends StatefulWidget {
  const TambahBukuScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TambahBukuScreenState createState() => _TambahBukuScreenState();
}

class _TambahBukuScreenState extends State<TambahBukuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _penulisCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _tahunCtrl = TextEditingController();
  final _sampulCtrl = TextEditingController(); // Sampul URL

  bool _isSubmitting = false;

  void _clearForm() {
    _formKey.currentState?.reset();
    _judulCtrl.clear();
    _penulisCtrl.clear();
    _deskripsiCtrl.clear();
    _tahunCtrl.clear();
    _sampulCtrl.clear();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final url = Uri.parse('http://194.168.2.191:8000/api/simpan');
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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Buku berhasil disimpan')));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Gagal: ${res.statusCode}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('⚠️ Network error: $e')));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _penulisCtrl.dispose();
    _deskripsiCtrl.dispose();
    _tahunCtrl.dispose();
    _sampulCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Buku',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Judul
                  TextFormField(
                    controller: _judulCtrl,
                    decoration: InputDecoration(
                      labelText: 'Judul Buku',
                      prefixIcon: const Icon(Icons.title),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Judul tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // Penulis
                  TextFormField(
                    controller: _penulisCtrl,
                    decoration: InputDecoration(
                      labelText: 'Penulis',
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Penulis tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // Deskripsi
                  TextFormField(
                    controller: _deskripsiCtrl,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      prefixIcon: const Icon(Icons.description),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  // Tahun Terbit
                  TextFormField(
                    controller: _tahunCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tahun Terbit',
                      prefixIcon: const Icon(Icons.date_range),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Tahun tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // URL Sampul
                  TextFormField(
                    controller: _sampulCtrl,
                    decoration: InputDecoration(
                      labelText: 'URL Sampul Buku',
                      hintText: 'https://example.com/image.jpg',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Sampul tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : _clearForm,
                          child: const Text('Bersihkan'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Simpan'),
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
