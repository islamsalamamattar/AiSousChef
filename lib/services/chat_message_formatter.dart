import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'recipe_create_service.dart';

class MessageFormatter {
  static Widget formatMessage(
      BuildContext context, Map<String, dynamic> message, String accessToken) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxMessageWidth = screenWidth * 0.85; // 85% of screen width

    bool containsActionButton = message['role'] == 'assistant' &&
        (message['text'].contains('#') ||
            message['text'].contains('**Ingredients'));

    return Align(
      alignment: message['role'] == 'assistant'
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxMessageWidth),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: message['role'] == 'assistant'
              ? CupertinoColors.systemGrey6
              : CupertinoColors.systemGrey,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message['text'],
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: message['role'] == 'assistant'
                      ? CupertinoColors.black
                      : CupertinoColors.white,
                ),
                h1: TextStyle(
                  color: message['role'] == 'assistant'
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.white,
                ),
                h2: TextStyle(
                  color: message['role'] == 'assistant'
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.white,
                ),
                h3: TextStyle(
                  color: message['role'] == 'assistant'
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.white,
                ),
                h4: TextStyle(
                  color: message['role'] == 'assistant'
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.white,
                ),
                strong: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: message['role'] == 'assistant'
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.white,
                ),
                em: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: message['role'] == 'assistant'
                      ? CupertinoColors.black
                      : CupertinoColors.white,
                ),
              ),
            ),
            if (containsActionButton)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _showSaveDialog(
                          context, message['interaction_id'], accessToken);
                    },
                    child: const Row(
                      children: [
                        Text(
                          "Save Recipe",
                          style: TextStyle(
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                        SizedBox(width: 4.0),
                        Icon(
                          CupertinoIcons.arrow_down_doc_fill,
                          size: 18.0,
                          color: CupertinoColors.systemBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static void _showSaveDialog(
      BuildContext context, String interactionId, String accessToken) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text("Save Recipe"),
          message: Text("Do you want to add this recipe to your favorites?"),
          actions: [
            CupertinoActionSheetAction(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the initial dialog
                _saveRecipe(context, interactionId, accessToken);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text("No"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        );
      },
    );
  }

  static void _saveRecipe(
      BuildContext context, String interactionId, String accessToken) async {
    // Capture the context before starting async operation
    final overlayContext =
        Navigator.of(context, rootNavigator: true).overlay!.context;

    // Show loading dialog
    _showLoadingDialog(overlayContext);

    try {
      final response =
          await RecipeCreateService().createRecipe(accessToken, interactionId);
      // Close loading dialog
      Navigator.of(overlayContext, rootNavigator: true).pop();

      // Show response dialog
      _showResponseDialog(overlayContext, response['status']);
    } catch (e) {
      // Close loading dialog
      Navigator.of(overlayContext, rootNavigator: true).pop();
      // Show error message
      _showResponseDialog(overlayContext, "Error saving recipe.");
    }
  }

  static void _showLoadingDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Saving..."),
          content: CupertinoActivityIndicator(),
        );
      },
    );
  }

  static void _showResponseDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Save Recipe"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Map<String, dynamic> formatReply(Map<String, dynamic> reply) {
    return {
      'role': 'assistant',
      'text': reply['text'],
    };
  }
}
