import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:gift_grab_ui/ui.dart';

import '../../data/constants/label_text.dart';

class GroupFormPage extends StatelessWidget {
  final ShortText name;
  final Function(String) nameChanged;

  final LongText description;
  final Function(String) descriptionChanged;

  final Range? maxCount;
  final Function(double)? maxCountChanged;

  final Toggle open;
  final Function(bool) openChanged;

  final VoidCallback submit;

  const GroupFormPage({
    required this.name,
    required this.nameChanged,
    required this.description,
    required this.descriptionChanged,
    this.maxCount,
    this.maxCountChanged,
    required this.open,
    required this.openChanged,
    required this.submit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(16),
      child: Column(
        children: [
          ShortTextInput(
            name,
            labelText: 'Name',
            onChanged: nameChanged,
          ),
          const Gap(32),
          LongTextInput(
            description,
            labelText: 'Description',
            helperText:
                'Describe your group (${description.value.length}/${LongText.max})',
            onChanged: descriptionChanged,
          ),
          const Gap(32),
          if (maxCount != null && maxCountChanged != null) ...[
            RangeInput(
              maxCount!,
              title: 'Member Limit',
              onChanged: maxCountChanged!,
            ),
            const Gap(32),
          ],
          ToggleInput(
            open,
            title: 'Open Group',
            subtitle: '(Open groups do not require request acceptance)',
            onChanged: openChanged,
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: submit,
              child: const Text(LabelText.submit),
            ),
          ),
        ],
      ),
    );
  }
}
