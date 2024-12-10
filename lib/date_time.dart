import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/constants.dart';
import 'package:rentwheels/services/searchPage.dart';

class DateTimeSelectionPage extends StatefulWidget {

  const DateTimeSelectionPage({super.key});

  @override
  _DateTimeSelectionPageState createState() => _DateTimeSelectionPageState();
}

class _DateTimeSelectionPageState extends State<DateTimeSelectionPage> {

  /*final List<String> carTypes = ['ALL', 'SUV', 'Sedan', 'Hatchback'];
  String selectedCarType = 'ALL';*/


  DateTime startDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay(hour: 6, minute: 0);
  DateTime endDate = DateTime.now();
  TimeOfDay endTime = TimeOfDay(hour: 6, minute: 0);

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 6, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  /*void _performSearch() {
    // Add logic for the search functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Search button pressed. Implement search logic here.',
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Select Date and Time',
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          //width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row for Start Date and Start Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickDate(context, true),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${startDate.day}-${startDate.month}-${startDate.year}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Time', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickTime(context, true),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startTime.format(context),
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.access_time, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Row for End Date and End Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Date', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickDate(context, false),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${endDate.day}-${endDate.month}-${endDate.year}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Time', style: TextStyle(fontSize: 14)),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _pickTime(context, false),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endTime.format(context),
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.access_time, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //Choose car type drop down menu
              /*SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Car Type',
                  labelStyle: GoogleFonts.mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kPrimaryColor, width: 2), // Highlighted color
                  ),
                ),
                dropdownColor: Colors.white,
                value: selectedCarType, // Default value is 'ALL'
                items: carTypes.map((carType) {
                  return DropdownMenuItem(
                    value: carType,
                    child: Text(
                      carType,
                      style: GoogleFonts.mulish(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                icon: Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                menuMaxHeight: 200,
                onChanged: (newValue) {
                  setState(() {
                    selectedCarType = newValue!;
                  });
                },
              ),*/

              SizedBox(height: 24),
              // Search Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the search page or perform search functionality
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor, // Set the button color
                  foregroundColor: Colors.white, // Set the text color
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'SEARCH',
                  style: GoogleFonts.mulish(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
