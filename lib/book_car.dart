import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/bookinggate.dart';
import 'package:rentwheels/data.dart';
import 'package:rentwheels/constants.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class BookCar extends StatefulWidget {
  final Car car;

  const BookCar({super.key, required this.car});

  @override
  State<BookCar> createState() => _BookCarState();
}

class _BookCarState extends State<BookCar> {
  int _currentImage = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<Widget> buildPageIndicator() {
    List<Widget> list = [];
    for (var i = 0; i < widget.car.images.length; i++) {
      list.add(buildIndicator(i == _currentImage));
    }
    return list;
  }

  Widget buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 6),
      height: 8,
      width: isActive ? 20 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _startTime = pickedTime;
      });
    }
  }

  Future<void> _selectEndTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  String formatDateTime() {
    if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      return "Select start & end date and time";
    }

    final formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate!);
    final formattedStartTime = _startTime!.format(context);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(_endDate!);
    final formattedEndTime = _endTime!.format(context);
    
    return 'Start: $formattedStartDate at $formattedStartTime\nEnd: $formattedEndDate at $formattedEndTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(  // Make the whole page scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image carousel and navigation with animation effect
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_left,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.car.model,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.car.brand,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Car images carousel with fade-in/out animation
                    SizedBox(
                      height: 250,
                      child: PageView(
                        physics: BouncingScrollPhysics(),
                        onPageChanged: (int page) {
                          setState(() {
                            _currentImage = page;
                          });
                        },
                        children: widget.car.images.map((path) {
                          return AnimatedOpacity(
                            opacity: _currentImage == widget.car.images.indexOf(path) ? 1.0 : 0.5,
                            duration: Duration(milliseconds: 300),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Hero(
                                tag: widget.car.model,
                                child: Image.asset(
                                  path,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    widget.car.images.length > 1
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: buildPageIndicator(),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Car specifications section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Specifications",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Brand: ${widget.car.brand}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Model: ${widget.car.model}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Fuel Type: ${widget.car.fuelType}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Transmission: ${widget.car.transmission}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Seats: ${widget.car.seats}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      "Car Type: ${widget.car.carType}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 8,)
                  ],
                ),
              ),

              // New section for date and time selection
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Start & End Date and Time",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _selectStartDate,
                          child: Text("Start Date"),
                        ),
                        ElevatedButton(
                          onPressed: _selectEndDate,
                          child: Text("End Date"),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _selectStartTime,
                          child: Text("Start Time"),
                        ),
                        ElevatedButton(
                          onPressed: _selectEndTime,
                          child: Text("End Time"),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                       formatDateTime(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "₹${widget.car.price} per day",
                      style: GoogleFonts.mulish(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingGateway(
                      car: widget.car,
                      basePrice: widget.car.price,
                    ),
                  ),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Book this car",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}