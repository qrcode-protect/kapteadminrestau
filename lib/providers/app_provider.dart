import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_package/firebase_login_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:libertyrestaurant/models/utilisateur/utilisateur.dart';
import 'package:libertyrestaurant/services/data.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AppStateProvider with ChangeNotifier {
  AppStateProvider() {
    getUser();
  }
  AuthenticationRepository auth = AuthenticationRepository(_auth);
  User? user;
  bool awaitUser = true;
  Utilisateur? utilisateur;

  getUser() async {
    user = auth.firebaseAuth.currentUser;
    if (user != null) {
      getUtilisateur();
    } else {
      user = await FirebaseAuth.instance.authStateChanges().first;
      if (user != null) {
        getUtilisateur();
      } else {
        awaitUser = false;
      }
    }
    notifyListeners();
  }

  getUtilisateur() async {
    utilisateur = await Data().getUtilisateur();
    notifyListeners();
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await auth.loginWithEmailAndPassword(email, password).then((value) async {
      getUser();
      getUtilisateur();
    });
  }

  signOut() async {
    await auth.logOut().then((value) {
      getUser();
      utilisateur = null;
    });
    notifyListeners();
  }
}
