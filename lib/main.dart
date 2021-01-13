import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple sing in',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Apple sing in'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AuthCredential _credential;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SignInWithAppleButton(
                onPressed: () async {
                  final credential = await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                      AppleIDAuthorizationScopes.fullName,
                    ],
                  );

                  try {
                    await singInFirebase(credential);
                  } catch (e) {
                    print(e);
                  }

                  print(credential);

                  // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                  // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                },
              ),
              SizedBox(height: 20),
              Visibility(
                visible: _credential != null,
                child: FlatButton(
                  onPressed: () async {
                    await logout();
                  },
                  child: Text('Logout'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> singInFirebase(
      AuthorizationCredentialAppleID appleCredential) async {
    OAuthProvider oAuthProvider = new OAuthProvider("apple.com");
    _credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final auth = await FirebaseAuth.instance.signInWithCredential(_credential);
    print(FirebaseAuth.instance.currentUser);
    setState(() {});

    print(auth.user.uid);
  }

  Future<void> logout() async {
    try {
      print('=========before');
      print(FirebaseAuth.instance.currentUser);
      await FirebaseAuth.instance.signOut();
      print('=========after');
      print(FirebaseAuth.instance.currentUser);
    } catch (e) {
      print(e);
    }
  }
}
