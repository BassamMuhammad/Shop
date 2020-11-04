import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    @required this.title,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String authToken, String userId) async {
    isFavorite = !isFavorite;
    final url =
        "https://flutter-shop-d0f79.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken";
    notifyListeners();
    try {
      final response = await put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) throw HttpException("Error occured");
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
    }
  }
}
