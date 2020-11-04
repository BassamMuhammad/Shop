import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  String _token;
  String _userId;

  ProductsProvider(this._token, this._userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  void addProducts(value) {
    _items.add(value);
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((meal) => meal.id == id);
  }

  Future<void> fetchAndSetProdut([bool filter = false]) async {
    String filterBy = filter ? "&orderBy='creatorId'&equalTo='$_userId'" : "";
    var url =
        "https://flutter-shop-d0f79.firebaseio.com/products.json?auth=$_token$filterBy";
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) return;

      url =
          "https://flutter-shop-d0f79.firebaseio.com/userFavorites/$_userId.json?auth=$_token";
      final favResposne = await http.get(url);
      final favData = json.decode(favResposne.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            description: prodData["description"],
            id: prodId,
            title: prodData["title"],
            imageUrl: prodData["imageUrl"],
            price: prodData["price"],
            isFavorite: favData == null ? false : favData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://flutter-shop-d0f79.firebaseio.com/products.json?auth=$_token";
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
            "creatorId": _userId,
          }));

      final newProduct = Product(
          id: json.decode(response.body)["name"],
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          title: product.title);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final index = _items.indexWhere((element) => element.id == id);
    _items[index] = newProduct;
    final url =
        "https://flutter-shop-d0f79.firebaseio.com/products/$id.json?auth=$_token";
    await http.patch(url,
        body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price,
        }));
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://flutter-shop-d0f79.firebaseio.com/products/$id.json?auth=$_token";
    final prodIndex = _items.indexWhere((element) => element.id == id);
    var prod = _items[prodIndex];
    _items.removeAt(prodIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(prodIndex, prod);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
    prod = null;
  }
}
