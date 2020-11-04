import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  Product _editedProduct =
      Product(id: null, description: "", imageUrl: "", price: 0.0, title: "");

  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
  };

  var _isloading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
  }

  @override
  dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImage);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
  }

  void _updateImage() {
    if (!_imageUrlFocusNode.hasFocus) setState(() {});
  }

  Future<void> _saveForm() async {
    setState(() {
      _isloading = true;
    });
    if (_form.currentState.validate()) {
      _form.currentState.save();
      if (_editedProduct.id != null) {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        try {
          await Provider.of<ProductsProvider>(context, listen: false)
              .addProduct(_editedProduct);
        } catch (error) {
          await showDialog<Null>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text("Something went wrong"),
                  content: Text("An error occured!"),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text("Okay"))
                  ],
                );
              });
        }
        setState(() {
          _isloading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues["title"],
                      validator: (value) {
                        if (value.isEmpty) return "Please enter title";
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (newValue) => _editedProduct = Product(
                        id: _editedProduct.id,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price,
                        title: newValue,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      validator: (value) {
                        if (value.isEmpty) return "Please enter price";
                        if (double.tryParse(value) == null)
                          return "Please enter valid price";
                        if (double.parse(value) <= 0)
                          return "Please enter number greater than zero";
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      onSaved: (newValue) => _editedProduct = Product(
                        id: _editedProduct.id,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        price: double.parse(newValue),
                        title: _editedProduct.title,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
                      validator: (value) {
                        if (value.isEmpty) return "Please enter description";
                        return null;
                      },
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (newValue) => _editedProduct = Product(
                        id: _editedProduct.id,
                        description: newValue,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price,
                        title: _editedProduct.title,
                        isFavorite: _editedProduct.isFavorite,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter a URL")
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) return "Please enter URL";
                              if (!value.startsWith("http"))
                                return "Please enter valid URL";
                              return null;
                            },
                            decoration: InputDecoration(labelText: "Image Url"),
                            maxLines: 3,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) => _saveForm(),
                            onSaved: (newValue) => _editedProduct = Product(
                              id: _editedProduct.id,
                              description: _editedProduct.description,
                              imageUrl: newValue,
                              price: _editedProduct.price,
                              title: _editedProduct.title,
                              isFavorite: _editedProduct.isFavorite,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
