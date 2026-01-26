import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
          GapSizes.xlGap,
          LongTextInput(
            description,
            labelText: 'Description',
            helperText:
                'Describe your group (${description.value.length}/${LongText.max})',
            onChanged: descriptionChanged,
          ),
          GapSizes.xlGap,
          if (maxCount != null && maxCountChanged != null) ...[
            RangeInput(
              maxCount!,
              title: 'Member Limit',
              onChanged: maxCountChanged!,
            ),
            GapSizes.xlGap,
          ],
          ToggleInput(
            open,
            title: 'Open Group',
            subtitle: '(Open groups do not require request acceptance)',
            onChanged: openChanged,
          ),
          const Spacer(),
          Center(
            child: ShadButton(
              onPressed: submit,
              child: const Text(LabelText.submit),
            ),
          ),
        ],
      ),
    );
  }
}
