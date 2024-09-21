import 'dart:ffi';

class ServiceProvider {
  late String brand;//name of service rovider
  late String location;//where to find service provide
  late String logo;//service provider logo image path
  late ServiceCat serviceClass;//Decor, dressing etc
  late List<Product> products;
  late double reviews;//service provider overall user review

  ServiceProvider({
    required this.brand,
    required this.location,
    required this.logo,
    required this.products,
    required this.reviews,
    required this.serviceClass,
  });

}

class Product {
  final String name;//name of product
  final List<String> picture;//one or more product pictures
  final String description;//product or service description
  final double price;//product or service price
  final double reviews;//product reviews

  Product(this.picture, this.reviews, {
   required this.name,
   required this.description,
   required this.price,
  });
}


enum ServiceCat{decor,food,dressing,cakes,photos,venues,vendors,music,hairdressing,mc,makeup,events}