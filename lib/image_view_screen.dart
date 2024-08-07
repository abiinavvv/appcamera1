import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final String imagePath;
  final Function(String) onDelete; // Callback for delete action

  const ImageViewScreen({
    Key? key,
    required this.imagePath,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topCenter,
          child: Text(
            'View Image',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteImage();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the dialog after deleting
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteImage() {
    final file = File(imagePath);
    if (file.existsSync()) {
      file.deleteSync(); // Delete the image file
      onDelete(imagePath);
    }
  }
}
