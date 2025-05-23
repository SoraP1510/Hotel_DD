// import ที่จำเป็น
import 'package:flutter/material.dart';
import 'package:test3/models/booking_info.dart';
import 'package:test3/screens/Payment.dart';
import 'package:test3/screens/Review.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test3/session_manager.dart';

// stateful widget สำหรับหน้าแสดงรายละเอียดโรงแรม
class HotelDetailPage extends StatefulWidget {
  final int hotelId; // รหัสโรงแรม
  final BookingInfo bookingInfo; // ข้อมูลการจองที่ส่งมาจากหน้าอื่น

  const HotelDetailPage({
    super.key,
    required this.hotelId,
    required this.bookingInfo,
  });

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  List<dynamic> _rooms = []; // รายการห้องของโรงแรม
  double? _latitude; // ละติจูดของโรงแรม
  double? _longitude; // ลองจิจูดของโรงแรม
  String? _hotelName; // ชื่อโรงแรม
  String? _imageUrl; // รูปภาพโรงแรม
  String? _description; // รายละเอียดโรงแรม
  int _reviewCount = 0; // จำนวนรีวิว
  String? _city; // เมือง
  String? _province; // จังหวัด
  double? _avgRating; // คะแนนเฉลี่ย

  @override
  void initState() {
    super.initState();
    _fetchHotels(); // โหลดข้อมูลโรงแรม
    _fetchRooms(); // โหลดข้อมูลห้องพัก
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
            orElse: () => {});
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
        }
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
      throw Exception('Failed to fetch availability');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hotelName ?? 'Detail'), // ชื่อโรงแรม
        leading: const BackButton(), // ปุ่ม back
      ),
      body: _hotelName == null
          ? const Center(child: CircularProgressIndicator()) // โหลดอยู่
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูปโรงแรม
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: _imageUrl != null && _imageUrl != ""
                          ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: (_imageUrl == null || _imageUrl == "")
                        ? const Center(child: Icon(Icons.image, size: 60))
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ชื่อโรงแรม + ปุ่มดูรีวิว
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReviewPage(hotelId: widget.hotelId),
                              ));
                        },
                        child: Text("$_reviewCount Review",
                            style: const TextStyle(
                                color: Colors.pinkAccent,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  if (_avgRating != null)
                    _buildStarRating(_avgRating!), // ดาวให้คะแนน

                  const Divider(height: 32),

                  // รายละเอียดโรงแรม
                  Text(_description ?? 'No description',
                      style: const TextStyle(fontSize: 14)),

                  const SizedBox(height: 16),

                  // แผนที่ตำแหน่งโรงแรม
                  const Text("Location",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: hasLocation
                        ? FlutterMap(
                            options: MapOptions(
                                center: LatLng(_latitude!, _longitude!),
                                zoom: 15.0),
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

                  // แท็ก
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

                  // รายการห้อง
                  ..._rooms.map((room) => _roomItem(context, room)),
                ],
              ),
            ),
    );
  }

  // แสดงรายการห้องแต่ละห้อง
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
            //เช็กใช้ล็อกอิน
            if (SessionManager.currentUser == null) {
              //แจ้งเตือนให้ไปล็อกอินก่อน
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("กรุณาล็อกอินก่อนทำการจอง")),
              );
              return;
            }

            //ถ้าล็อกอินไปหน้า PaymentPage
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  roomType: roomType,
                  roomPrice: priceValue,
                  roomImageUrl: roomImageUrl,
                  bookingInfo: BookingInfo(
                    checkIn: widget.bookingInfo.checkIn,
                    checkOut: widget.bookingInfo.checkOut,
                    rooms: widget.bookingInfo.rooms,
                    guests: widget.bookingInfo.guests,
                    hotelId: widget.hotelId,
                    roomId: room['room_id'],
                    userId: SessionManager
                        .currentUser!['user_id'], // ✅ เชื่อม user_id
                  ),
                ),
              ),
            );

            if (result == 'refresh') {
              _fetchRooms();
            }
          },
          child: const Text("Book now"),
        ),
      ),
    );
  }
}

// ฟังก์ชันแสดงดาวคะแนนเฉลี่ย
Widget _buildStarRating(double avgRating) {
  int fullStars = (avgRating).floor();
  bool hasHalfStar = (avgRating) % 1 >= 0.5;
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
