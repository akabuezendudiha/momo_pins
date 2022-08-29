import 'package:flutter/material.dart';

Future<String?> showSingleEntryTextDialog(
    {required BuildContext context, required String title, required String hint, required String prevValue, TextInputType keyboardType = TextInputType.phone}) async {
  TextEditingController controller = TextEditingController(text: prevValue);

  return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: TextField(
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  icon: const Icon(Icons.phone),
                  hintText: hint,
                ),
                controller: controller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text(
                        'Save',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SimpleDialogOption(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      });
}
