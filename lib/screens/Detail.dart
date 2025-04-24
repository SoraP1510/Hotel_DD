import 'package:flutter/material.dart';
import 'package:test3/models/booking_info.dart';
import 'package:test3/screens/Payment.dart';
import 'package:test3/screens/Review.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test3/session_manager.dart';

class HotelDetailPage extends StatefulWidget {
  final int hotelId;
  final BookingInfo bookingInfo;
  const HotelDetailPage(
      {super.key, required this.hotelId, required this.bookingInfo});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  List<dynamic> _rooms = [];
  double? _latitude;
  double? _longitude;
  String? _hotelName;
  String? _imageUrl;
  String? _description;
  int _reviewCount = 0;
  String? _city;
  String? _province;
  double? _avgRating;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://hotel-api-six.vercel.app/rooms/hotel/${widget.hotelId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _rooms = data;
        });
      } else {
        print("Failed to load rooms: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching rooms: $e");
    }
  }

  Future<void> _fetchHotels() async {
    try {
      final response =
          await http.get(Uri.parse('https://hotel-api-six.vercel.app/hotels'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hotels = (data as List).cast<Map<String, dynamic>>();

        final hotel = hotels.firstWhere(
          (item) => item['hotel_id'] == widget.hotelId,
          orElse: () => {},
        );

        if (hotel.isNotEmpty) {
          final reviews = hotel['reviews'] ?? [];
          double sum = 0;
          for (var r in reviews) {
            final rating = double.tryParse(r['rating'].toString()) ?? 0;
            sum += rating;
          }
          setState(() {
            _avgRating = reviews.isNotEmpty ? sum / reviews.length : 0;
            _reviewCount = reviews.length;
            _latitude = double.tryParse(hotel['latitude'].toString());
            _longitude = double.tryParse(hotel['longitude'].toString());
            _hotelName = hotel['hotel_name'];
            _imageUrl = hotel['hotel_image'];
            _description = hotel['description'];
            _city = hotel['city'];
            _province = hotel['province'];
          });
        } else {
          print("Hotel not found.");
        }
      } else {
        print("Failed to load hotels: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching hotels: $e");
    }
  }

  Future<int> _fetchAvailableRooms(String roomId, String date) async {
    final url = Uri.parse(
        'https://hotel-api-six.vercel.app/booking/check-availability?room_id=$roomId&date=$date');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['available'] ?? 0;
    } else {
      print('Failed to fetch availability: ${response.statusCode}');
      throw Exception('Failed to fetch availability');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hotelName ?? 'Detail'),
        leading: const BackButton(),
      ),
      body: _hotelName == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: _imageUrl != null && _imageUrl != ""
                          ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (_imageUrl == null || _imageUrl == "")
                        ? const Center(child: Icon(Icons.image, size: 60))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _hotelName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReviewPage(hotelId: widget.hotelId),
                            ),
                          );
                        },
                        child: Text(
                          "$_reviewCount Review",
                          style: const TextStyle(
                            color: Colors.pinkAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_avgRating != null) _buildStarRating(_avgRating!),
                  const Divider(height: 32),
                  Text(_description ?? 'No description',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  const Text("Location",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: hasLocation
                        ? FlutterMap(
                            options: MapOptions(
                              center: LatLng(_latitude!, _longitude!),
                              zoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: LatLng(_latitude!, _longitude!),
                                    child: const Icon(Icons.location_pin,
                                        color: Colors.red, size: 40),
                                  )
                                ],
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: 16),
                  const Text("Tag",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_city != null) Chip(label: Text('#$_city')),
                      if (_province != null) Chip(label: Text('#$_province')),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text("Room",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._rooms.map((room) => _roomItem(context, room)),
                ],
              ),
            ),
    );
  }

  Widget _roomItem(BuildContext context, dynamic room) {
    final roomType = room['room_type'] ?? 'Room';
    final roomImageUrl = room['room_image'];
    final priceValue = double.tryParse(room['room_price'].toString()) ?? 0;
    final priceText = '฿${priceValue.toStringAsFixed(2)}';
    final checkInDate =
        widget.bookingInfo.checkIn.toIso8601String().substring(0, 10);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            image: roomImageUrl != null && roomImageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(roomImageUrl), fit: BoxFit.cover)
                : null,
          ),
          child: (roomImageUrl == null || roomImageUrl.isEmpty)
              ? const Center(child: Icon(Icons.image))
              : null,
        ),
        title: Text(roomType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(priceText),
            FutureBuilder<int>(
              future:
                  _fetchAvailableRooms(room['room_id'].toString(), checkInDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Checking availability...");
                } else if (snapshot.hasError) {
                  print('Availability error: ${snapshot.error}');
                  return const Text("Error loading availability");
                } else {
                  return Text("Available rooms: ${snapshot.data}");
                }
              },
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            final roomId = room['room_id'];
            final numToBook = widget.bookingInfo.rooms;

            final roomResp = await http.get(
                Uri.parse('https://hotel-api-six.vercel.app/rooms/$roomId'));
            if (roomResp.statusCode != 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('โหลดข้อมูลห้องไม่สำเร็จ')));
              return;
            }
            final roomData = jsonDecode(roomResp.body);
            final int roomQty = roomData is List
                ? int.tryParse(roomData[0]['room_qty'].toString()) ?? 0
                : int.tryParse(roomData['room_qty'].toString()) ?? 0;

            final bookingResp = await http
                .get(Uri.parse('https://hotel-api-six.vercel.app/booking'));
            if (bookingResp.statusCode != 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('โหลดข้อมูลการจองไม่สำเร็จ')));
              return;
            }

            final allBookings = jsonDecode(bookingResp.body);
            int totalBooked = 0;
            for (var b in allBookings) {
              if (b['room_id'] == roomId) {
                totalBooked += (b['num_rooms'] as num).toInt();
              }
            }

            if (totalBooked + numToBook > roomQty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('ห้องเต็ม ไม่สามารถจองได้เพิ่มเติม')),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  roomType: room['room_type'],
                  roomPrice: double.parse(room['room_price'].toString()),
                  roomImageUrl: room['room_image'],
                  bookingInfo: BookingInfo(
                    checkIn: widget.bookingInfo.checkIn,
                    checkOut: widget.bookingInfo.checkOut,
                    rooms: numToBook,
                    guests: widget.bookingInfo.guests,
                    hotelId: widget.hotelId,
                    roomId: roomId,
                    userId: SessionManager.currentUser?['user_id'] ?? 0,
                  ),
                ),
              ),
            );
          },
          child: const Text("Book now"),
        ),
      ),
    );
  }
}

Widget _buildStarRating(double avgRating) {
  int fullStars = (avgRating / 2).floor();
  bool hasHalfStar = (avgRating / 2) % 1 >= 0.5;
  int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

  return Row(
    children: [
      for (int i = 0; i < fullStars; i++)
        const Icon(Icons.star,
            color: Color.fromARGB(255, 255, 131, 218), size: 20),
      if (hasHalfStar)
        const Icon(Icons.star_half,
            color: Color.fromARGB(255, 255, 131, 218), size: 20),
      for (int i = 0; i < emptyStars; i++)
        const Icon(Icons.star_border,
            color: Color.fromARGB(255, 255, 131, 218), size: 20),
    ],
  );
}
