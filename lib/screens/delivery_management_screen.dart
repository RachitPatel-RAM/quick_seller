import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/order_approval_dialog.dart';
import '../widgets/order_card.dart';
import '../services/order_service.dart';

class DeliveryManagementScreen extends StatelessWidget {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Orders'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ordered_item').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[700]!),
              ),
            );
          }

          final orders = snapshot.data?.docs ?? [];
          
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              var orderDoc = orders[index];
              var orderData = orderDoc.data() as Map<String, dynamic>;
              
              return OrderCard(
                orderDoc: orderDoc,
                orderData: orderData,
                onApprove: (orderId, data) => _showApprovalDialog(context, orderId, data, true),
                onReject: (orderId, data) => _showApprovalDialog(context, orderId, data, false),
              );
            },
          );
        },
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, String orderId, Map<String, dynamic> data, bool isApprove) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OrderApprovalDialog(
          orderId: orderId,
          orderData: data,
          isApprove: isApprove,
          onApprove: _orderService.approveOrder,
          onReject: _orderService.rejectOrder,
        );
      },
    );
  }
}