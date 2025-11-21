import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({Key? key}) : super(key: key);

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  bool _uploading = false;
  String _mensagem = '';

  Future<void> _uploadVideo() async {
    setState(() {
      _uploading = true;
      _mensagem = 'selecting_files'.tr;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) {
      setState(() {
        _uploading = false;
        _mensagem = 'canceled_upload'.tr;
      });
      return;
    }

    final file = result.files.single;
    final Uint8List fileBytes = file.bytes!;
    final String fileName = file.name;

    setState(() => _mensagem = 'uploading_to_firebase'.tr);

    try {
      // 1. Upload para Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('videos/$fileName');
      final uploadTask = await storageRef.putData(fileBytes);
      final videoUrl = await uploadTask.ref.getDownloadURL();

      setState(() => _mensagem = 'generating_thumbnail'.tr);

      // 2. Gerar thumbnail
      final Uint8List? thumbnailBytes = await _generateThumbnailFromVideo(fileBytes);
      final String? thumbnailBase64 = thumbnailBytes != null ? base64Encode(thumbnailBytes) : null;

      // 3. Salvar dados no Firestore
      await FirebaseFirestore.instance.collection('tattoo_galeria').add({
        'videoUrl': videoUrl,
        'thumbnail': thumbnailBase64,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _mensagem = 'success'.tr;
        _uploading = false;
      });

    } catch (e) {
      setState(() {
        _mensagem = 'Erro: $e';
        _uploading = false;
      });
    }
  }

  Future<Uint8List?> _generateThumbnailFromVideo(Uint8List videoBytes) async {
    final blob = html.Blob([videoBytes], 'video/mp4');
    final videoUrl = html.Url.createObjectUrlFromBlob(blob);
    final video = html.VideoElement()
      ..src = videoUrl
      ..autoplay = false
      ..muted = true
      ..preload = 'auto'
      ..style.display = 'none';

    html.document.body?.append(video);

    final completer = Completer<Uint8List?>();

    video.onLoadedMetadata.listen((_) async {
      final originalWidth = video.videoWidth!;
      final originalHeight = video.videoHeight!;

      const maxWidth = 480;
      final scale = originalWidth > maxWidth ? maxWidth / originalWidth : 1.0;
      final targetWidth = (originalWidth * scale).round();
      final targetHeight = (originalHeight * scale).round();

      final canvas = html.CanvasElement(width: targetWidth, height: targetHeight);
      final ctx = canvas.context2D;

      video.currentTime = 0;

      await video.onSeeked.first;

      ctx.drawImageScaled(video, 0, 0, targetWidth, targetHeight);

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.9);
      html.Url.revokeObjectUrl(videoUrl);
      video.remove();

      final base64 = dataUrl.split(',').last;
      final bytes = base64Decode(base64);
      completer.complete(bytes);
    });

    video.load();

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: Text('select_and_send_video'.tr),
              onPressed: _uploading ? null : _uploadVideo,
            ),
            const SizedBox(height: 20),
            if (_mensagem.isNotEmpty)
              Text(_mensagem, style: TextStyle(color: _uploading ? Colors.orange : Colors.green)),
            if (_uploading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
