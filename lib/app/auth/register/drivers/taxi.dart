import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Gocab/utils/state_of_countries.dart';
import 'package:Gocab/services/driver_registration.dart';
import 'package:Gocab/helper/alertbox.dart';

class TaxiDriverRegistrationPage extends StatefulWidget {
  final Drivers drivers = Drivers();
  final AlertBox alertbox = AlertBox();

  @override
  _TaxiDriverRegistrationPageState createState() =>
      _TaxiDriverRegistrationPageState();
}

class _TaxiDriverRegistrationPageState
    extends State<TaxiDriverRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController identityController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController vehicleInfoController = TextEditingController();
  final TextEditingController licensePlateController =
      TextEditingController(); // Added license plate controller

  File? selectedFile;
  String? selectedCountry; // Initialize with null
  String? selectedState;

  List<String> getStatesByCountry(String country) {
    switch (country) {
      case 'Nigeria':
        return nigeriaStates;
      case 'Ghana':
        return ghanaStates;
      case 'Kenya':
        return kenyaStates;
      case 'Uganda':
        return ugandaStates;
      default:
        return [];
    }
  }

  void submitNewTaxiDriverDetais() {
    String name = nameController.text;
    String email = emailAddressController.text;
    String meansOfIdentity = identityController.text;
    String phoneNumber = phoneNumberController.text;
    String vehicleInformation = vehicleInfoController.text;
    String licensePlate = licensePlateController.text;
    String location = locationController.text;
    File? documents = selectedFile;

    print(name);
    print("hello");

    // Check if any of the required fields are null or empty
    if (name.isEmpty ||
        email.isEmpty ||
        meansOfIdentity.isEmpty ||
        phoneNumber.isEmpty ||
        vehicleInformation.isEmpty ||
        licensePlate.isEmpty ||
        location.isEmpty ||
        documents == null ||
        selectedCountry == null ||
        selectedState == null) {
      // Display an error message or perform appropriate error handling
      widget.alertbox.showAlertDialog(context, "Incomplete Details",
          "please fill your information currently before submit");
      return;
    }

    // Call the registerTaxiDriver method on the drivers instance
    widget.drivers.registerTaxiDriver(
      name,
      email,
      phoneNumber,
      vehicleInformation,
      location,
      selectedCountry!,
      selectedState!,
      meansOfIdentity,
      documents,
      licensePlate,
    );

    // Clear the form fields and selected file after successful registration
    // nameController.clear();
    // locationController.clear();
    // licensePlateController.clear();
    // setState(() {
    //   selectedFile = null;
    // });
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    identityController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    vehicleInfoController.dispose();
    licensePlateController.dispose(); // Dispose the license plate controller
    super.dispose();
  }

  Future<void> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxi Driver Registration'),
      ),
      body: SingleChildScrollView(
        // Wrap the column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Existing code...

                  TextFormField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: emailAddressController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: vehicleInfoController,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Information',
                      prefixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  // Existing code...
                ],
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: licensePlateController,
                decoration: InputDecoration(
                  labelText: 'License Plate No',
                  prefixIcon: Icon(Icons.car_rental),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_sharp),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue;
                    selectedState = null;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'Select Country',
                    child: Text('Select Country'),
                  ),
                  ...countries.map((String country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                ],
                decoration: InputDecoration(
                  labelText: 'Country',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedState,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedState = newValue;
                  });
                },
                items: selectedCountry != null
                    ? getStatesByCountry(selectedCountry!).map((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList()
                    : null, // Set items to null if no country is selected
                decoration: InputDecoration(
                  labelText: 'State',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: identityController,
                decoration: InputDecoration(
                  labelText: 'Means of Identity',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: InkWell(
                  onTap: _openFilePicker,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Documents',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Icon(Icons.attach_file),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                selectedFile != null ? selectedFile!.path : 'No file selected',
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed:
                    submitNewTaxiDriverDetais, // Call the submitNewTaxiDriverDetais method
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(double.infinity, 48),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
