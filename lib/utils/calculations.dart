double calculateTotal(List<dynamic> items) {
  return items.fold(0.0, (total, item) {
    return total + ((item['price'] ?? 0.0) * (item['quantity'] ?? 0));
  });
}