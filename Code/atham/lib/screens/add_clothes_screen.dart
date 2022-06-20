import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atham/providers/user_provider.dart';
import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({Key? key}) : super(key: key);

  @override
  _AddClothesScreenState createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clothesNameController = TextEditingController();
  final TextEditingController _nowCategoryController = TextEditingController();

  var mainCategoryList = [
    '상의',
    '하의',
    '신발',
  ];

  var selectedMainCategory = "상의";
  var selectedMaxT = 10;
  var selectedMinT = 0;

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('옷 추가하기'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera, 30);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  //Uint8List file = await pickImage(ImageSource.gallery);
                  Uint8List file = await pickImage(ImageSource.gallery, 50);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postClothes(String uid, String username, String profImage,
      String mainCategory, int maxT, int minT) async {
    if (_descriptionController.text.isEmpty ||
        _clothesNameController.text.isEmpty ||
        _nowCategoryController.text.isEmpty) {
      showSnackBar(context, "아직 입력하지 않는 정보가 있습니다!!!");
      return;
    }

    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await fireStoreMethods().uploadClothes(
          _descriptionController.text,
          _file!,
          uid,
          _clothesNameController.text,
          _nowCategoryController.text,
          mainCategory,
          maxT,
          minT);
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
    Navigator.pop(context);
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _clothesNameController.dispose();
    _nowCategoryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file == null
        ? Material(
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.upload,
                ),
                onPressed: () => _selectImage(context),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text(
                'Post to',
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postClothes(
                      userProvider.getUser.uid,
                      userProvider.getUser.username,
                      userProvider.getUser.photoUrl,
                      selectedMainCategory,
                      selectedMaxT,
                      selectedMinT),
                  child: const Text(
                    "Add Clothes",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            // POST FORM
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        userProvider.getUser.photoUrl,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: TextField(
                        controller: _clothesNameController,
                        decoration:
                            const InputDecoration(hintText: "옷 이름을 입력하세요"),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Write a caption..."),
                        maxLines: 3,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: DropdownButton(
                                value: selectedMainCategory,
                                items: mainCategoryList.map((String value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedMainCategory = value!;
                                  });
                                },
                              )),
                        ),
                        Expanded(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: TextField(
                                controller: _nowCategoryController,
                                decoration: const InputDecoration(
                                    hintText: "카테고리를 입력하세요"),
                                maxLines: 1,
                              )),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            child: NumberPicker(
                              value: selectedMinT,
                              minValue: -100,
                              maxValue: 100,
                              step: 1,
                              haptics: true,
                              onChanged: (value) {
                                if (selectedMaxT - value >= 0) {
                                  setState(() {
                                    selectedMinT = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            child: NumberPicker(
                              value: selectedMaxT,
                              minValue: -100,
                              maxValue: 100,
                              step: 1,
                              haptics: true,
                              onChanged: (value) {
                                if (value - selectedMinT >= 0) {
                                  setState(() {
                                    selectedMaxT = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                            image: MemoryImage(_file!),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
