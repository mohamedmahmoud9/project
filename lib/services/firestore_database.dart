import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journey_app/models/activity.dart';
import 'package:journey_app/models/event.dart';
import 'package:journey_app/models/message.dart';
import 'package:journey_app/models/poduct_comments.dart';
import 'package:journey_app/models/post.dart';
import 'package:journey_app/models/product.dart';

import '../models/user.dart';
import 'firestore_path.dart';

class FirestoreDatabase {
  final _service = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  UploadTask uploadTask;

  Future<void> addUserToFirestore(UserModel user, PickedFile img) async {
    String imgRef = user.profilePic;
    if (img != null) {
      final result = await uploadFile(img, 'users', _auth.currentUser.uid);
      imgRef = await result.snapshot.ref.getDownloadURL();
    }
    user.profilePic = imgRef;
    await _service
        .collection(FirestorePath.user())
        .doc(_auth.currentUser.uid)
        .set(user.toMap());
  }

  Future<UploadTask> uploadFile(
      PickedFile file, String collection, String id) async {
    UploadTask uploadTask;
    // Create a Reference to the file
    Reference ref = _storage.ref().child(collection).child('/$id');

    uploadTask = ref.putFile(File(file.path));
    await uploadTask.whenComplete(() {});
    return Future.value(uploadTask);
  }

  Future<UserModel> getCurrentUser() async {
    final snapshot = await _service
        .collection(FirestorePath.user())
        .doc(_auth.currentUser.uid)
        .get();
    print(snapshot.data());
    return UserModel.fromJson(snapshot.data(), _auth.currentUser.uid);
  }

  Future<UserModel> getUserById(String uid) async {
    final snapshot =
        await _service.collection(FirestorePath.user()).doc(uid).get();
    return UserModel.fromJson(snapshot.data(),uid );
  }

  Future<void> joinEvent(Event event) async {
    if (event.usersInEvent.contains(_auth.currentUser.uid)) {
      event.usersInEvent.remove(_auth.currentUser.uid);
    } else {
      event.usersInEvent.add(_auth.currentUser.uid);
    }
    await _service
        .collection(FirestorePath.evets())
        .doc(event.id)
        .set(event.toJson());
  }

  Stream<List<Activity>> getUserActivities() => _service
      .collection(FirestorePath.userActivities(_auth.currentUser.uid))
      .snapshots()
      .map((event) => event.docs.map((e) {
            print(e.data());
            return Activity.formJson(e.data());
          }).toList());

  Stream<List<UserModel>> getAllUsers() =>
      _service.collection(FirestorePath.user()).snapshots().map((event) =>
          event.docs.map((e) => UserModel.fromJson(e.data(), e.id)).toList());
  Stream<List<Event>> getAllEvents() =>
      _service.collection(FirestorePath.evets()).snapshots().map((event) =>
          event.docs.map((e) => Event.fromJson(e.data(), e.id)).toList());
  Stream<List<ProductComment>> getProductComments(String id) => _service
      .collection(FirestorePath.productComments(id))
      .snapshots()
      .map((event) => event.docs
          .map((e) => ProductComment.formJson(e.data(), e.id))
          .toList());
  Stream<List<Post>> getUserPosts(String id) => _service
      .collection(FirestorePath.userPosts(id))
      .snapshots()
      .map((event) =>
          event.docs.map((e) => Post.fromJson(e.data(), e.id)).toList());
  Stream<List<Product>> getAllProducts() =>
      _service.collection(FirestorePath.market()).snapshots().map((event) =>
          event.docs.map((e) => Product.fromJson(e.data(), e.id)).toList());
  Future<void> addEvent(Event event, PickedFile img) async {
    String imgRef = event.image;
    if (img != null) {
      final result = await uploadFile(img, 'events', DateTime.now().toString());
      if (result != null) imgRef = await result.snapshot.ref.getDownloadURL();
    }
    event.image = imgRef;
    await _service.collection(FirestorePath.evets()).doc().set(event.toJson());
  }

  Future<void> delEvent(Event event) async {
    await _service.collection(FirestorePath.evets()).doc(event.id).delete();
  }

  Future<void> addActivity(Activity activity) async {
    await _service
        .collection(FirestorePath.userActivities(_auth.currentUser.uid))
        .doc()
        .set(activity.toJson());
  }

  Future<void> addPost(Post post, PickedFile img) async {
    if (img != null) {
      final result = await uploadFile(img, 'market', DateTime.now().toString());
      if (result != null) {
        post.image = await result.snapshot.ref.getDownloadURL();
      }
    } else {
      post.image = '';
    }

    await _service
        .collection(FirestorePath.userPosts(_auth.currentUser.uid))
        .doc()
        .set(post.toJson());
  }

  Future<void> addComment(ProductComment comment, String id) async {
    await _service
        .collection(FirestorePath.productComments(id))
        .doc()
        .set(comment.toJson());
  }

  Future<void> addMessage(Message msg, String toId) async {
    await _service
        .collection(FirestorePath.chats(_auth.currentUser.uid, toId))
        .doc()
        .set(msg.toMap());
    await _service
        .collection(FirestorePath.chats(toId, _auth.currentUser.uid))
        .doc()
        .set(msg.toMap());
  }

  Stream<List<Message>> getChat(String toId) => _service
      .collection(FirestorePath.chats(_auth.currentUser.uid, toId))
      .snapshots()
      .map((event) =>
          event.docs.map((e) => Message.fromJson(e.data(), e.id)).toList());

  Future<void> addProduct(Product product, PickedFile img) async {
    if (img != null) {
      final result = await uploadFile(img, 'market', DateTime.now().toString());
      if (result != null) {
        product.image = await result.snapshot.ref.getDownloadURL();
      }
    }

    await _service
        .collection(FirestorePath.market())
        .doc()
        .set(product.toJson());
  }

  Future<void> delProduct(Product product) async {
    await _service.collection(FirestorePath.market()).doc(product.id).delete();
  }

  Future<void> updateProduct(
    Product product,
  ) async {
    await _service
        .collection(FirestorePath.market())
        .doc(product.id)
        .set(product.toJson());
  }
}
