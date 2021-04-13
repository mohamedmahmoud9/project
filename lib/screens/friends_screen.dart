import 'package:flutter/material.dart';
import 'profile_screen.dart';
import '../services/firestore_database.dart';
import '../models/user.dart';

class FriendsScreen extends StatelessWidget {
  final FirestoreDatabase firestoreDatabase = FirestoreDatabase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Friends"),
      ),
      body: FutureBuilder(
        future: firestoreDatabase.getCurrentUser(),
        builder: (BuildContext context,
            AsyncSnapshot<UserModel> currentUserSnapshot) {
          if (!currentUserSnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder(
            stream: firestoreDatabase.getAllUsers(),
            builder: (BuildContext context,
                AsyncSnapshot<List<UserModel>> allUsersSnapshot) {
              if (allUsersSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final userFirends = allUsersSnapshot.data
                    .where((element) => currentUserSnapshot.data.following
                        .contains(element.uid))
                    .toList();
                return ListView.builder(
                  itemCount: userFirends.length,
                    itemBuilder: (context, i) {
                      if (userFirends[i].auth) {
                        return ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(userFirends[i].profilePic)),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(userModel: userFirends[i]))),
                          title: Row(
                            children: [
                              Icon(Icons.verified,color: Colors.orange,),
                              SizedBox(width: 4,),
                              Text(
                                  '${userFirends[i].firstname} ${userFirends[i].lastname}'),
                            ],
                          ),
                        );
                      } else {
                        return ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(userFirends[i].profilePic)),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ProfileScreen(userModel: userFirends[i]))),
                          title: Row(
                            children: [
                              Icon(Icons.person,color: Colors.orange,),
                              SizedBox(width: 4,),
                              Text(
                                  '${userFirends[i].firstname} ${userFirends[i].lastname}'),
                            ],
                          ),
                        );
                      }
                    }
                );
              }
            },
          );
        },
      ),
    );
  }
}
