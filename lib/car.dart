// car.dart

class Car {
  final String name;
  final String imageUrl;
  final String price;
  final String details;

  Car({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.details,
  });

  // Factory method to create a Car from Firestore document
  factory Car.fromFirestore(Map<String, dynamic> data) {
    return Car(
      name: data['name'],
      imageUrl: data['imageUrl'],
      price: data['price'],
      details: data['details'],
    );
  }
}
