import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _userId;
  String _token;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) _authTimer.cancel();

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogOut() {
    if (_authTimer != null) _authTimer.cancel();
    final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBbois_vyq7CKFGo0ac_0lpVvrMrNX2l3E";
    final response = await http.post(
      url,
      body: json.encode(
        {
          "email": email,
          "password": password,
          "returnSecureToken": true,
        },
      ),
    );
    final responseData = json.decode(response.body);
    if (responseData["error"] != null)
      throw HttpException(responseData["error"]["message"]);

    _token = responseData["idToken"];
    _userId = responseData["localId"];
    _expiryDate = DateTime.now()
        .add(Duration(seconds: int.parse(responseData["expiresIn"])));
    _autoLogOut();
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      "token": _token,
      "userId": _userId,
      "expiryDate": _expiryDate.toIso8601String(),
    });
    prefs.setString("userData", userData);

    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) return false;
    final extractedData =
        json.decode(prefs.getString("userData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedData["userData"]);

    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedData["token"];
    _userId = extractedData["userId"];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }
}
