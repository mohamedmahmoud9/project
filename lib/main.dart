import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:journey_app/screens/activity_screen.dart';
import 'package:journey_app/screens/events_screen.dart';
import 'package:journey_app/screens/main_map.dart';
import 'package:journey_app/screens/market_screen.dart';
import 'package:location/location.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';
import 'services/firestore_database.dart';
import 'models/user.dart';
import 'screens/uncomplete_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth firebaseAuth;
  Location location = Location();
  @override
  void initState() {
    super.initState();
    firebaseAuth = FirebaseAuth.instance;
    location.requestPermission();
    updatelocation();

  }
void updatelocation()async{
    final userlocation = await location.getLocation();
    FirebaseFirestore.instance.collection('users').doc(firebaseAuth.currentUser.uid).update({'locationLatLng':GeoPoint(
        userlocation.latitude, userlocation.longitude)});
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journey',
      theme: ThemeData(
          // primarySwatch: Colors.red,
          accentColor: Colors.deepOrange,
          primaryColor: Color(0xFFF79939),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          buttonTheme: ButtonThemeData(
              buttonColor: Color(0xFFF79939),
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)))),
      home: firebaseAuth.currentUser == null
          ? AuthScreen(
              firebaseAuth: firebaseAuth,
            )
          : FutureBuilder(
              future: FirestoreDatabase().getCurrentUser(),
              builder:
                  (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingScreen();
                } else {
                  if(snapshot.data == null)
                    return AuthScreen(
    firebaseAuth: firebaseAuth,
    );
                  if (snapshot.data.isCompleted)
                    return HomeScreen(
                      userModel: snapshot.data,
                    );
                  else
                    return UnCompleteProfileScreen(
                        userModel: snapshot.data,
                        firbaseAuth: firebaseAuth,
                        isEdit: false);
                }
              },
            ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final UserModel userModel;

  const HomeScreen({
    Key key,
    @required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .05,
            ),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: MediaQuery.of(context).size.height * .2,
              ),
            ),
            Expanded(
                child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(userModel: userModel)));
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                              child: Icon(
                            Icons.person,
                            color: Colors.white,
                          )),
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CommunityScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                              child: Icon(
                            Icons.group,
                            color: Colors.white,
                          )),
                        ),
                        Text(
                          'Community',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ActivityScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                              child: Icon(
                            Icons.pedal_bike,
                            color: Colors.white,
                          )),
                        ),
                        Text(
                          'Activites',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MarketScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                              child: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          )),
                        ),
                        Text(
                          'Market',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EventsScreen())),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                              child: Icon(
                            Icons.event,
                            color: Colors.white,
                          )),
                        ),
                        Text(
                          'Events',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => MainMap())),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                              child: Icon(
                            Icons.location_on,
                            color: Colors.white,
                          )),
                        ),
                        Text(
                          'Map',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  const AuthScreen({
    Key key,
    this.firebaseAuth,
  }) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode authMode;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassswordController = TextEditingController();

  bool _loading = false;

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeySignUp = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    authMode = AuthMode.Login;
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              authMode == AuthMode.SignUp
                  ? _buildSignupCard()
                  : _buildLoginCard(),
              FlatButton(
                  onPressed: () {
                    setState(() {
                      if (authMode == AuthMode.Login) {
                        authMode = AuthMode.SignUp;
                      } else {
                        authMode = AuthMode.Login;
                      }
                    });
                  },
                  child: Text(authMode == AuthMode.SignUp
                      ? 'Already Have an Account ?'
                      : 'Create New Account ?'))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Form(
      key: _formKeyLogin,
      child: Column(
        children: [
          TextFormField(
            validator: (value) {
              if (value.isEmpty ||
                  !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                return 'Invaled Email';
              }
              return null;
            },
            controller: emailController,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30))),
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30))),
          ),
          SizedBox(
            height: 8,
          ),
          _loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RaisedButton(
                  child: Text('Login'),
                  onPressed: () async {
                    if (!_formKeyLogin.currentState.validate()) {
                      return;
                    }
                    setState(() {
                      _loading = true;
                    });
                    try {
                      _formKeyLogin.currentState.save();
                      await widget.firebaseAuth.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim());
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MyApp()));
                    } on FirebaseAuthException catch (error) {
                      setState(() {
                        _loading = false;
                      });
                      _scaffoldkey.currentState
                          .showSnackBar(SnackBar(content: Text(error.message)));
                    }
                    setState(() {
                      _loading = false;
                    });
                  },
                ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupCard() {
    return Form(
      key: _formKeySignUp,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            validator: (value) {
              if (value.isEmpty ||
                  !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                return 'Invalid Email';
              }
              return null;
            },
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30))),
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            validator: (value) {
              if (value.length < 8) {
                return 'Password Must be equal or greater than 8 characters';
              }
              return null;
            },
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30))),
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            obscureText: true,
            validator: (value) {
              if (value != passwordController.text) {
                return 'Passwords Not Match!';
              }
              return null;
            },
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Confirm Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30))),
          ),
          SizedBox(
            height: 8,
          ),
          _loading
              ? Center(child: CircularProgressIndicator())
              : RaisedButton(
                  child: Text('Sign up'),
                  onPressed: () async {
                    if (!_formKeySignUp.currentState.validate()) {
                      return;
                    }
                    setState(() {
                      _loading = true;
                    });
                    try {
                      _formKeySignUp.currentState.save();
                      await widget.firebaseAuth.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim());
                      await FirestoreDatabase().addUserToFirestore(
                          UserModel(
                            uid: widget.firebaseAuth.currentUser.uid,
                            email: emailController.text.trim(),
                            gender: null,
                            status: null,
                            firstname: null,
                            posts: [],
                            following: [],
                            lastname: null,
                            profilePic: null,
                            isCompleted: false,
                            locationLatLng: null,
                          ),
                          null);
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MyApp()));
                    } on FirebaseAuthException catch (error) {
                      setState(() {
                        _loading = false;
                      });
                      _scaffoldkey.currentState
                          .showSnackBar(SnackBar(content: Text(error.message)));
                    }
                    setState(() {
                      _loading = false;
                    });
                  },
                ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

}

enum AuthMode { Login, SignUp }
