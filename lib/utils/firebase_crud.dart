import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('videos');
class FirebaseCrud {

  static Future<Response> addComment({
     String comment,
     String url,
     String userID,
     String name,
  }) async {

    Response response = Response();
    DocumentReference documentReferencer =
    _Collection.doc();

    Map<String, dynamic> data = <String, dynamic>{
      "comment": comment,
      "url": url,
      "name": name,
      "userID" : userID
    };

    var result = await documentReferencer
        .set(data)
        .whenComplete(() {
      response.code = 200;
      response.message = "Sucessfully added to the database";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Stream<QuerySnapshot> readComment() {
    CollectionReference notesItemCollection =
        _Collection;

    return notesItemCollection.snapshots();
  }
  static Future<Response> updateComment({
     String comment,
     String url,
     String userID,
     String name,
     String docId,
  }) async {
    Response response = Response();
    DocumentReference documentReferencer =
    _Collection.doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "comment": comment,
      "url": url,
      "name": name,
      "userID" : userID
    };

    await documentReferencer
        .update(data)
        .whenComplete(() {
      response.code = 200;
      response.message = "Sucessfully updated Comment";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Future<Response> deleteComment({
    String docId,
  }) async {
    Response response = Response();
    DocumentReference documentReferencer =
    _Collection.doc(docId);

    await documentReferencer
        .delete()
        .whenComplete((){
      response.code = 200;
      response.message = "Sucessfully Deleted Comment";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }
}