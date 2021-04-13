import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journey_app/models/product.dart';
import 'package:journey_app/models/user.dart';

import 'package:journey_app/screens/product_details.dart';
import 'package:journey_app/screens/profile_screen.dart';
import 'package:journey_app/screens/user_on_map_screen.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'package:toast/toast.dart';

import 'add_product_screen.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String title;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Product> userProducts = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Market'),
          bottom: PreferredSize(child: TextField(onChanged: (String value){
            setState(() {
              this.title = value;
            });
          },decoration: InputDecoration(hintText: 'Enter title',fillColor: Colors.white,filled: true),), preferredSize: Size(0,50)),
          actions: [
            FlatButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text('My Products'),
                        ),
                        body: ListView.builder(
                            itemCount: userProducts.length,
                            itemBuilder: (context, i) => ListTile(
                                  title: Text(userProducts[i].title),
                                  subtitle: Text(userProducts[i].description),
                                  trailing: Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OutlineButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProducDetails(
                                                            product:
                                                                userProducts[
                                                                    i])));
                                          },
                                          child: Text('Details'),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Theme.of(context).errorColor,
                                          ),
                                          onPressed: () async {
                                            try {
                                              await FirestoreDatabase()
                                                  .delProduct(userProducts[i]);
                                              Toast.show(
                                                  'Product Deleted!', context);
                                              Navigator.of(context).pop();
                                            } catch (e) {
                                              Toast.show('Something went wrong',
                                                  context);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                      ));
                },
                child: Text('My Products'),
                textColor: Colors.white)
          ],

        ),
        floatingActionButton: RaisedButton.icon(
          label: Text('Post'),
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (
              context,
            ) =>
                    AddProductScreen()));
          },
        ),
        body: StreamBuilder(
          stream: FirestoreDatabase().getAllProducts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            userProducts = snapshot.data
                .where((element) => element.userId == auth.currentUser.uid)
                .toList();
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  if(title !=null && title !=''){
                    if(snapshot.data[i].title.toLowerCase().contains(title.toLowerCase())){
                      return Card(
                        child: Column(
                          children: [
                            FutureBuilder<UserModel>(future: FirestoreDatabase().getUserById(snapshot.data[i].userId),builder: (context,user){
                              if(user.data == null)
                                return  CircularProgressIndicator();;
                            return Row(
                              children: [
                                CircleAvatar(backgroundImage: NetworkImage(user.data.profilePic),),
                                SizedBox(width: 5,),
                                Icon(Icons.verified,color: Colors.orange,),
                                SizedBox(width: 5,),
                                Text('Seller:\n'+user.data.firstname+' '+user.data.lastname,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange),),
                                Spacer(),
                                if (snapshot.data[i].userId == auth.currentUser.uid)

                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(context).errorColor,
                                    ),
                                    onPressed: () {
                                      try {
                                        FirestoreDatabase()
                                            .delProduct(snapshot.data[i]);
                                        Toast.show('Product Deleted!', context);
                                      } catch (e) {
                                        Toast.show('Something went wrong', context);
                                      }
                                    },
                                  ),
                              ],
                            );
                            }),

                            ListTile(
                              title: Text(snapshot.data[i].title),
                              subtitle: Text(snapshot.data[i].description),
                              trailing: Text("Price : ${snapshot.data[i].price}\$"),
                            ),
                            Image.network(
                              snapshot.data[i].image,
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
                                              geoPoint: snapshot.data[i].geoPoint,
                                              appBarTitle:
                                              snapshot.data[i].title)));
                                    },
                                    icon: Icon(Icons.location_on_outlined),
                                    label: Text('Location')),
                                RaisedButton(
                                    onPressed: snapshot.data[i].isSold
                                        ? null
                                        : () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProducDetails(
                                                      product:
                                                      snapshot.data[i])));
                                    },
                                    child: Text(snapshot.data[i].isSold
                                        ? 'Sold out'
                                        : 'bidding')),
                                RaisedButton.icon(
                                    onPressed: () async {
                                      var user = await FirestoreDatabase()
                                          .getUserById(snapshot.data[i].userId);
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileScreen(userModel: user)));

                                    },
                                    icon: Icon(Icons.person),
                                    label: Align(alignment: Alignment.center,child: Text('Chat With\n Creator')),),
                              ],
                            )
                          ],
                        ),
                      );
                    }
                  }
              else{
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FutureBuilder<UserModel>(future: FirestoreDatabase().getUserById(snapshot.data[i].userId),builder: (context,user){
                            if(user.data == null)
                              return  CircularProgressIndicator();
                            return Row(
                              children: [
                                CircleAvatar(backgroundImage: NetworkImage(user.data.profilePic),),
                                SizedBox(width: 5,),
                                Icon(Icons.verified,color: Colors.orange,),
                                SizedBox(width: 5,),
                                Text('Seller:\n'+user.data.firstname+' '+user.data.lastname,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange),),
                                Spacer(),
                                if (snapshot.data[i].userId == auth.currentUser.uid)

                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(context).errorColor,
                                    ),
                                    onPressed: () {
                                      try {
                                        FirestoreDatabase()
                                            .delProduct(snapshot.data[i]);
                                        Toast.show('Product Deleted!', context);
                                      } catch (e) {
                                        Toast.show('Something went wrong', context);
                                      }
                                    },
                                  ),
                              ],
                            );
                          }),

                          ListTile(
                            title: Text(snapshot.data[i].title),
                            subtitle: Text(snapshot.data[i].description),
                            trailing: Text("Price : ${snapshot.data[i].price}\$"),
                          ),
                          Image.network(
                            snapshot.data[i].image,
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
                                            geoPoint: snapshot.data[i].geoPoint,
                                            appBarTitle:
                                            snapshot.data[i].title)));
                                  },
                                  icon: Icon(Icons.location_on_outlined),
                                  label: Text('Location')),
                              RaisedButton.icon(
                                  onPressed: snapshot.data[i].isSold
                                      ? null
                                      : () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProducDetails(
                                                    product:
                                                    snapshot.data[i])));
                                  },
                                  icon: Icon(Icons.comment_outlined),
                                  label: Text(snapshot.data[i].isSold
                                      ? 'Sold out'
                                      : 'Bid')),
                              RaisedButton.icon(
                                  onPressed: () async {
                                    final user = await FirestoreDatabase()
                                        .getUserById(snapshot.data[i].userId);
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileScreen(userModel: user)));
                                  },
                                  icon: Icon(Icons.person),
                                  label: Align(alignment: Alignment.center,child: Text('Chat With\n Seller')),)
                            ],
                          )
                        ],
                      ),
                    );
                  }
                return Card();
                });
          },
        ));
  }
}
