import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../providers/notes_provider.dart';

class CreateNoteScreen extends ConsumerStatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final formNotifier = ref.read(noteFormProvider.notifier);
      formNotifier.updateTitle(_titleController.text.trim());
      formNotifier.updateContent(_contentController.text.trim());
      await formNotifier.save();

      if (mounted) {
        final formState = ref.read(noteFormProvider);
        if (formState.isSuccess) {
          ref.invalidate(notesProvider);
          ref.invalidate(recentNotesProvider);
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note created successfully')),
          );
        } else if (formState.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(formState.error!)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(noteFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Note'),
        actions: [
          TextButton(
            onPressed: formState.isSaving ? null : _handleSave,
            child: formState.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Title',
                hint: 'Enter note title',
                controller: _titleController,
                validator: Validators.noteTitle,
                onChanged: (value) {
                  ref.read(noteFormProvider.notifier).updateTitle(value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Content',
                hint: 'Enter note content',
                controller: _contentController,
                maxLines: 15,
                onChanged: (value) {
                  ref.read(noteFormProvider.notifier).updateContent(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
