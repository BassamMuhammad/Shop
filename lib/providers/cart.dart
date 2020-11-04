import 'package:flutter/cupertino.dart';

class CartItem {
  String id;
  String title;
  double price;
  int quantity;

  CartItem(
      {@required this.id,
      @required this.price,
      @required this.quantity,
      @required this.title});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemsCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem({String productId, double price, String title}) {
    if (_items.containsKey(productId)) {
      _items.update(productId, (oldCartItem) {
        oldCartItem.quantity = oldCartItem.quantity + 1;
        return oldCartItem;
      });
    } else {
      _items.putIfAbsent(
          productId,
          () =>
              CartItem(id: productId, price: price, quantity: 1, title: title));
    }
    notifyListeners();
  }

  void deleteItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id].quantity > 1)
      _items.update(id, (existingItem) {
        existingItem.quantity -= 1;
        return existingItem;
      });
    else
      _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
