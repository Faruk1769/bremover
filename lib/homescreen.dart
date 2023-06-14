// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_unnecessary_containers, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:before_after_image_slider_nullsafty/before_after_image_slider_nullsafty.dart';
import 'package:bremover/api.dart';
import 'package:bremover/dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var loaded = false;
  //var imgPicked = false;
  var removedbg = false;
  var isloading = false;

  Uint8List? image;
  String imagePath = '';

  ScreenshotController screenshotController = ScreenshotController();

  pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (img != null) {
      imagePath = img.path;
      //imgPicked = true;
      loaded = true;
      setState(() {});
    } else {}
  }

  downloadImage() async {
    var perm = await Permission.storage.request();

    var foldername = "BGRemover";
    var filename = "${DateTime.now().millisecondsSinceEpoch}.png";

    if (perm.isGranted) {
      final directory = Directory("storage/emulated/0/");

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await screenshotController.captureAndSave(directory.path,
          delay: const Duration(milliseconds: 100),
          fileName: filename,
          pixelRatio: 1.0);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloaded to ${directory.path}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              downloadImage();
            },
            icon: const Icon(Icons.download),
          ),
        ],
        leading: const Icon(Icons.sort_rounded),
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          "AI Background Remover",
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: Center(
        child: removedbg
            ? BeforeAfter(
                beforeImage: Image.file(File(imagePath)),
                afterImage: Screenshot(
                    controller: screenshotController,
                    child: Image.memory(image!)))
            : loaded
                ? GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Image.file(
                      File(imagePath),
                    ),
                  )
                : DashedBorder(
                    padding: EdgeInsets.all(40),
                    color: Colors.grey,
                    radius: 12,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            pickImage();
                          },
                          child: Text("Remove Background")),
                    )),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: loaded
              ? () async {
                  setState(() {
                    isloading = true;
                  });
                  image = await Api.removebg(imagePath);
                  if (image != null) {
                    removedbg = true;
                    isloading = false;
                    setState(() {});
                  }
                }
              : null,
          child: isloading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              : const Text("Remove Background"),
        ),
      ),
    );
  }
}
