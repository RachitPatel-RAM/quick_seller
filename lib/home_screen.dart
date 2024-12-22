import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:quicks/screens/delivery_management_screen.dart';

import 'login_screen.dart';
import 'order_management.dart';

class QsellerApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QsellerHomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/addProduct': (context) => AddProductScreen(),
        '/deliveryManagement': (context) => DeliveryManagementScreen(),
      },
    );
  }
}

class QsellerHomeScreen extends StatefulWidget {
  @override
  _QsellerHomeScreenState createState() => _QsellerHomeScreenState();
}

class _QsellerHomeScreenState extends State<QsellerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _profileImage;
  String? _name;
  String? _email;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Listen to real-time updates
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists) {
            setState(() {
              _profileImage = doc.data()?['profileImage'];
              _name = doc.data()?['name'];
              _email = doc.data()?['email'];
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate to the LoginScreen
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    } catch (e) {
      // Handle any errors
      print('Error signing out: $e');
      // You could also show a Snackbar or a dialog here to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Qseller'),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_name ?? 'name'),
              accountEmail: Text(_email ?? 'email@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _profileImage != null
                    ? NetworkImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? Icon(Icons.person)
                    : null,
              ),
              decoration: BoxDecoration(color: Colors.grey),
            ),
            Spacer(),
            ElevatedButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Sign Out'),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching products.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }
          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: product['imageUrl'] != null
                      ? Image.network(
                    product['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 50),
                  title: Text(product['name'] ?? 'Unnamed Product'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['description'] ?? ''),
                      SizedBox(height: 4),
                      Text('Category: ${product['category'] ?? 'Unknown'}'),
                      Text('Price: \₹${product['price'].toString()}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: () async {
                          final nameController = TextEditingController(text: product['name']);
                          final priceController = TextEditingController(text: product['price'].toString());
                          final descriptionController = TextEditingController(text: product['description']);
                          String? category = product['category'];

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Update Product'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: nameController,
                                        decoration: InputDecoration(labelText: 'Name'),
                                      ),
                                      TextFormField(
                                        controller: priceController,
                                        decoration: InputDecoration(labelText: 'Price'),
                                        keyboardType: TextInputType.number,
                                      ),
                                      DropdownButtonFormField(
                                        value: category,
                                        items: ['Fashion', 'Toys', 'Electronics', 'Books', 'Beauty']
                                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                                            .toList(),
                                        onChanged: (value) {
                                          category = value as String?;
                                        },
                                        decoration: InputDecoration(labelText: 'Category'),
                                      ),
                                      TextFormField(
                                        controller: descriptionController,
                                        decoration: InputDecoration(labelText: 'Description'),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('products')
                                          .doc(product.id)
                                          .update({
                                        'name': nameController.text,
                                        'price': double.parse(priceController.text),
                                        'description': descriptionController.text,
                                        'category': category,
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('products')
                              .doc(product.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.yellow,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Add Product',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.yellow,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeliveryManagementScreen()),
              );
            },
            child: Icon(Icons.local_shipping),
            tooltip: 'Delivery Management',
          ),
        ],
      ),
    );
  }
}
class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  File? _imageFile;
  String? _imageUrl;
  bool _isSaving = false; // Flag to track saving state

  final String cloudinaryUrl = "https://api.cloudinary.com/v1_1/drbp7g1t4/image/upload";
  final String uploadPreset = "Qselllerproduct";

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _saveProduct() async {
    final sellerId = FirebaseAuth.instance.currentUser?.uid;
    if (sellerId != null && _imageUrl != null) {
      setState(() {
        _isSaving = true; // Show progress indicator
      });

      try {
        // Save product to Firestore
        await FirebaseFirestore.instance.collection('products').add({
          'sellerId': sellerId, // Link product to the seller
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'imageUrl': _imageUrl,
          'createdAt': Timestamp.now(),
        });
        Navigator.pop(context);
      } catch (e) {
        print('Error saving product: $e');
      } finally {
        setState(() {
          _isSaving = false; // Hide progress indicator
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      await _uploadImageToCloudinary();
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_imageFile == null) return;

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_imageFile!.path),
        'upload_preset': uploadPreset,
      });

      final response = await dio.post(cloudinaryUrl, data: formData);
      if (response.statusCode == 200) {
        String secureUrl = response.data['secure_url'];

        setState(() {
          _imageUrl = secureUrl;
        });

        print('Image uploaded successfully. Secure URL: $secureUrl');
      } else {
        print('Failed to upload image to Cloudinary.');
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
    }
  }

  Future<void> _fetchSellerProducts() async {
    final sellerId = FirebaseAuth.instance.currentUser?.uid;
    if (sellerId != null) {
      try {
        // Fetch products for the current seller only
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: sellerId)
            .get();

        List<DocumentSnapshot> products = snapshot.docs;
        print('Fetched products: ${products.length}');
        // You can now use the products list to display the products for the seller
      } catch (e) {
        print('Error fetching products for seller: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSellerProducts(); // Fetch seller products when screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  if (_imageFile != null)
                    Image.file(_imageFile!, height: 200, width: 200, fit: BoxFit.cover),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Product Name'),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField(
                    value: _selectedCategory,
                    items: ['Fashion', 'Toys', 'Electronics', 'Books', 'Beauty']
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
