import 'package:atham/flutter_flow/flutter_flow_theme.dart';
import 'package:atham/methods/firestore_methods.dart';
import 'package:atham/screens/profile_screen.dart';
import 'package:atham/utils/utils.dart';
import 'package:atham/weather/loading_screen.dart';
import 'package:atham/weather/weather.dart';
import 'package:atham/widgets/for_you_clothes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:atham/utils/colors.dart';
import 'package:atham/utils/global_var.dart';
import 'package:atham/widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TodayMainScreen extends StatefulWidget {
  const TodayMainScreen({Key? key}) : super(key: key);

  @override
  State<TodayMainScreen> createState() => _TodayMainScreenState();
}

class _TodayMainScreenState extends State<TodayMainScreen> {
  List<String> photoUrlList = [];
  List<String> usersNameList = [];
  List<String> likedTImesList = [];

  List<String> musinsaClothesNameList = [];
  List<String> musinsaPhotoUrlList = [];
  List<String> musinsaUrl = [];

  bool isLoading = false;

  //weather Zone
  WeatherModel weather = WeatherModel();
  var weatherData;
  int temperature = 0;
  String weatherText = "";
  String cityName = '';
  String weatherIcon = '';
  String weatherMessage = '';
  int maxTempInt = 0;
  int minTempInt = 0;
  //weather Zone Out

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy("likedTimes", descending: true)
          .limit(3)
          .get();

      for (var i in postSnap.docs) {
        var a = i.data()!;
        photoUrlList.add(a["postUrl"]);
        usersNameList.add(a["username"]);
        likedTImesList.add(a["likedTimes"].toString());
      }

      var rankingSnap = await FirebaseFirestore.instance
          .collection('musinsa')
          .doc("ranking")
          .get();

      var rankingData = rankingSnap.data()!;
      for (int a = 1; a < 4; a++) {
        String nowClothesName = "clothesName" + a.toString();
        musinsaClothesNameList.add(rankingData[nowClothesName]);
        String nowUrlName = "clothesUrl" + a.toString();
        musinsaUrl.add(rankingData[nowUrlName]);
        String nowPhotoName = "clothesPhoto" + a.toString();
        musinsaPhotoUrlList.add(rankingData[nowPhotoName]);
      }

      //weather loading zone
      //weather loading zone
      //weather loading zone
      weatherData = await WeatherModel().getLocationWeather();
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = 'Error';
        weatherMessage = 'Unable to get weather data';
        cityName = '';
        return;
      }

      double temp = weatherData['main']['temp'];
      temperature = temp.toInt();
      double maxTempDouble = weatherData['main']['temp_max'];
      maxTempInt = maxTempDouble.toInt();
      double minTempDouble = weatherData['main']['temp_min'];
      minTempInt = minTempDouble.toInt();
      int condition = weatherData['weather'][0]['id'];
      weatherMessage = weather.getMessage(temperature);
      weatherIcon = weather.getWeatherIcon(condition);
      cityName = weatherData['name'];
      weatherText = weatherData['weather'][0]['main'];

      //weather loading zone Out
      //weather loading zone Out
      //weather loading zone Out

    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: width > webScreenSize
                ? webBackgroundColor
                : mobileBackgroundColor,
            appBar: width > webScreenSize
                ? null
                : AppBar(
                    backgroundColor: mobileBackgroundColor,
                    centerTitle: false,
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/AthamLogo.png',
                          //color: primaryColor,
                          height: 80,
                        ),
                        const VerticalDivider(),
                        Text(
                          "Today",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.person,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                  uid: FirebaseAuth.instance.currentUser!.uid),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    DateFormat.yMMMd().format(
                      DateTime.now(),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                //weather zone
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 190,
                    width: width,
                    child: Column(
                      children: [
                        Padding(
                          // city
                          padding: EdgeInsets.only(bottom: 1),
                          child: Text(
                            cityName.toUpperCase(),
                            style: GoogleFonts.carterOne(
                                fontSize: 40, fontWeight: FontWeight.w400),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 1),
                              child: Text(
                                temperature.toString() + "도",
                                style: GoogleFonts.monoton(fontSize: 40),
                                maxLines: 1,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_up,
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .color,
                                    ),
                                    Text(
                                      maxTempInt.toString() + "도",
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .color,
                                    ),
                                    Text(
                                      minTempInt.toString() + "도",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(),
                            Text(
                              weatherText + weatherIcon,
                              style: GoogleFonts.lato(fontSize: 30),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              weatherMessage,
                              maxLines: 2,
                              style: GoogleFonts.notoSans(fontSize: 15),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                child: Text("지금과 어울리는 옷은?"),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ForYouCLothes(
                                        MaxT: maxTempInt,
                                        MinT: minTempInt,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                //인기 게시물
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        "실시간 게시물 랭킹 Top3",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(),
                      Row(children: [
                        //1st
                        Expanded(flex: 1, child: rankingPost(0)),
                        SizedBox(width: 10),
                        //2nd
                        Expanded(flex: 1, child: rankingPost(1)),
                        SizedBox(width: 10),
                        //3rd
                        Expanded(flex: 1, child: rankingPost(2)),
                      ]),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                //실시간 인기 상품
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text("실시간 인기 Top3 패션",
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(),
                      Row(children: [
                        //1st
                        Expanded(flex: 1, child: rankingClothes(0)),
                        SizedBox(width: 10),
                        //2nd
                        Expanded(flex: 1, child: rankingClothes(1)),
                        SizedBox(width: 10),
                        //3rd
                        Expanded(flex: 1, child: rankingClothes(2)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget rankingPost(int thisIndex) {
    return Column(
      children: [
        Stack(
          children: [
            Image(
              image: NetworkImage(photoUrlList[thisIndex]),
              width: 150,
              fit: BoxFit.fitWidth,
            ),
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text((thisIndex + 1).toString() + "위",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              usersNameList[thisIndex],
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [Icon(Icons.favorite), Text(likedTImesList[thisIndex])],
            )
          ],
        )
      ],
    );
  }

  Widget rankingClothes(int thisIndex) {
    return Column(
      children: [
        Stack(
          children: [
            Image(
              image: NetworkImage(musinsaPhotoUrlList[thisIndex]),
              width: 150,
              fit: BoxFit.fitWidth,
            ),
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text((thisIndex + 1).toString() + "위",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
        Text(
          musinsaClothesNameList[thisIndex],
          maxLines: 3,
        ),
      ],
    );
  }
}
