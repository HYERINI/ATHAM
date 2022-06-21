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

  List<String> mainCategoryList = [
    '상의',
    '아우터',
    '원피스/세트',
    '팬츠',
    '스커트',
    '트레이닝',
    '가방',
    '신발',
    '패션소품',
    '홈웨어',
    '주얼리'  
  ];
  List<String> subCategoryList = [];

  String selectedMainCategory = "상의";
  String selectedSubCategory = "반팔티셔츠";
  var selectedMaxT = 10;
  var selectedMinT = 0;

  void chooseSubList(String? nowString) {
    if (nowString == "상의") {
      subCategoryList = [
        "반팔티셔트",
        "블라우스",
        "셔츠",
        "민소매",
        "니트",
        "조끼",
        "긴팔티셔츠",
        "후드",
        "맨투맨"
      ];
    } else if (nowString == "아우터") {
      subCategoryList = ["가디건", "바람막이", "자켓", "집업/점퍼", "야상", "플리스", "코트", "패딩"];
    } else if (nowString == "원피스/세트") {
      subCategoryList = ["미니원피스", "롱원피스", "투피스", "점프수트"];
    } else if (nowString == "팬츠") {
      subCategoryList = ["롱팬츠", "슬랙스", "데님", "숏팬츠"];
    }else if (nowString == "스커트") {
      subCategoryList = ["미니 스커트", "미디/롱스커트"];
    }else if (nowString == "트레이닝") {
      subCategoryList = ["트레이닝 세트", "트레이닝 상의", "트레이닝 하의", "레깅스"];
    }else if (nowString == "가방") {
      subCategoryList = ["그로스백", "숄더백", "토트백", "클러치", "에코백", "백팩", "지갑", "파우치"];
    }else if (nowString == "신발") {
      subCategoryList = ["블로퍼/뮬", "플랫/로퍼", "샌들", "스니커즈", "슬리퍼/쪼리", "힐", "위커/부츠"];
    }else if (nowString == "패션소품") {
      subCategoryList = ["헤어", "모자", "마스크", "양말/스타킹", "벨트", "시계", "머플러/스카프", "아이웨어", "장갑", "기타"];
    }else if (nowString == "홈웨어") {
      subCategoryList = ["세트", "윈피스", "잠옷바지", "로브/가운"];
    }else if (nowString == "주얼리") {
      subCategoryList = ["귀걸이", "목걸이", "반지", "팔찌", "발찌", "보석함"];
    }
  }

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
      String mainCategory, String subCategory, int maxT, int minT) async {
    if (_descriptionController.text.isEmpty ||
        _clothesNameController.text.isEmpty) {
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
          subCategory,
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
                      selectedSubCategory,
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
                                  chooseSubList(value);
                                  setState(() {
                                    selectedSubCategory = subCategoryList[0];
                                    selectedMainCategory = value!;
                                  });
                                },
                              )),
                        ),
                        Expanded(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              child: DropdownButton(
                                value: selectedSubCategory,
                                items: subCategoryList.map((String value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedSubCategory = value!;
                                  });
                                },
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
