import 'package:flutter/material.dart';

class NavigationItem {

  IconData iconData;

  NavigationItem(this.iconData);

}

List<NavigationItem> getNavigationItemList(){
  return <NavigationItem>[
    //NavigationItem(Icons.calendar_today),
    NavigationItem(Icons.person),
  ];
}

class Car {

  String brand;
  String model;
  int price;
  double rate;
  //String rent;
  String fuelType;
  int seats;
  String transmission;

  List<String> images;

  Car(this.brand, this.model, this.price, /*this.rent,*/ this.rate, this.fuelType, this.seats, this.transmission, this.images);

}

List<Car> getCarList(){
  return <Car>[
    Car(
      "Toyota",
      "Fortuner",
      4500,
      //"Monthly",
      4.5,
      "Diesel",
      7,
      "Manual",
      [
        "assets/images/fortuner_0.png",
        "assets/images/fortuner_1.png",
        "assets/images/fortuner_2.png",
        "assets/images/fortuner_3.png",
      ],
    ),
    Car(
      "Hyundai",
      "Creta",
      3200,
      //"Weekly",
      4.0,
      "Diesel",
      5,
      "Manual",
      [
        "assets/images/creta.png",
      ],
    ),
    Car(
      "Maruti",
      "Swift",
      1800,
      //"Daily",
      4.1,
      "Petrol",
      4,
      "Automatic",
      [
        "assets/images/swift.png",
      ],
    ),
    Car(
      "Hyundai",
      "Verna",
      2000,
      //"Daily",
      3.9,
      "Petrol",
      5,
      "Automatic",
      [
        "assets/images/verna.png",
      ],
    ),
  ];
}

class Dealer {

  String name;
  String image;


  Dealer(this.name, this.image);

}

List<Dealer> getDealerList(){
  return <Dealer>[
    Dealer(
      "Toyota",
      "assets/images/toyota.png",
    ),
    Dealer(
      "Suzuki",
      "assets/images/suzuki.png",
    ),
    Dealer(
      "Hyundai",
      "assets/images/hyundai_0.png",
    ),
    Dealer(
      "Tata",
      "assets/images/tata_0.png",
    ),
  ];
}

class carType {
  String car_type;

  String image;

  carType(this.car_type, this.image);
}

List<carType> getCarTypeList(){
  return <carType>[
    carType(
      "SUV",
      "assets/images/suv.png",
    ),
    carType("SEDAN",
      "assets/images/sedan.png",
    ),
    carType("HATCHBACK",
      "assets/images/hatchback.png",
    ),
  ];
}


class Filter {

  String name;

  Filter(this.name);

}

List<Filter> getFilterList(){
  return <Filter>[
    Filter("Highest Price"),
    Filter("Lowest Price"),
  ];
}