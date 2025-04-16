
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:med/models/note_model.dart';



@RoutePage()
class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final textController = TextEditingController();
  bool _hasInitialized = false;
  List<Note> currentNotes = [];
  final String baseUrl = 'http://10.0.2.2:8000/api/notes';

  Future<List<Note>> fetchNotes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((note) => Note.fromJson(note)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<void> addNote(String text) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
  }

  Future<void> updateNote(String id, String newText) async {
    await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': newText}),
    );
  }

  Future<void> deleteNote(String id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }

  Future<void> deleteAllNotes() async {
     await http.delete(Uri.parse(baseUrl));
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
      });
    }
  }

  void openNoteDialog({Note? noteToUpdate}) {
    if (noteToUpdate != null) {
      textController.text = noteToUpdate.text;
    } else {
      textController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(noteToUpdate == null ? 'Create Note' : 'Update Note'),
          content: TextField(
            controller: textController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your note...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                textController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final noteText = textController.text.trim();
                if (noteText.isEmpty) return;

                if (noteToUpdate == null) {
                  await addNote(noteText);
                } else {
                  await updateNote(noteToUpdate.id, noteText);
                }

                currentNotes = await fetchNotes();
                setState(() {});
                textController.clear();
                Navigator.pop(context);
              },
              child: Text(noteToUpdate == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteNote(note.id);
              currentNotes = await fetchNotes();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              if (currentNotes.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete All Notes"),
                    content: const Text("Are you sure you want to delete ALL notes?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await deleteAllNotes();
                          currentNotes = await fetchNotes();
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text("Delete All"),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteDialog(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: currentNotes.isEmpty
            ? const Center(child: Text('No notes yet. Tap + to add one!'))
            : ListView.builder(
                itemCount: currentNotes.length,
                itemBuilder: (context, index) {
                  final note = currentNotes[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        note.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () => openNoteDialog(noteToUpdate: note),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmDelete(note),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}