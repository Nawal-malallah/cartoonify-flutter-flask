import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class CartoonifyPage extends StatefulWidget {
  @override
  _CartoonifyPageState createState() => _CartoonifyPageState();
}

class _CartoonifyPageState extends State<CartoonifyPage> {
  File? _image;
  File? _cartoonImage;
  bool _loading = false;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _cartoonImage = null;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    setState(() => _loading = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.6:5000/cartoonify'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
final dir = await getTemporaryDirectory();

// 🧹 مسح كل الملفات المؤقتة باستثناء الملف اللي هنستخدمه
await for (var entity in dir.list()) {
  try {
    if (entity is File && !entity.path.endsWith('cartoon.jpg')) {
      await entity.delete();
    }
  } catch (e) {
    print('⚠️ Skipping delete: $e');
  }
}

// 💾 حفظ الصورة الجديدة
final file = File('${dir.path}/cartoon.jpg');
await file.writeAsBytes(bytes);

setState(() {
  _cartoonImage = file;
});

    } else {
      print('❌ Failed to get cartoon image');
    }

    setState(() => _loading = false);
  }

  Future<void> saveCartoonToDownloads() async {
    if (_cartoonImage == null) return;

    // 1. Request permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Permission denied to write file")),
      );
      return;
    }

    // 2. Create file name with timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final newFileName = "cartoon_$timestamp.jpg";

    // 3. Get external directory within app sandbox
    final directory = await getExternalStorageDirectory();
    final newPath = '${directory!.path}/$newFileName';

    try {
      final newFile = await _cartoonImage!.copy(newPath);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Saved to: ${newFile.path}')));
    } catch (e) {
      print("❌ Error saving file: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to save image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("🎨 Cartoonify Image"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _image == null
                    ? Column(
                      children: [
                        Icon(Icons.image, size: 100, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "No image selected.",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!, height: 250),
                    ),

                SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.photo_library),
                  label: Text("Pick Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      0,
                      0,
                      0,
                    ), // ← هنا اللون بيتحدد
                    minimumSize: Size(double.infinity, 50),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),

                if (_image != null) ...[
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: uploadImage,
                    icon: Icon(Icons.auto_fix_high),
                    label: Text("Convert to Cartoon"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],

                if (_loading) ...[
                  SizedBox(height: 30),
                  CircularProgressIndicator(),
                ],

                if (_cartoonImage != null) ...[
                  SizedBox(height: 30),
                  Text(
                    "🖼️ Cartoon Image",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_cartoonImage!, height: 400),
                  ),
                  SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: saveCartoonToDownloads,
                    icon: Icon(Icons.download),
                    label: Text("Download Cartoon"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
