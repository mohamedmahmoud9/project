import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:journey_app/models/event.dart';
import 'package:journey_app/models/user.dart';
import 'package:journey_app/screens/add_event_screen.dart';
import 'package:journey_app/screens/profile_screen.dart';
import 'package:journey_app/screens/user_on_map_screen.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'package:toast/toast.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Event> events = [];
  String title;
  UserModel user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:Text('Events') ,
            bottom: PreferredSize(child: TextField(onChanged: (String value){
              setState(() {
                this.title = value;
              });
            },decoration: InputDecoration(hintText: 'Enter title',fillColor: Colors.white,filled: true),), preferredSize: Size(0,50)),
          actions: [
            FlatButton(
              child: Text('Joined'),
              textColor: Colors.white,
              onPressed: () {
                List<Event> userEvent = [];
                events.forEach((element) {
                  if (element.usersInEvent.contains(auth.currentUser.uid)) {
                    userEvent.add(element);
                  }
                });
                showDialog(
                    context: context,
                    child: Scaffold(
                        appBar: AppBar(
                          title: Text(
                            'Joined Events',
                          ),
                          elevation: 0,
                        ),
                        body: ListView.builder(
                            itemCount: userEvent.length,
                            itemBuilder: (context, i) => EventTile(
                                  auth: auth,
                                  events: userEvent,
                                  event: userEvent[i],
                                ))));
              },
            )
          ],
        ),
        floatingActionButton: RaisedButton.icon(
          label:Text('Post'),
          icon: Icon(Icons.add),
          onPressed: () async{
            UserModel currentuser = await FirestoreDatabase().getCurrentUser();
            if(currentuser.auth){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (
                      context,
                      ) =>
                      AddEventScreen()));

            }else{
              Toast.show('You are not Authinticated', context);
            }
          },
        ),
        body: StreamBuilder(
          stream: FirestoreDatabase().getAllEvents(),
          builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            events = snapshot.data;

            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) {


                if(title!=null){
                  if(snapshot.data[i].title.toLowerCase().contains(title.toLowerCase())){
                    return EventTile(
                        event: snapshot.data[i], auth: auth, events: snapshot.data);
                  }
                  else{
                    return ListTile();

                  }
                }
                else{
                  return EventTile(
                      event: snapshot.data[i], auth: auth, events: snapshot.data);
                }


              } );
          },
        ));
  }
  void getuser(String id)async{
    this.user =  await FirestoreDatabase().getUserById(id);
  }
}

class EventTile extends StatelessWidget {
   EventTile({
    Key key,
    @required this.auth,
    this.event,
    this.events,
  }) : super(key: key);
  final FirebaseAuth auth;
  final Event event;
  final List<Event> events;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          if (event.userId == auth.currentUser.uid)
            Row(
              children: [
                FutureBuilder<UserModel>(future: FirestoreDatabase().getUserById(event.userId), builder: (context,snapshot){
                  if(snapshot.data == null){
                    return Container();
                  }
                if(event.userId == snapshot.data.uid){
                return CircleAvatar(backgroundImage: NetworkImage(snapshot.data.profilePic),);
                }else{
                return CircleAvatar(backgroundImage: NetworkImage(snapshot.data.profilePic),);
                }
                },),
                SizedBox(width: 5,),
                FutureBuilder<UserModel>(future: FirestoreDatabase().getUserById(event.userId), builder: (context,snapshot){
                  if(snapshot.data == null){
                    return Container();
                  }
                  if(snapshot.data.auth)
                  return Icon(Icons.verified_rounded,color: Colors.orange,);
                  return Icon(Icons.person,color: Colors.orange,);
                },),

                SizedBox(width: 5,),
                Text('Organizer: \n'+event.orgnaizer,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),),
                Spacer(),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                  onPressed: () {
                    try {
                      FirestoreDatabase().delEvent(event);
                      Toast.show('Event Deleted!', context);
                    } catch (e) {
                      Toast.show('Something went wrong', context);
                    }
                  },
                ),
              ],
            ),
          if(event.userId !=auth.currentUser.uid)
          Row(
            children: [
              Flexible(
                child: FutureBuilder<UserModel>(future: FirestoreDatabase().getUserById(event.userId), builder: (context,snapshot){
                  if(snapshot.data == null){
                    return CircularProgressIndicator();
                  }
                  if(event.userId == snapshot.data.uid){
                    return CircleAvatar(backgroundImage: NetworkImage(snapshot.data.profilePic),);
                  }else{
                    return CircleAvatar(backgroundImage: NetworkImage(snapshot.data.profilePic),);
                  }
                },),
              ),
              SizedBox(width: 5,),
              Icon(Icons.verified_rounded,color: Colors.orange,),
              SizedBox(width: 5,),
              Text('Organizer: \n'+event.orgnaizer,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),),
            ],
          ),
          ListTile(
            title: Text(event.title),
            subtitle: Text(event.description),
            trailing: RaisedButton.icon(
              icon: Icon(Icons.person),
                onPressed: () {
                  showDialog(
                      context: context,
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text(
                            'Participants',
                          ),

                          elevation: 0,
                          // backgroundColor: Theme.of(context)
                          //     .scaffoldBackgroundColor,
                        ),
                        body: StreamBuilder(
                          stream: FirestoreDatabase().getAllUsers(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<UserModel>> userssnap) {
                            if (userssnap.connectionState ==
                                ConnectionState.none) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if(userssnap.data == null)
                              return Container();
                            List<UserModel> usersFiltered = userssnap.data
                                .where((element) =>
                                    event.usersInEvent.contains(element.uid))
                                .toList();
                            usersFiltered = List.from(usersFiltered.reversed);

                            return ListView.builder(
                                itemCount: usersFiltered.length,
                                itemBuilder: (context, i) {
                                  if(usersFiltered[i].uid == event.userId){
                                    if(usersFiltered[i].auth){
                                      return ListTile(
                                          onTap: () async {
                                            final user =
                                            await FirestoreDatabase().getUserById(event.userId);
                                            Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => ProfileScreen(userModel: user)));
                                          },
                                          trailing: Icon(Icons.verified,color: Colors.orange,),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                usersFiltered[i].profilePic),
                                          ),
                                          subtitle:
                                          Text('Leader'),
                                          title: Text(
                                              '${usersFiltered[i].firstname} ${usersFiltered[i].lastname}'));
                                    }else{
                                      return ListTile(
                                          onTap: () async {
                                            final user =
                                            await FirestoreDatabase().getUserById(event.userId);
                                            Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => ProfileScreen(userModel: user)));
                                          },
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                usersFiltered[i].profilePic),
                                          ),
                                          subtitle:
                                          Text('Leader'),
                                          title: Text(
                                              '${usersFiltered[i].firstname} ${usersFiltered[i].lastname}'));
                                    }

                                  }
                                  else{
                                    return ListTile(
                                        onTap: () async {
                                          final user =
                                          await FirestoreDatabase().getUserById(usersFiltered[i].uid);
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => ProfileScreen(userModel: user)));
                                        },
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              usersFiltered[i].profilePic),
                                        ),
                                        subtitle:
                                        Text('Member'),
                                        title: Text(
                                            '${usersFiltered[i].firstname} ${usersFiltered[i].lastname}'));
                                  }

                                });

                          },
                        ),
                      ));
                },
                label: Text('Participants: ${event.usersInEvent.length}')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Chip(
                backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                  label:
                      Text('${DateFormat.yMMMEd().add_jm().format(event.startDate)}'),labelStyle: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold),),
              Text(
                'To',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Chip(shape: RoundedRectangleBorder(),
                backgroundColor: Colors.white,
                label: Text('${DateFormat.yMMMEd().add_jm().format(event.endDate)}'),
                labelStyle: TextStyle(fontSize: 13,color: Colors.black),)
            ],
          ),
          Image.network(
            event.image,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserOnMapScreen(
                            geoPoint: event.geoPoint,
                            appBarTitle: event.title)));
                  },
                  icon: Icon(Icons.location_on_outlined),
                  label: Text('Location')),
              if (event.userId != auth.currentUser.uid)
                RaisedButton.icon(
                    onPressed: () async {
                      await FirestoreDatabase().joinEvent(event);
                      Toast.show('Done!', context);
                    },
                    icon: Icon(event.usersInEvent.contains(auth.currentUser.uid)
                        ? Icons.remove
                        : Icons.add),
                    label: Text(
                        event.usersInEvent.contains(auth.currentUser.uid)
                            ? 'Leave Event'
                            : 'Join Event')),
              RaisedButton.icon(
                  onPressed: () async {
                    final user =
                        await FirestoreDatabase().getUserById(event.userId);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileScreen(userModel: user)));
                  },
                  icon: Icon(Icons.person),
                  label: Text('Organizer'))
            ],
          )
        ],
      ),
    );
  }
}
