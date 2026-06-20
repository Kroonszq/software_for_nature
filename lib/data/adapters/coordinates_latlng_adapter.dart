import 'package:latlong2/latlong.dart';
import 'package:software_for_nature/data/models/coordinates.dart';

extension CoordinatesMapper on Coordinates {
  LatLng get latLng => LatLng(lat, lng);
}

extension LatLngMapper on LatLng {
  Coordinates get coordinates => Coordinates(
    lat: latitude,
    lng: longitude,
  );
}
