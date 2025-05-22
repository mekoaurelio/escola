import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadManager {
  final String uploadURL;
  final Dio _dio;
  final String fileName;

  UploadManager(
      {
        required this.uploadURL,
        required this.fileName,
      }) : _dio = Dio();

  /// Realiza o upload da imagem [image] utilizando o método adequado
  /// dependendo da plataforma (web ou mobile/desktop).
  Future<Response> uploadImage({
    required XFile image,
    Function(double progress)? onProgress,
  }) async {
    MultipartFile multipartFile;

    if (kIsWeb) {
      // Na web, lemos os bytes e criamos o MultipartFile a partir deles.
      final bytes = await image.readAsBytes();
      multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );
    } else {
      // Em mobile/desktop, podemos utilizar o caminho do arquivo.
      multipartFile = await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      );
    }

    FormData formData = FormData.fromMap({
      "image": multipartFile,
    });

    Response response = await _dio.post(
      uploadURL,
      data: formData,
      onSendProgress: (int sent, int total) {
        if (total != 0 && onProgress != null) {
          onProgress(sent / total);
        }
      },
    );
    return response;
  }

  /// Inicia o upload da imagem, notificando o progresso e o resultado por callbacks.
  Future<void> startUpload({
    required XFile image,
    required void Function(double progress) onProgress,
    required void Function(bool success, String message) onCompleted,
  }) async {
    try {
      Response response = await uploadImage(
        image: image,
        onProgress: onProgress,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.data);
        String filePath = data["filePath"] ?? "Caminho";
        onCompleted(true, filePath);
      } else {
        onCompleted(false, 'Falha no upload!');
      }
    } catch (e) {
      onCompleted(false, 'Erro ao enviar imagem: $e');
    }
  }

}
