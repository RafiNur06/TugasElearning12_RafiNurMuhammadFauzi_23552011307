import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note.dart';
import 'note_db.dart';
import 'note_form_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await NoteDb.instance.queryAll();
    _notes = rows.map((e) => Note.fromMap(e)).toList();
    setState(() => _loading = false);
  }

  Future<void> _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteFormPage()),
    );
    _load();
  }

  Future<void> _openEdit(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteFormPage(note: note)),
    );
    _load();
  }

  Future<void> _delete(int id) async {
    await NoteDb.instance.delete(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (_, i) {
                final n = _notes[i];
                final color = n.noteColorByDeadline(n.deadline);
                final deadlineText = n.deadline == null
                    ? 'Non-priority'
                    : DateFormat('dd MMM yyyy').format(n.deadline!);

                return Dismissible(
                  key: ValueKey(n.id),
                  onDismissed: (_) => _delete(n.id!),
                  child: InkWell(
                    onTap: () => _openEdit(n),
                    child: Card(
                      color: color,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                n.content,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(deadlineText,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
