import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    var theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .pushNamed(ProductsDetailScreen.routeName, arguments: product.id),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage("assets/images/product-placeholder.png"),
              image: NetworkImage(
                product.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            builder: (context, value, child) => IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: theme.accentColor,
                onPressed: () {
                  final oldFav = product.isFavorite;
                  product.toggleFavorite(auth.token, auth.userId);
                  if (oldFav == product.isFavorite)
                    Scaffold.of(context).showSnackBar(
                      SnackBar(content: const Text("Error occured")),
                    );
                }),
          ),
          trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: theme.accentColor,
              onPressed: () {
                cart.addItem(
                    price: product.price,
                    productId: product.id,
                    title: product.title);
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: const Text("Item added to cart"),
                  action: SnackBarAction(
                    label: "UNDO",
                    onPressed: () => cart.deleteItem(product.id),
                  ),
                ));
              }),
        ),
      ),
    );
  }
}
