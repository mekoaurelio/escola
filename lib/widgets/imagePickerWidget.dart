import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final String imageUrl;
  final bool showCamera;
  final bool showCircular;
  final Function(Uint8List?) onImageSelected;

  const ProfileImagePicker({
    Key? key,
    required this.imageUrl,
    required this.onImageSelected,
    this.showCamera=true,
    this.showCircular=true,
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  XFile? _selectedImage;
  String? _currentImageUrl;  // Store the current imageUrl

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.imageUrl; // Initialize with the initial URL
  }

  Future<void> getImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = fileBytes;
        _selectedImage = pickedFile;
        // Bust cache on Image
         _currentImageUrl = '${widget.imageUrl}?nocache=${DateTime.now().millisecondsSinceEpoch}';
      });
      widget.onImageSelected(_imageBytes);
    } else {
      if (kDebugMode) {
        print('Nenhuma imagem selecionada.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          widget.showCircular?
          CircleAvatar(
            radius: 60,
            backgroundImage: _imageBytes != null
                ? MemoryImage(_imageBytes!)
             : NetworkImage(widget.imageUrl) as ImageProvider,
            backgroundColor: Colors.grey.shade300,
          )
            :
          Container(
            width: 320,  // Largura igual à altura para manter o quadrado
            height: 320,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,  // Cor de fundo se não houver imagem
              borderRadius: BorderRadius.circular(8),  // Borda opcional
              image: _imageBytes != null
                  ? DecorationImage(
                image: MemoryImage(_imageBytes!),
                fit: BoxFit.cover,
              )
                  : DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),


          if(widget.showCamera)
            Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: getImage,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}