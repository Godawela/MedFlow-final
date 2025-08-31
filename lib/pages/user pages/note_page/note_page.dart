
// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/models/note_model.dart';
import 'package:med/pages/user%20pages/note_page/widgets/pdf_download_button.dart';
import 'package:med/pages/user%20pages/note_page/widgets/note_dialog.dart'; // Import the new dialog
import 'package:med/widgets/appbar.dart';

@RoutePage()
class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with TickerProviderStateMixin {
  bool _hasInitialized = false;
  List<Note> currentNotes = [];
  final String baseUrl = 'https://medflow-phi.vercel.app/api/notes';
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<List<Note>> fetchNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final response = await http.get(Uri.parse('$baseUrl/${user.uid}'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((note) => Note.fromJson(note)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<void> addNote(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('User not logged in');
      return;
    }

    await http.post(
      Uri.parse('$baseUrl/${user.uid}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
      }),
    );
  }

  Future<void> updateNote(String uid, String id, String newText) async {
    await http.put(
      Uri.parse('$baseUrl/$uid/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': newText}),
    );
  }

  Future<void> deleteNote(String uid, String id) async {
    await http.delete(Uri.parse('$baseUrl/$uid/$id'));
  }

  Future<void> deleteAllNotes(String uid) async {
    await http.delete(Uri.parse('$baseUrl/$uid'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      fetchNotes().then((notes) {
        setState(() {
          currentNotes = notes;
          _hasInitialized = true;
        });
        _fabAnimationController.forward();
        _listAnimationController.forward();
      });
    }
  }

  // Updated method to use the reusable dialog
  Future<void> openNoteDialog({Note? noteToUpdate}) async {
    await showNoteDialog(
      context: context,
      noteToUpdate: noteToUpdate,
      onSave: (text) async {
        await addNote(text);
        await _refreshNotes();
      },
      onUpdate: (id, text) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await updateNote(user.uid, id, text);
          await _refreshNotes();
        }
      },
    );
  }

  // Helper method to refresh notes
  Future<void> _refreshNotes() async {
    final notes = await fetchNotes();
    setState(() {
      currentNotes = notes;
    });
  }

  void confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Note",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await deleteNote(user.uid, note.id);
              }
              await _refreshNotes();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void confirmDeleteAll() {
    if (currentNotes.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Delete All Notes",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              "Are you sure you want to delete ALL notes? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await deleteAllNotes(user.uid);
                }
                await _refreshNotes();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Delete All",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // AppBar
          CurvedAppBar(
            title: 'My Notes',
            subtitle:
                '${currentNotes.length} ${currentNotes.length == 1 ? 'note' : 'notes'}',
            isProfileAvailable: false,
            showIcon: true,
          ),

          // Header section with stats
          if (currentNotes.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tap on the notes to edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentNotes.length} notes saved',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.8),
                            fontSize: 14,
                          ),
                        ),
                        PDFDownloadButton(notes: currentNotes),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: confirmDeleteAll,
                      icon: const Icon(Icons.delete_sweep_rounded,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Clear All',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: currentNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.note_add_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No notes yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to create your first note!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : AnimatedBuilder(
                    animation: _listAnimationController,
                    builder: (context, child) {
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: currentNotes.length,
                        itemBuilder: (context, index) {
                          final note = currentNotes[index];
                          return Transform.translate(
                            offset: Offset(
                              0,
                              50 *
                                  (1 - _listAnimationController.value) *
                                  (index + 1),
                            ),
                            child: Opacity(
                              opacity: _listAnimationController.value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha:0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () =>
                                        openNoteDialog(noteToUpdate: note),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.deepPurple.shade400,
                                                  Colors.deepPurple.shade600,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              note.text,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                height: 1.4,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red.shade400,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  confirmDelete(note),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: () => openNoteDialog(),
            backgroundColor: Colors.deepPurple.shade500,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            label: const Text(
              'New Note',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}