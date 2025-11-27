import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../providers/notes_provider.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

class CreateNoteScreen extends ConsumerStatefulWidget {
  final String? noteId; // If provided, we're editing an existing note

  const CreateNoteScreen({this.noteId, super.key});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _pdfTitleController = TextEditingController();

  List<File> _selectedImages = [];
  bool _isUploading = false;
  bool _isGeneratingPdf = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    // Reset form state when creating a new note (not editing)
    if (widget.noteId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(noteFormProvider.notifier).reset();
      });
    }

    // Set default PDF title
    final now = DateTime.now();
    _pdfTitleController.text =
        'NEW DOC ${DateFormat('MMM dd, yyyy HH:mm').format(now)}';

    // If editing, load the note data
    if (widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(noteFormProvider.notifier).setEditingNoteId(widget.noteId);
        _loadNoteForEditing();
      });
    }
  }

  Future<void> _loadNoteForEditing() async {
    try {
      final noteAsync = ref.read(noteDetailProvider(widget.noteId!));
      final note = await noteAsync.when(
        data: (note) => Future.value(note),
        loading: () => Future.error('Note is loading'),
        error: (err, stack) => Future.error(err),
      );

      // Populate form with existing note data
      _titleController.text = note.title;
      _contentController.text = note.content;

      final formNotifier = ref.read(noteFormProvider.notifier);
      formNotifier.updateTitle(note.title);
      formNotifier.updateContent(note.content);
      if (note.category != null) {
        formNotifier.setCategory(note.category);
      }
      for (final tag in note.tags) {
        formNotifier.addTag(tag);
      }

      // Determine note type based on content
      if (note.pdfUrl != null || note.hasPdf) {
        formNotifier.setNoteType(NoteType.file);
        formNotifier.setPdfUrl(note.pdfUrl);
        if (note.images.isNotEmpty) {
          formNotifier.setImageUrls(note.images);
        }
      } else if (note.attachments.isNotEmpty) {
        formNotifier.setNoteType(NoteType.file);
        formNotifier.setFileUrl(note.attachments.first);
      } else {
        formNotifier.setNoteType(NoteType.text);
      }
    } catch (e) {
      ToastService.showError('Failed to load note: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pdfTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            images.map((xFile) => File(xFile.path)).toList(),
          );
        });
      }
    } catch (e) {
      ToastService.showError('Failed to pick images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      ToastService.showError('Failed to take photo: $e');
    }
  }

  Future<void> _showImageSourceDialog() async {
    // Check if title is entered first
    if (_titleController.text.trim().isEmpty) {
      ToastService.showError('Please enter a title first');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      final item = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, item);
    });
  }

  Future<void> _selectFile() async {
    // Check if title is entered first
    if (_titleController.text.trim().isEmpty) {
      ToastService.showError('Please enter a title first');
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _uploadFile(file);
      }
    } catch (e) {
      ToastService.showError('Failed to select file: $e');
    }
  }

  Future<void> _uploadFile(File file) async {
    if (!_formKey.currentState!.validate()) {
      ToastService.showError('Please enter a title first');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Uploading file...';
    });
    try {
      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final url = await cloudinaryService.uploadFile(
        file,
        folder: 'notes/files',
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              _uploadProgress = sent / total;
              _uploadStatus =
                  'Uploading: ${(_uploadProgress * 100).toStringAsFixed(1)}%';
            });
          }
        },
      );

      ref.read(noteFormProvider.notifier).setFileUrl(url);
      ToastService.showSuccess('File uploaded successfully');

      // Save the note
      await _saveNote();
    } catch (e) {
      ToastService.showError('Failed to upload file: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _uploadStatus = '';
        });
      }
    }
  }

  Future<void> _generatePdfFromImages() async {
    if (_selectedImages.isEmpty) {
      ToastService.showError('Please select at least one image');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ToastService.showError('Please enter a title');
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Generating PDF...';
    });
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final cloudinaryService = ref.read(cloudinaryServiceProvider);

      // Generate PDF
      if (mounted) {
        setState(() => _uploadStatus = 'Generating PDF from images...');
      }
      final pdfFile = await pdfService.generatePdfFromImages(
        _selectedImages,
        title: _pdfTitleController.text.trim(),
      );

      // Upload PDF to Cloudinary
      if (mounted) {
        setState(() => _uploadStatus = 'Uploading PDF...');
      }
      final pdfUrl = await cloudinaryService.uploadFile(
        pdfFile,
        folder: 'notes/pdfs',
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              // PDF upload is 70% of total progress
              _uploadProgress = (sent / total) * 0.7;
              _uploadStatus =
                  'Uploading PDF: ${((sent / total) * 100).toStringAsFixed(1)}%';
            });
          }
        },
      );

      // Upload images to Cloudinary for reference
      if (mounted) {
        setState(() => _uploadStatus = 'Uploading images...');
      }
      final imageUrls = await cloudinaryService.uploadImages(
        _selectedImages,
        folder: 'notes/images',
        onProgress: (current, total, sent, totalBytes) {
          if (mounted) {
            setState(() {
              // Images upload is 30% of total progress (starts at 70%)
              final imageProgress = sent / totalBytes;
              _uploadProgress = 0.7 + (imageProgress * 0.3);
              _uploadStatus =
                  'Uploading images: $current/$total (${(_uploadProgress * 100).toStringAsFixed(1)}%)';
            });
          }
        },
      );

      ref.read(noteFormProvider.notifier).setPdfUrl(pdfUrl);
      ref.read(noteFormProvider.notifier).setImageUrls(imageUrls);

      // Update note title if it's still empty or default
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = _pdfTitleController.text.trim();
        ref
            .read(noteFormProvider.notifier)
            .updateTitle(_pdfTitleController.text.trim());
      }

      ToastService.showSuccess('PDF generated and uploaded successfully');

      // Save the note
      await _saveNote();
    } catch (e) {
      ToastService.showError('Failed to generate PDF: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<void> _saveNote() async {
    final formNotifier = ref.read(noteFormProvider.notifier);
    formNotifier.updateTitle(_titleController.text.trim());

    if (ref.read(noteFormProvider).noteType == NoteType.text) {
      formNotifier.updateContent(_contentController.text.trim());
    }

    await formNotifier.save();

    if (mounted) {
      final formState = ref.read(noteFormProvider);
      if (formState.isSuccess) {
        ref.invalidate(notesProvider);
        ref.invalidate(recentNotesProvider);
        if (widget.noteId != null) {
          ref.invalidate(noteDetailProvider(widget.noteId!));
        }

        // Reset form state after successful save
        formNotifier.reset();

        context.pop();
        ToastService.showSuccess(
          widget.noteId != null
              ? 'Note updated successfully'
              : 'Note created successfully',
        );
      } else if (formState.error != null) {
        ToastService.showError(formState.error!);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final noteType = ref.read(noteFormProvider).noteType;

    if (noteType == NoteType.text) {
      await _saveNote();
    } else {
      // For file type, check if file is uploaded or PDF is generated
      final formState = ref.read(noteFormProvider);
      if (formState.fileUrl == null && formState.pdfUrl == null) {
        ToastService.showError(
          'Please upload a file or generate a PDF from images',
        );
        return;
      }
      await _saveNote();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(noteFormProvider);
    final noteType = formState.noteType;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId != null ? 'Edit Note' : 'Create Note'),
        actions: [
          TextButton(
            onPressed: (formState.isSaving || _isUploading || _isGeneratingPdf)
                ? null
                : _handleSave,
            child: (formState.isSaving || _isUploading || _isGeneratingPdf)
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
        child: Column(
          children: [
            // Progress Indicator
            if (_isUploading || _isGeneratingPdf)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _uploadProgress > 0 ? _uploadProgress : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _uploadStatus.isNotEmpty
                                ? _uploadStatus
                                : (_isUploading
                                      ? 'Uploading...'
                                      : 'Generating PDF...'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (_uploadProgress > 0)
                          Text(
                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    if (_uploadProgress > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        minHeight: 4,
                      ),
                    ],
                  ],
                ),
              ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Input
                    CustomTextField(
                      label: 'Title',
                      hint: 'Enter note title',
                      controller: _titleController,
                      validator: Validators.noteTitle,
                      onChanged: (value) {
                        ref.read(noteFormProvider.notifier).updateTitle(value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Note Type Selection
                    Text(
                      'Note Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<NoteType>(
                            title: const Text('Text Note'),
                            value: NoteType.text,
                            groupValue: noteType,
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(noteFormProvider.notifier)
                                    .setNoteType(value);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<NoteType>(
                            title: const Text('File/Docs/PDF'),
                            value: NoteType.file,
                            groupValue: noteType,
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(noteFormProvider.notifier)
                                    .setNoteType(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Content based on note type
                    if (noteType == NoteType.text) ...[
                      // Text Note Editor
                      CustomTextField(
                        label: 'Content',
                        hint: 'Write your note here...',
                        controller: _contentController,
                        maxLines: 15,
                        onChanged: (value) {
                          ref
                              .read(noteFormProvider.notifier)
                              .updateContent(value);
                        },
                      ),
                    ] else ...[
                      // File/Docs/PDF Options
                      _buildFileOptions(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Option 1: Select File
        Card(
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('Select File (Docs/PDF)'),
            subtitle: const Text('Upload a document or PDF file'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectFile,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Option 2: Make PDF from Images
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Make PDF from Images'),
                subtitle: const Text('Select images and create a PDF'),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PDF Title Input
                    CustomTextField(
                      label: 'Document Name',
                      hint: 'Enter document name',
                      controller: _pdfTitleController,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Image Grid
                    if (_selectedImages.isNotEmpty) ...[
                      _buildImageGrid(),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Add Image Button
                    OutlinedButton.icon(
                      onPressed: _titleController.text.trim().isEmpty
                          ? () => ToastService.showError(
                              'Please enter a title first',
                            )
                          : _showImageSourceDialog,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Images'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),

                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        text: 'Make PDF',
                        onPressed: _isGeneratingPdf
                            ? null
                            : _generatePdfFromImages,
                        isLoading: _isGeneratingPdf,
                        icon: Icons.picture_as_pdf,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          // Add button
          return InkWell(
            onTap: _titleController.text.trim().isEmpty
                ? () => ToastService.showError('Please enter a title first')
                : _showImageSourceDialog,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add Image',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        // Image with drag and drop
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_selectedImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          child: DragTarget<int>(
            onAccept: (draggedIndex) {
              if (draggedIndex != index) {
                _reorderImages(draggedIndex, index);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImages[index]),
                        fit: BoxFit.cover,
                      ),
                      border: candidateData.isNotEmpty
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ),
                  // Drag handle
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.drag_handle,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
