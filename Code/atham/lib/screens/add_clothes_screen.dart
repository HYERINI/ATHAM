import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atham/providers/user_provider.dart';
import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class AddClothesScreen extends StatefulWidget {
  final Uint8List file;
  const AddClothesScreen({Key? key, required this.file}) : super(key: key);

  @override
  _AddClothesScreenState createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
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
  String selectedSubCategory = "";
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
    } else if (nowString == "스커트") {
      subCategoryList = ["미니 스커트", "미디/롱스커트"];
    } else if (nowString == "트레이닝") {
      subCategoryList = ["트레이닝 세트", "트레이닝 상의", "트레이닝 하의", "레깅스"];
    } else if (nowString == "가방") {
      subCategoryList = ["그로스백", "숄더백", "토트백", "클러치", "에코백", "백팩", "지갑", "파우치"];
    } else if (nowString == "신발") {
      subCategoryList = [
        "블로퍼/뮬",
        "플랫/로퍼",
        "샌들",
        "스니커즈",
        "슬리퍼/쪼리",
        "힐",
        "위커/부츠"
      ];
    } else if (nowString == "패션소품") {
      subCategoryList = [
        "헤어",
        "모자",
        "마스크",
        "양말/스타킹",
        "벨트",
        "시계",
        "머플러/스카프",
        "아이웨어",
        "장갑",
        "기타"
      ];
    } else if (nowString == "홈웨어") {
      subCategoryList = ["세트", "윈피스", "잠옷바지", "로브/가운"];
    } else if (nowString == "주얼리") {
      subCategoryList = ["귀걸이", "목걸이", "반지", "팔찌", "발찌", "보석함"];
    }
  }

  void postClothes(String uid, String username, String profImage,
      String mainCategory, String subCategory, int maxT, int minT) async {
    if (_descriptionController.text.isEmpty ||
        _clothesNameController.text.isEmpty ||
        selectedSubCategory.isEmpty) {
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
          widget.file!,
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
        clearImage();
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
      clearImage();
    }
  }

  void clearImage() {
    setState(() {
      //_file = null;
    });
    Navigator.pop(context);
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text(
          '옷 등록페이지',
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
              "등록하기!",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      // POST FORM
      body: ListView(
        children: <Widget>[
          isLoading
              ? const LinearProgressIndicator()
              : const Padding(padding: EdgeInsets.only(top: 0.0)),
          const Divider(),
          Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                height: 150,
                alignment: Alignment.topCenter,
                child: Image.memory(
                  widget.file,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "옷 이름:",
                      style: GoogleFonts.jua(fontSize: 17),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _clothesNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '옷의 이름은?',
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(7, 0, 7, 0),
                  child: Divider(
                    color: Colors.grey,
                  )),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "옷에 대한 설명: ",
                  style: GoogleFonts.jua(fontSize: 17),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '이 옷에 대해 설명해보세요!',
                  ),
                  maxLines: 4,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Text(
                          "메인 카테고리",
                          style: GoogleFonts.jua(fontSize: 17),
                        )),
                  ),
                  Expanded(
                    flex: 7,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: DropdownButtonHideUnderline(
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
                          ),
                        )),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: Text(
                          "하위 카테고리",
                          style: GoogleFonts.jua(fontSize: 17),
                        )),
                  ),
                  Expanded(
                    flex: 7,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        child: DropdownButtonHideUnderline(
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
                          ),
                        )),
                  ),
                ],
              ),
              const Divider(
                color: Colors.grey,
              ),
              Text(
                "입을 수 있는 온도는?",
                style: GoogleFonts.jua(fontSize: 17),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "최저 기온",
                        style: GoogleFonts.jua(fontSize: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "최고 기온",
                        style: GoogleFonts.jua(fontSize: 14),
                      ),
                    ),
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
                  const Divider(
                    color: Colors.grey,
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
            ],
          ),
        ],
      ),
    );
  }
}
