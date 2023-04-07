import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

class HomePage extends StatefulWidget {
  var name;

  HomePage(this.name);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selise"),
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text("Hello ${widget.name}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

            _LogoutButton(
                color: Colors.red,
                text: "Logout",
                onPressed: () async{
                  await GoogleSignIn().signOut();
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login()));
                }),
          ],
        ),
      ),
    );
  }
}


class _LogoutButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onPressed;

  _LogoutButton(
      { this.color,
         this.text,
         this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: GestureDetector(
        onTap:(){
          if(onPressed != null){
            onPressed();
          }
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: TextStyle(color: color, fontSize: 14),
                      ),
                      SizedBox(
                        width: 35,
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
