import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

Future<void> uploadTattooImage() async {
  // Inicializa o Firebase (se ainda não estiver inicializado)
  await Firebase.initializeApp();

  // 1. Seleciona a imagem do computador
  final ImagePicker picker = ImagePicker();
  final XFile? imageFile = await picker.pickImage(
    source: ImageSource.gallery,  // Ou ImageSource.camera para câmera
  );

  if (imageFile == null) {
    print("Nenhuma imagem selecionada.");
    return;
  }

  try {
    // 2. Converte XFile para File (necessário para o Firebase Storage Web)
    final File file = File(imageFile.path);
    print('2');

    // 3. Referência do Firebase Storage (caminho onde a imagem será salva)
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('tattoo_galeria/${DateTime.now().millisecondsSinceEpoch}.jpg');

    print('3');
    // 4. Faz o upload da imagem
    final UploadTask uploadTask = storageRef.putFile(file);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

    print('4');
    // 5. Obtém a URL pública da imagem
    final String imageUrl = await snapshot.ref.getDownloadURL();

    // 6. Salva a URL no Firestore (coleção 'tattoo_galeria')
    await FirebaseFirestore.instance.collection('tattoo_galeria').add({
      'imageUrl': imageUrl,
      'uploadDate': DateTime.now(),
      'likes': 0,  // Exemplo de campo adicional
    });

    print("Imagem enviada com sucesso! URL: $imageUrl");
  } catch (e) {
    print("Erro ao enviar imagem: $e");
  }
}

// Widget de exemplo para chamar a função
class TattooUploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: uploadTattooImage,
      child: Text("Enviar Tatuagem"),
    );
  }
}