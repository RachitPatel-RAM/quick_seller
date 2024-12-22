// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class DeliveryManagementScreen extends StatelessWidget {
//   final CollectionReference orders = FirebaseFirestore.instance.collection('ordered_item');
//   final CollectionReference adminOrders = FirebaseFirestore.instance.collection('admin_view_order');
//   final String currentSellerId;
//
//   DeliveryManagementScreen({required this.currentSellerId});
//
//   // Existing approve/reject methods remain the same...
//
//   @override
//   Widget build(BuildContext context) {
//     final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage Orders'),
//         backgroundColor: Colors.yellow[700],
//         foregroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         // Filter orders where items contain products from the current seller
//         stream: orders.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Something went wrong!'));
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[700]!),
//             ));
//           }
//
//           final orderDocuments = snapshot.data?.docs ?? [];
//           final sellerOrders = orderDocuments.where((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             final items = data['items'] as List<dynamic>? ?? [];
//             // Check if any item belongs to the current seller
//             return items.any((item) => item['sellerId'] == userId);
//           }).toList();
//
//           if (sellerOrders.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.inbox, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'No orders available',
//                     style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             itemCount: sellerOrders.length,
//             padding: EdgeInsets.all(8),
//             itemBuilder: (context, index) {
//               var orderDoc = sellerOrders[index];
//               var orderData = orderDoc.data() as Map<String, dynamic>;
//               var items = orderData['items'] as List<dynamic>? ?? [];
//
//               // Filter items for current seller
//               var sellerItems = items.where(
//                       (item) => item['sellerId'] == userId
//               ).toList();
//
//               return Card(
//                 elevation: 3,
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//                 child: ExpansionTile(
//                   title: Text(
//                     'Order #${orderDoc.id.substring(0, 8)}',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     'Items: ${sellerItems.length} | Total: ₹${_calculateTotal(sellerItems)}',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                   children: [
//                     ...sellerItems.map((item) => ListTile(
//                       leading: item['imageUrl'] != null
//                           ? Image.network(
//                         item['imageUrl'],
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) =>
//                             Icon(Icons.image_not_supported),
//                       )
//                           : Icon(Icons.image_not_supported),
//                       title: Text(item['name'] ?? 'Unknown Product'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Quantity: ${item['quantity'] ?? 0}'),
//                           Text('Price: ₹${item['price'] ?? 0}'),
//                           Text('Total: ₹${(item['price'] ?? 0) * (item['quantity'] ?? 0)}'),
//                         ],
//                       ),
//                     )),
//                     Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton.icon(
//                             icon: Icon(Icons.check),
//                             label: Text('Approve'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                             ),
//                             onPressed: () => showApprovalDialog(
//                                 context,
//                                 orderDoc.id,
//                                 orderData,
//                                 true
//                             ),
//                           ),
//                           ElevatedButton.icon(
//                             icon: Icon(Icons.close),
//                             label: Text('Reject'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                             ),
//                             onPressed: () => showApprovalDialog(
//                                 context,
//                                 orderDoc.id,
//                                 orderData,
//                                 false
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   double _calculateTotal(List<dynamic> items) {
//     return items.fold(0.0, (total, item) {
//       return total + ((item['price'] ?? 0.0) * (item['quantity'] ?? 0));
//     });
//   }
// }
