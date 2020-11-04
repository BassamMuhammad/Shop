import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isloading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isloading = true;
    });
    Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProdut()
        .then((value) => setState(() {
              _isloading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyShop"),
        actions: [
          PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.Favorites)
                    _showOnlyFavorites = true;
                  else
                    _showOnlyFavorites = false;
                });
              },
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: const Text("Show Only Favorites"),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: const Text("Show All"),
                      value: FilterOptions.All,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (context, cart, child) =>
                Badge(child: child, value: cart.itemsCount.toString()),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
