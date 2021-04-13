import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journey_app/models/message.dart';
import 'package:journey_app/models/user.dart';
import 'package:journey_app/services/firestore_database.dart';

class ChatScreen extends StatelessWidget {
  final UserModel userModel;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TextEditingController textEditingController = TextEditingController();
  ChatScreen({Key key, @required this.userModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userModel.firstname + " " + userModel.lastname),
      ),
      body: StreamBuilder(
        stream: FirestoreDatabase().getChat(userModel.uid),
        builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          snapshot.data.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    reverse: true,
                    itemBuilder: (context, i) => buildMessage(snapshot.data[i],
                        snapshot.data[i].from == firebaseAuth.currentUser.uid)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: textEditingController,
                    )),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (textEditingController.text.isEmpty) {
                          return;
                        }
                        FirestoreDatabase().addMessage(
                            Message(
                                from: firebaseAuth.currentUser.uid,
                                dateTime: DateTime.now(),
                                to: userModel.uid,
                                message: textEditingController.text,
                                id: ''),
                            userModel.uid);
                         textEditingController.clear();   
                      },
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildMessage(Message snapshot, bool isFrom) {
    return Row(
      mainAxisAlignment:
          isFrom ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment:
                  isFrom ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.message,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormat.yMMMEd().add_jms().format(snapshot.dateTime),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
