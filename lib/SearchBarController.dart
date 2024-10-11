import 'package:get/get.dart';
import 'models/property_listing.dart';

class SearchResultController extends GetxController {
  var searchResult = <PropertyListing>[].obs;
  var searchResultUnfiltered = <PropertyListing>[].obs;
  var filterData = Rxn<Map<String, dynamic>>();
  var location = ''.obs;
  var locationLat = Rxn<double>();
  var locationLong = Rxn<double>();

  void updateSearchResult(List<PropertyListing> newResults) {
    searchResult.value = newResults;
    update();
  }

  void updateSearchResultUnfiltered(List<PropertyListing> newResults) {
    searchResultUnfiltered.value = newResults;
    update();
  }

  void updateFilterData(Map<String, dynamic>? newFilterData) {
    filterData.value = newFilterData;
    update();
  }

  void updateLocation(String newLocation) {
    location.value = newLocation;
    update();
  }

  void updateLocationLat(double? lat) {
    locationLat.value = lat;
    update();
  }
  void updateLocationLong(double? long) {
    locationLong.value = long;
    update();
  }
}
