import 'package:flutter/material.dart';
import 'package:rentwheels/data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/constants.dart';
import 'package:rentwheels/car_widget.dart';
import 'package:rentwheels/available_cart.dart';
import 'package:rentwheels/book_car.dart';
import 'package:rentwheels/dealer_widget.dart';
import 'package:rentwheels/profile.dart';
import 'package:rentwheels/date_time.dart';
import 'package:rentwheels/notification.dart';

class Showroom extends StatefulWidget {
  const Showroom({super.key});

  @override
  State<Showroom> createState() => _ShowroomState();
}

class _ShowroomState extends State<Showroom> {
  /*List<NavigationItem> navigationItems = getNavigationItemList();
  late NavigationItem selectedItem;*/

  List<Car> cars = getCarList();
  List<Dealer> dealers = getDealerList();
  List<carType> carTypes = getCarTypeList();

  /*@override
  void initState() {
    super.initState();
    setState(() {
      selectedItem = navigationItems[0];
    });

  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        //brightness: Brightness.light,
        title: Text(
          "RentWheels",
          style: GoogleFonts.mulish(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications,
                    color: Colors.black,
                    size: 28,
                  ),
                  // Badge for unread notifications
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '3', // Replace with a variable to show the count dynamically
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile(),)
                );
              },
              child: Icon(
                Icons.person,
                color: Colors.black,
                size: 28,
              ),
            )
          ),
          Padding(padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(
                  context,
                );
              },
              child: Icon(
                Icons.home,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  // Navigate to the DateTimeSelectionPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DateTimeSelectionPage()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.only(left: 30, right: 24, top: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Date & Time",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [

                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              "TOP CARS",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],

                              ),
                            ),

                          ],
                        ),
                      ),

                      SizedBox(
                        height: 280,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: buildDeals(),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AvailableCars()),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 16, right: 16, left: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            padding: EdgeInsets.all(24),
                            height: 110,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    Text(
                                      "View All",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),

                                    ),

                                    Text(
                                      "Cars",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),

                                    ),


                                  ],
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      )
                                  ),
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: kPrimaryColor,

                                    ),
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              "CHOOSE BY CAR TYPE",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],

                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 150,
                        margin: EdgeInsets.only(bottom: 16),
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: buildCarTypeList(),
                        ),
                      ),

                    ],
                  ),
                ),
              )
          )

        ],
      ),
    );
  }

  List<Widget> buildDeals() {
    List<Widget> list = [];
    for(var i = 0; i <cars.length; i++) {
      list.add(
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookCar(car : cars[i])),
                );
              },
              child: buildCar(cars[i], i))
      );
    }
    return list;
  }

  List<Widget> buildCarTypeList() {
  List<Widget> list = [];
  for (var i = 0; i < carTypes.length; i++) {
    list.add(buildCarType(carTypes[i], i)); // Pass each `carType` object and its index
  }
  return list;
}


  /*List<Widget> buildNavigationItems() {
    List<Widget> list = [];
    for(var i = 0; i <navigationItems.length; i++) {
      list.add(buildNavigationItem(navigationItems[i]));
    }
    return list;
  }*/

  /*Widget buildNavigationItem(NavigationItem item) {
    return GestureDetector(
      onTap: (){
        setState(() {
          selectedItem = item;
          Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(item: item)),);
        });
      },
      child: SizedBox(
        width: 50,
        child: Stack(
          children:[
            Center(
              child: Icon(
                item.iconData,
                color:Colors.grey[400],
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }*/
}