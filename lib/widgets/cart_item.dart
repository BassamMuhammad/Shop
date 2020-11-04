import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final String title;
  final int quantity;
  CartItem(this.id, this.productId, this.price, this.title, this.quantity);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        Provider.of<Cart>(context, listen: false).deleteItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Are you sure?"),
              content: Text("Do you want to remove?"),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text("NO")),
                FlatButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text("YES")),
              ],
            );
          },
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: FittedBox(child: Text("\$$price")),
              ),
            ),
            title: Text(title),
            subtitle: Text("Total: \$${price * quantity}"),
            trailing: Text("$quantity"),
          ),
        ),
      ),
    );
  }
}
