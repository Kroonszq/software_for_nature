import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/data/models/event_attachment.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventAttachmentsField extends StatelessWidget {
  const EventAttachmentsField({super.key});

  String _fmtSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFiles(EventFormBloc bloc) async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null) return;
    final attachments = result.files
        .map((f) => EventAttachment(name: f.name, path: f.path, size: f.size))
        .toList();
    if (attachments.isNotEmpty) bloc.add(AttachmentsAdded(attachments));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) => prev.attachments != curr.attachments,
      builder: (context, state) {
        final bloc = context.read<EventFormBloc>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Files'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _pickFiles(bloc),
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add files'),
                ),
              ],
            ),
            ...state.attachments.map(
              (a) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(a.name, overflow: TextOverflow.ellipsis),
                subtitle: a.size != null ? Text(_fmtSize(a.size)) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => bloc.add(AttachmentRemoved(a)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
