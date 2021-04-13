import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journey_app/models/post.dart';
import 'package:journey_app/screens/add_new_post.dart';
import 'package:journey_app/screens/chat_screen.dart';
import '../services/firestore_database.dart';
import '../models/user.dart';
import 'uncomplete_profile_screen.dart';
import 'user_on_map_screen.dart';
import 'package:toast/toast.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;

  ProfileScreen({Key key, @required this.userModel}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final TextEditingController textEditingController = TextEditingController();
  // UserModel currentUser;
  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();

  //   currentUser = await FirestoreDatabase().getCurrentUser();
  // }
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.userModel.uid == firebaseAuth.currentUser.uid
          ? RaisedButton.icon(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddNewPostScreen()));
        },
        label: Text('Post'),
      icon: Icon(Icons.add),

            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Profile'),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder(
        future: FirestoreDatabase().getCurrentUser(),
        builder: (context, AsyncSnapshot<UserModel> snapshot) => !snapshot
                .hasData
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage:
                            NetworkImage(widget.userModel.profilePic),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    if(widget.userModel.auth)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          '${widget.userModel.firstname} ${widget.userModel.lastname}',
                          style:
                              TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 10,),
                        Icon(Icons.verified,color: Colors.orange,),
                      ],
                    ),
                    if(!widget.userModel.auth)
                          Text(
                            '${widget.userModel.firstname} ${widget.userModel.lastname}',
                            style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    if(widget.userModel.uid == firebaseAuth.currentUser.uid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_android,color: Colors.green,),
                        SizedBox(width: 5,),
                        Text(widget.userModel.phonenumber),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if(widget.userModel.status == '1')
                    Text('Off Trip',style: TextStyle(color: Colors.green),),
                    if(widget.userModel.status !='1')
                      Text('On Trip',style: TextStyle(color: Colors.red,),),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      '${widget.userModel.gender}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    if(FirebaseAuth.instance.currentUser.uid == widget.userModel.uid)
                         OutlineButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UnCompleteProfileScreen(
                                        userModel: widget.userModel,
                                        firbaseAuth: firebaseAuth,
                                        isEdit: true,
                                      )));
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Edit You Info')),
                    if(!(firebaseAuth.currentUser.uid == widget.userModel.uid))
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              snapshot.data.following
                                      .contains(widget.userModel.uid)
                                  ? RaisedButton.icon(
                                      onPressed: () {
                                        try {
                                          setState(() {
                                            snapshot.data.following
                                                .remove(widget.userModel.uid);
                                          });
                                          FirestoreDatabase()
                                              .addUserToFirestore(
                                                  snapshot.data, null);
                                          Toast.show(
                                              'You unfollowing ${widget.userModel.firstname} now',
                                              context);
                                        } catch (e) {
                                          Toast.show(
                                              'Something went wrong, try again later!',
                                              context);
                                        }
                                      },
                                      icon: Icon(Icons.person_add_outlined),
                                      label: Text('UnFollow'))
                                  : OutlineButton.icon(
                                      onPressed: () {
                                        try {
                                          if (snapshot.data.following == null) {
                                            setState(() {
                                              snapshot.data.following = [
                                                widget.userModel.uid
                                              ];
                                            });
                                            FirestoreDatabase()
                                                .addUserToFirestore(
                                                    widget.userModel, null);
                                          } else {
                                            setState(() {
                                              snapshot.data.following
                                                  .add(widget.userModel.uid);
                                            });
                                            FirestoreDatabase()
                                                .addUserToFirestore(
                                                    snapshot.data, null);
                                            Toast.show(
                                                'You Following ${widget.userModel.firstname} now',
                                                context);
                                          }
                                        } catch (e) {
                                          Toast.show(
                                              'Something went wrong, try again later!',
                                              context);
                                        }
                                      },
                                      icon: Icon(Icons.person_add_outlined),
                                      label: Text('Follow')),
                              RaisedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserOnMapScreen(
                                                  geoPoint: widget
                                                      .userModel.locationLatLng,
                                                  appBarTitle: widget
                                                          .userModel.firstname +
                                                      widget.userModel.lastname,
                                                )));
                                  },
                                  icon: Icon(Icons.location_on_outlined),
                                  label: Text('Location')),
                              RaisedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                                  userModel: widget.userModel,
                                                )));
                                  },
                                  icon: Icon(Icons.message),
                                  label: Text('Message')),
                            ],
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    if (firebaseAuth.currentUser.uid == widget.userModel.uid)
                      OutlineButton.icon(
                          onPressed: () async {
                            await firebaseAuth.signOut();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => MyApp()));
                          },
                          icon: Icon(Icons.logout),
                          label: Text('Log out')),
                    StreamBuilder(
                      stream: FirestoreDatabase()
                          .getUserPosts(widget.userModel.uid),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Post>> postsSnap) {
                        if (postsSnap.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Container(),
                          );
                        }
                        return Column(
                            children: postsSnap.data
                                .map((e) => Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    widget
                                                        .userModel.profilePic),
                                              ),
                                              title: Text(widget
                                                      .userModel.firstname +
                                                  " " +
                                                  widget.userModel.lastname),
                                              subtitle: Text(
                                                  '${DateFormat.yMMMEd().format(e.dateTime)}'),
                                            ),
                                            Text(
                                              e.body,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (e.image.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 16),
                                                child: Image.network(
                                                  e.image,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList());
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
