import 'package:flutter/material.dart';

class OrderApprovalDialog extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final bool isApprove;
  final Function(String, Map<String, dynamic>) onApprove;
  final Function(String, Map<String, dynamic>) onReject;

  const OrderApprovalDialog({
    Key? key,
    required this.orderId,
    required this.orderData,
    required this.isApprove,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String action = isApprove ? 'Approve' : 'Reject';

    return AlertDialog(
      title: Text("$action Order"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Username: ${orderData['username'] ?? 'N/A'}"),
          Text("Phone: ${orderData['phone'] ?? 'N/A'}"),
          Text("Email: ${orderData['email'] ?? 'N/A'}"),
          Text("Address: ${orderData['address'] ?? 'N/A'}"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (isApprove) {
              onApprove(orderId, orderData);
            } else {
              onReject(orderId, orderData);
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order $action')),
            );
          },
          child: Text(action),
        ),
      ],
    );
  }
}