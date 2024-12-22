import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference orders = FirebaseFirestore.instance.collection('ordered_item');
  final CollectionReference adminOrders = FirebaseFirestore.instance.collection('admin_view_order');

  Future<void> approveOrder(String docId, Map<String, dynamic> orderData) async {
    try {
      orderData['status'] = 'Approved';
      await adminOrders.add(orderData);
      await orders.doc(docId).delete();
    } catch (e) {
      print('Error approving order: $e');
    }
  }

  Future<void> rejectOrder(String docId, Map<String, dynamic> orderData) async {
    try {
      orderData['status'] = 'Rejected';
      await adminOrders.add(orderData);
      await orders.doc(docId).delete();
    } catch (e) {
      print('Error rejecting order: $e');
    }
  }
}