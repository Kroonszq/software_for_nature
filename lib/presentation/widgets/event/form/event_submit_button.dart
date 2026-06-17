import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/event_form_bloc/event_form_bloc.dart';

class EventSubmitButton extends StatelessWidget {
  const EventSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormBloc, EventFormBlocState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        final submitting = state.status == EventFormStatus.submitting;

        VoidCallback? onPressed;
        if (!submitting) {
          onPressed = () {
            if (Form.of(context).validate()) {
              context.read<EventFormBloc>().add(FormSubmitted());
            }
          };
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ElevatedButton(
            onPressed: onPressed,
            child: submitting
                ? const SizedBox( height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit'),
          ),
        );
      },
    );
  }
}
