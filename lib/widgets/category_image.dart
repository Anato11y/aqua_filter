import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class CategoryImage extends StatefulWidget {
  final String imageUrl;
  const CategoryImage({super.key, required this.imageUrl});

  @override
  CategoryImageState createState() => CategoryImageState();
}

class CategoryImageState extends State<CategoryImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        throw Exception("Ошибка загрузки изображения");
      }
    } catch (e) {
      debugPrint("Ошибка загрузки изображения: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    if (_imageBytes == null) {
      return const Icon(Icons.image_not_supported,
          size: 50, color: Colors.grey);
    }
    return Image.memory(_imageBytes!, width: 50, height: 50, fit: BoxFit.cover);
  }
}
