import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../SearchBarController.dart';
import '../models/boolean_variable.dart';
import '../models/property_listing.dart';

class Filterpanel extends StatefulWidget {
  Filterpanel({super.key});
  @override
  _Filterpanelstate createState() => _Filterpanelstate();
}

class _Filterpanelstate extends State<Filterpanel> {
  late SearchResultController searchResultController;
  @override
  void initState() {
    super.initState();

    searchResultController = Get.find<SearchResultController>();

    late Map<String, dynamic>? filterData;
    filterData = searchResultController.filterData.value;

    if (filterData != null && filterData!.isNotEmpty) {
      final data = filterData;

      _minPriceController.text = data!['min_price']?.toString() ?? '';
      _maxPriceController.text = data['max_price']?.toString() ?? '';

      gender = (data['sex_preference'] == "male" || data['sex_preference'] == "female")
          ? data['sex_preference']
          : "no preference";
      _genderController.text = gender;

      nationality = (data['nationality_preference'] == "malaysian" || data['nationality_preference'] == "non-malaysian")
          ? data['nationality_preference']
          : "no preference";
      _nationalityController.text = nationality;

      room_type = data['room_type'] ?? '';
      isMasterRoom = room_type == 'master';
      isSingleRoom = room_type == 'single';
      isSharedRoom = room_type == 'shared';
      isSuite = room_type == 'suite';

      List<BooleanVariable> amenities = data['amenities'] ?? [];
      for (var amenity in amenities) {
        switch (amenity.name) {
          case 'isWifiAccess':
            isWifiAccess = amenity.value;
            break;
          case 'isAirCon':
            isAirCon = amenity.value;
            break;
          case 'isNearMarket':
            isNearMarket = amenity.value;
            break;
          case 'isCarPark':
            isCarPark = amenity.value;
            break;
          case 'isNearMRT':
            isNearMRT = amenity.value;
            break;
          case 'isNearLRT':
            isNearLRT = amenity.value;
            break;
          case 'isPrivateBathroom':
            isPrivateBathroom = amenity.value;
            break;
          case 'isGymnasium':
            isGymnasium = amenity.value;
            break;
          case 'isCookingAllowed':
            isCookingAllowed = amenity.value;
            break;
          case 'isWashingMachine':
            isWashingMachine = amenity.value;
            break;
          case 'isNearBusStop':
            isNearBusStop = amenity.value;
            break;
        }
      }
    }
  }

  String room_type = "";
  String gender = "no preference";
  String nationality = "no preference";
  final GlobalKey<FormFieldState> _genderKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _nationalityKey = GlobalKey<FormFieldState>();

  // room type
  bool isMasterRoom = false;
  bool isSingleRoom = false;
  bool isSharedRoom = false;
  bool isSuite = false;

  // ammenities
  bool isWifiAccess = false;
  bool isAirCon = false;
  bool isNearMarket = false;
  bool isCarPark = false;
  bool isNearMRT = false;
  bool isNearLRT = false;
  bool isPrivateBathroom = false;
  bool isGymnasium = false;
  bool isCookingAllowed = false;
  bool isWashingMachine = false;
  bool isNearBusStop = false;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView(
        children: [
          PriceFilter(),
          RoomTypeFilter(),
          PreferenceFilter(),
          AmenitiesFilter(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isMasterRoom = false;
            isSingleRoom = false;
            isSharedRoom = false;
            isSuite = false;
            isWifiAccess = false;
            isAirCon = false;
            isNearMarket = false;
            isCarPark = false;
            isNearMRT = false;
            isNearLRT = false;
            isPrivateBathroom = false;
            isGymnasium = false;
            isCookingAllowed = false;
            isWashingMachine = false;
            isNearBusStop = false;
            _minPriceController.clear();
            _maxPriceController.clear();
            _genderController.text = "no preference";
            _nationalityController.text = "no preference";
            room_type="";
            gender = "no preference";
            nationality = "no preference";
            _genderKey.currentState?.reset();
            _nationalityKey.currentState?.reset();

          });
        },
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
    );
  }

  Column AmenitiesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "Amenities",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Wifi Access"),
                value: isWifiAccess,
                onChanged: (value) {
                  setState(() {
                    isWifiAccess = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Private Bathroom"),
                value: isPrivateBathroom,
                onChanged: (value) {
                  setState(() {
                    isPrivateBathroom = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Gymnasium"),
                value: isGymnasium,
                onChanged: (value) {
                  setState(() {
                    isGymnasium = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Air Con"),
                value: isAirCon,
                onChanged: (value) {
                  setState(() {
                    isAirCon = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Near Market"),
                value: isNearMarket,
                onChanged: (value) {
                  setState(() {
                    isNearMarket = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Cooking Allowed"),
                value: isCookingAllowed,
                onChanged: (value) {
                  setState(() {
                    isCookingAllowed = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Near LRT"),
                value: isNearLRT,
                onChanged: (value) {
                  setState(() {
                    isNearLRT = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Near Bus Stop"),
                value: isNearBusStop,
                onChanged: (value) {
                  setState(() {
                    isNearBusStop = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Car Park"),
                value: isCarPark,
                onChanged: (value) {
                  setState(() {
                    isCarPark = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Washing Machine"),
                value: isWashingMachine,
                onChanged: (value) {
                  setState(() {
                    isWashingMachine = value!;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Near MRT"),
                value: isNearMRT,
                onChanged: (value) {
                  setState(() {
                    isNearMRT = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column PreferenceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 5),
          child: Text(
            "Preference",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: _genderKey,
                  value: gender,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Gender",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: "male", child: Text("Male")),
                    DropdownMenuItem(value: "female", child: Text("Female")),
                    DropdownMenuItem(value: "no preference", child: Text("No Preference")),
                  ],
                  onChanged: (selectedGender) {
                    gender = selectedGender ?? "no preference";
                    _genderController.text = selectedGender ?? "no preference";
                  },
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: _nationalityKey,
                  value: nationality,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Nationality",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: "malaysian", child: Text("Malaysian")),
                    DropdownMenuItem(
                        value: "non-malaysian", child: Text("Non Malaysian")),
                    DropdownMenuItem(value: "no preference", child: Text("No Preference")),
                  ],
                  onChanged: (selectedNationality) {
                    nationality = selectedNationality ?? "no preference";
                    _nationalityController.text = selectedNationality ?? "no preference";
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Column RoomTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "Room Type",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Master Room"),
                value: isMasterRoom,
                onChanged: (value) {
                  setState(() {
                    isMasterRoom = value!;
                    room_type = "master";
                    isSingleRoom = false;
                    isSuite = false;
                    isSharedRoom = false;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Single Room"),
                value: isSingleRoom,
                onChanged: (value) {
                  setState(() {
                    isSingleRoom = value!;
                    room_type = "single";
                    isMasterRoom = false;
                    isSharedRoom = false;
                    isSuite = false;

                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Shared Room"),
                value: isSharedRoom,
                onChanged: (value) {
                  setState(() {
                    isSharedRoom = value!;
                    room_type = "shared";
                    isMasterRoom = false;
                    isSingleRoom = false;
                    isSuite = false;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Suite"),
                value: isSuite,
                onChanged: (value) {
                  setState(() {
                    isSuite = value!;
                    room_type = "suite";
                    isMasterRoom = false;
                    isSingleRoom = false;
                    isSharedRoom = false;
                  });
                },
              ),
            )
          ],
        ),
      ],
    );
  }

  Column PriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 5),
          child: Text(
            "Price",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding:
          const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  decoration: InputDecoration(
                    labelText: "Min Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  decoration: InputDecoration(
                    labelText: "Max Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        "Filter",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        TextButton(
          onPressed: () {

            final filterData = {
              "min_price": double.tryParse(_minPriceController.text) ?? 0.0,
              "max_price": double.tryParse(_maxPriceController.text) ?? double.infinity,
              "sex_preference": _genderController.text.isNotEmpty
                  ? _genderController.text
                  : "no preference",
              "nationality_preference": _nationalityController.text.isNotEmpty
                  ? _nationalityController.text
                  : "no preference",
              "room_type": room_type,
              "amenities": [
                BooleanVariable(name: "isWifiAccess", value: isWifiAccess),
                BooleanVariable(name: "isAirCon", value: isAirCon),
                BooleanVariable(name: "isNearMarket", value: isNearMarket),
                BooleanVariable(name: "isCarPark", value: isCarPark),
                BooleanVariable(name: "isNearMRT", value: isNearMRT),
                BooleanVariable(name: "isNearLRT", value: isNearLRT),
                BooleanVariable(name: "isPrivateBathroom", value: isPrivateBathroom),
                BooleanVariable(name: "isGymnasium", value: isGymnasium),
                BooleanVariable(name: "isCookingAllowed", value: isCookingAllowed),
                BooleanVariable(name: "isWashingMachine", value: isWashingMachine),
                BooleanVariable(name: "isNearBusStop", value: isNearBusStop),
              ]
            };
            final searchResult = searchResultController.searchResultUnfiltered.value;

            print("search result length: ${searchResult.length}");

            List<PropertyListing> filteredResults = [];

            for (PropertyListing listing in searchResult) {
              bool shouldAddListing = true;

              double minPrice = filterData["min_price"] as double;
              double maxPrice = filterData["max_price"] as double;

              if (listing.price < minPrice || listing.price > maxPrice) {
                developer.log("Filtered by price");
                shouldAddListing = false;
              }

              String preferredNationality = filterData["nationality_preference"] as String;
              if (preferredNationality != "no preference" &&
                  listing.nationality_preference != preferredNationality) {
                developer.log("Filtered by nationality");
                shouldAddListing = false;
              }

              String preferredSex = filterData["sex_preference"] as String;
              if (preferredSex != "no preference" &&
                  listing.sex_preference != preferredSex) {
                developer.log("Filtered by sex");
                shouldAddListing = false;
              }

              String preferredRoomType = filterData["room_type"] as String;
              if (preferredRoomType.isNotEmpty && listing.room_type != preferredRoomType) {
                developer.log("Filtered by room type");
                shouldAddListing = false;
              }

              List<BooleanVariable> requiredAmenities = List<BooleanVariable>.from(filterData["amenities"] as List<dynamic>);
              for (var amenity in requiredAmenities) {
                if (amenity.value) {
                  var listingAmenity = listing.amenities.firstWhere(
                        (element) => element.name == amenity.name,
                    orElse: () => BooleanVariable(name: amenity.name, value: false),
                  );
                  if (!listingAmenity.value) {
                    developer.log("Filtered out by missing amenity: ${amenity.name}");
                    shouldAddListing = false;
                    break;
                  }
                }
              }
              if (shouldAddListing) {
                filteredResults.add(listing);
              }
            }
            searchResultController.updateSearchResult(filteredResults);
            searchResultController.updateFilterData(filterData);
          },
          child: Text("Confirm"),
        )
      ],
    );
  }
}
