import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final double price;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.dateTime,
      @required this.id,
      @required this.price,
      @required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String _token;
  final String _userId;

  Orders(this._token, this._userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://flutter-shop-d0f79.firebaseio.com/orders/$_userId.json?auth=$_token";
    final response = await get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) return;
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          dateTime: DateTime.parse(orderData["dateTime"]),
          id: orderId,
          price: orderData["price"],
          products: (orderData["products"] as List<dynamic>).map((item) {
            CartItem(
                id: item["id"],
                price: item["price"],
                quantity: item["quantity"],
                title: item["title"]);
          }).toList()));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrders(List<CartItem> cartProducts, double amount) async {
    final url =
        "https://flutter-shop-d0f79.firebaseio.com/orders/$_userId.json?auth=$_token";
    final timeStamp = DateTime.now();
    final response = await post(url,
        body: json.encode({
          "amount": amount,
          "dateTime": timeStamp.toIso8601String(),
          "products": cartProducts
              .map((cp) => {
                    "id": cp.id,
                    "title": cp.title,
                    "quantity": cp.quantity,
                    "price": cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
          dateTime: timeStamp,
          id: json.decode(response.body)["name"],
          price: amount,
          products: cartProducts),
    );
    notifyListeners();
  }
}
