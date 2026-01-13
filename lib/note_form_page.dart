import 'package:flutter/material.dart';
import 'note.dart';
import 'note_db.dart';

class NoteFormPage extends StatefulWidget {
  final Note? note;
  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  DateTime? _deadline;

  bool get _isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _title.text = widget.note!.title;
      _content.text = widget.note!.content;
      _deadline = widget.note!.deadline;
    }
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _clearDeadline() {
    setState(() => _deadline = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id,
      title: _title.text.trim(),
      content: _content.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      deadline: _deadline,
    );

    if (_isEdit) {
      await NoteDb.instance.update(note.id!, note.toMap());
    } else {
      await NoteDb.instance.insert(note.toMap());
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Note' : 'Tambah Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _content,
                decoration: const InputDecoration(labelText: 'Isi'),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Text(_deadline == null
                  ? 'Deadline: Tidak ada'
                  : 'Deadline: ${_deadline!.toLocal()}'),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _pickDeadline,
                    child: const Text('Pilih Deadline'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _clearDeadline,
                    child: const Text('Hapus Deadline'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
