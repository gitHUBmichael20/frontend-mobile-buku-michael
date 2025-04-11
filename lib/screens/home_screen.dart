import 'package:flutter/material.dart';
import 'package:front_end_mobile/models/book_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:front_end_mobile/providers/book_provider.dart';
import 'buku_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perpustakaan Digital',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () => context.read<BookProvider>().fetchBooks(),
          ),
        ],
        elevation: 1,
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            );
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  provider.errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.red[600],
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: Colors.blue[800],
            onRefresh: () => provider.fetchBooks(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final book = provider.books[index];
                return BookCard(book: book);
              },
            ),
          );
        },
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BukuDetailScreen(book: book),
            fullscreenDialog: true,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${book.idBuku}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    book.tahunTerbit.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                book.judulBuku,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                book.penulis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                book.deskripsiBuku,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}