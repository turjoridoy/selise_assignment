import 'package:comment_box/comment/comment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selise_assignment/utils/firebase_crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';

class SingleVideo extends StatefulWidget {
  UserCredential userCredential;
  var Url;
  SingleVideo(this.Url,this.userCredential);

  @override
  _SingleVideoState createState() => _SingleVideoState();
}

class _SingleVideoState extends State<SingleVideo> {

  YoutubePlayerController _controller;
  String uid;
  User user;

  final FirebaseAuth _ath = FirebaseAuth.instance;
  void inputData() {
    user = _ath.currentUser;
    setState(() {
      // userProfile = user.displayName;
      uid = user.uid;
    });
  }

  final Stream<QuerySnapshot> collectionReference = FirebaseCrud.readComment();

  @override
  void initState(){
    inputData();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.Url.toString()),
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
    super.initState();
  }

  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();

  Widget commentChild() {

    return StreamBuilder(
      stream: collectionReference,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {

          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView(
              children: snapshot.data.docs.map((e) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () async {
                        print("Comment Clicked");
                      },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: new BoxDecoration(
                            color: Colors.blue,
                            borderRadius: new BorderRadius.all(Radius.circular(50))),
                        child:Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    title: Text(user.displayName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blue),),
                    subtitle: Text(e["comment"],style: TextStyle(fontSize: 18,color: Colors.black),),
                    trailing: uid == e["userID"] ? GestureDetector(
                      onTap: () async{
                        var response = await FirebaseCrud.deleteComment(docId: e.id);
                        if (response.code != 200) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content:
                                  Text(response.message.toString()),
                                );
                              });
                        }
                      },
                      child: Icon(Icons.delete,color: Colors.red,) ,
                    ):Container(width: 1,),
                  ),
                );
              }).toList(),
            ),
          );
        }

        return Container();
      },
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        child: Column(
          children: [

            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: 300,
            //   child: YoutubePlayer(
            //     controller: _controller,
            //     showVideoProgressIndicator: true,
            //     progressIndicatorColor: Colors.amber,
            //     onReady: () {
            //       print('Player is ready.');
            //     },
            //   ),
            // ),
            SizedBox(height: 20,),
            Text("Comments",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),

            Container(
              height: MediaQuery.of(context).size.height - 450,
              child: CommentBox(
                child: commentChild(),
                labelText: 'Write a comment...',
                errorText: 'Comment cannot be blank',
                withBorder: false,
                sendButtonMethod: () async {
                  if (formKey.currentState.validate()) {
                    var response = await FirebaseCrud.addComment(
                      comment: commentController.text,
                      url: widget.Url,
                      userID: uid,
                      name: user.displayName
                    );
                    if (response.code != 200) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(response.message.toString()),
                            );
                          });
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(response.message.toString()),
                            );
                          });
                    }
                    //fad
                    commentController.clear();
                    FocusScope.of(context).unfocus();

                  } else {
                    print("Not validated");
                  }
                },
                formKey: formKey,
                commentController: commentController,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
