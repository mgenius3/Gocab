import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:Gocab/utils/state_of_countries.dart';

class DispatchRiderRegistrationPage extends StatefulWidget {
  @override
  _DispatchRiderRegistrationPageState createState() =>
      _DispatchRiderRegistrationPageState();
}

class _DispatchRiderRegistrationPageState
    extends State<DispatchRiderRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController identityController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController vehicleInfoController = TextEditingController();

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

  @override
  void dispose() {
    nameController.dispose();
    identityController.dispose();
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
        title: Text('Dispatch Rider Registration'),
      ),
      body: Padding(
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
              controller: identityController,
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
                selectedFile != null ? selectedFile!.path : 'No file selected'),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String identity = identityController.text;

                nameController.clear();
                identityController.clear();
                setState(() {
                  selectedFile = null;
                });
              },
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all<Size>(
                    Size(double.infinity, 48)), // Adjust the height as needed
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
