import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'image_view_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<FileSystemEntity> _images = [];
  final List<FileSystemEntity> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final myDir = Directory(path);

    setState(() {
      _images =
          myDir.listSync().where((item) => item.path.endsWith(".png")).toList();
    });
  }

  Future<void> _deleteImages() async {
    for (var image in _selectedImages) {
      await image.delete();
    }
    _selectedImages.clear();
    _loadImages(); // Refresh the image list after deleting
    Navigator.pop(context); // Close the box after deleting
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete the selected images?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the box without deleting
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteImages();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (_selectedImages.isNotEmpty) {
                _confirmDelete(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No images selected')),
                );
              }
            },
          ),
        ],
      ),
      body: _images.isEmpty
          ? const Center(
              child: Text(
                "no image available",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                childAspectRatio: 1,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewScreen(
                          imagePath: _images[index].path,
                          onDelete: (String deletedPath) {
                            setState(() {
                              // Remove the deleted image from the list
                              _images.removeWhere(
                                  (image) => image.path == deletedPath);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: GridTile(
                    footer: Checkbox(
                      value: _selectedImages.contains(_images[index]),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedImages.add(_images[index]);
                          } else {
                            _selectedImages.remove(_images[index]);
                          }
                        });
                      },
                    ),
                    child: Image.file(
                      File(_images[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
