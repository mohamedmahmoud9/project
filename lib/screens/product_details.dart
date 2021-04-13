import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journey_app/models/poduct_comments.dart';
import 'package:journey_app/models/product.dart';
import 'package:journey_app/models/user.dart';
import 'package:journey_app/screens/profile_screen.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'package:intl/intl.dart';

class ProducDetails extends StatelessWidget {
  final Product product;
  final TextEditingController controller = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser.uid;
  ProducDetails({Key key, this.product}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirestoreDatabase().getProductComments(product.id),
              builder: (BuildContext context,
                  AsyncSnapshot<List<ProductComment>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                snapshot.data.sort((a, b) => a.dateTime.compareTo(b.dateTime));
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, i) => ListTile(
                    onTap: () async {

                      final user = await FirestoreDatabase()
                          .getUserById(snapshot.data[i].uid);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(userModel: user)));
                    },
                    trailing: uid == product.userId && !product.isSold
                        ? RaisedButton(
                            child: Text('Sell'),
                            onPressed: () async {
                              product.isSold = true;
                              await FirestoreDatabase().updateProduct(product);
                              Navigator.of(context).pop();
                            },
                          )
                        : null,
                    title: Text('${snapshot.data[i].username}'+'\n'+DateFormat.yMEd().add_jms().format(snapshot.data[i].dateTime),style: TextStyle(color: Colors.orange),),
                    subtitle: Text('${snapshot.data[i].price}',style: TextStyle(color: Colors.black),),
                  ),
                );
              },
            ),
          ),
          if (uid != product.userId)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(hintText: 'Bid'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (controller.text.isEmpty) {
                        return;
                      }
                      final db = FirestoreDatabase();
                      final UserModel user = await db.getCurrentUser();
                      await db.addComment(
                        ProductComment(
                            dateTime: DateTime.now(),
                            price: controller.text,
                            username: user.firstname + ' ' + user.lastname,
                            commentId: '',
                            uid: user.uid),
                        product.id,
                      );
                      controller.clear();
                    },
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
