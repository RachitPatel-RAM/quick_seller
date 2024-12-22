import 'package:flutter/material.dart';
import '../utils/calculations.dart';

class OrderCard extends StatelessWidget {
  final dynamic orderDoc;
  final Map<String, dynamic> orderData;
  final Function(String, Map<String, dynamic>) onApprove;
  final Function(String, Map<String, dynamic>) onReject;

  const OrderCard({
    Key? key,
    required this.orderDoc,
    required this.orderData,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var items = orderData['items'] as List<dynamic>? ?? [];

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ExpansionTile(
        title: Text(
          'Order #${orderDoc.id.substring(0, 8)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Items: ${items.length} | Total: ₹${calculateTotal(items)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          ...items.map((item) => ListTile(
            leading: item['imageUrl'] != null
                ? Image.network(
              item['imageUrl'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported),
            )
                : Icon(Icons.image_not_supported),
            title: Text(item['name'] ?? 'Unknown Product'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${item['quantity'] ?? 0}'),
                Text('Price: ₹${item['price'] ?? 0}'),
                Text('Total: ₹${(item['price'] ?? 0) * (item['quantity'] ?? 0)}'),
              ],
            ),
          )),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.check),
                  label: Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => onApprove(orderDoc.id, orderData),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.close),
                  label: Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => onReject(orderDoc.id, orderData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}