import 'dart:ui';
import 'package:selise_assignment/login/single_video.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String api_key = "AIzaSyAaATaZ1TE5aeCFY4SWx6p70KWWQVL5K1M";
  List<YT_API> results = [];
  YoutubeAPI yt = YoutubeAPI(api_key, maxResults: 12, type: "video");
  bool isLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    callApi();
  }
  UserCredential userCredential;

  callApi() async {
    GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleAuth = await googleUser?.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken
    );
    userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    try {
      results = await yt.search("HD Music");
      print(results);
      setState(() {
        isLoaded = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Selise",
            style: TextStyle(color: Colors.black, fontFamily: "Poppins"),
          ),
          centerTitle: true,
          leading: Icon(
            FeatherIcons.youtube,
            color: Colors.grey,
            size: 28,
          ),
          actions: [
            IconButton(
              onPressed: () async{
                await GoogleSignIn().signOut();
                FirebaseAuth.instance.signOut();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login()));
              },
              icon: Icon(Icons.logout,color: Colors.red,),
            ),
          ],
        ),
        body: isLoaded
            ? ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                String url = results[index].url;
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleVideo(url,userCredential)));
                // if (await canLaunch(url)) {
                //   await launch(url);
                // } else {
                //   throw 'Could not launch $url';
                // }
              },
              child: (Container(
                padding: EdgeInsets.only(left: 15,right: 15),
                margin: EdgeInsets.only(top: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    index == 0
                        ? Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15,),
                          Text("Hello ${userCredential.user.displayName}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.red),),
                          SizedBox(height: 20,),
                          Row(
                            children: [
                              Text(
                                "TOP TRENDING",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins"),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.whatshot,
                                color: Colors.red,
                                size: 18,
                              )
                            ],
                          ),
                        ],
                      ),
                    ) : Container(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 10),
                                  blurRadius: 15,
                                  color: index == 0
                                      ? Colors.red[50]
                                      : Color.fromRGBO(0, 0, 0, 0.09))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              child: Image.network(
                                results[index].thumbnail['medium']["url"],
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      results[index].channelTitle,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Poppins"),
                                    ),
                                  ),
                                  Text(
                                    results[index].duration,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins"),
                                    textAlign: TextAlign.justify,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              )),
            );
          },
          itemCount: results.length,
        )
            : Center(
          child: SleekCircularSlider(
            appearance: CircularSliderAppearance(
              spinnerMode: true,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
