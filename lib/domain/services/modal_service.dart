import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ModalService {
  void shadToast(
    BuildContext context, {
    Widget? title,
    Widget? child,
    Function()? onPressed,
  }) =>
      ShadToaster.of(context).show(
        ShadToast(
          title: title,
          action: ShadButton.outline(child: child, onPressed: onPressed),
        ),
      );

  void shadToastDestructive(
    BuildContext context, {
    Widget? title,
    Widget? description,
    Widget? child,
    Function()? onPressed,
  }) =>
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: title,
          description: description,
          action: ShadButton.outline(
            child: child,
            decoration: ShadDecoration(
              border: ShadBorder.all(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            onPressed: onPressed,
          ),
        ),
      );

  Future<bool?> shadConfirmationDialog(
    BuildContext context, {
    Widget? title,
    Widget? description,
  }) =>
      showShadDialog(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: title,
          description: description,
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ShadButton(
              child: const Text('Continue'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
}
