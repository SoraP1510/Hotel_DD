import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test3/models/booking_info.dart';
import 'package:test3/screens/Detail.dart';
import 'package:test3/screens/SearchBox.dart';

// StatefulWidget หน้า Home ของแอป
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // เก็บโรงแรมทั้งหมด และโรงแรมที่ถูกกรอง
  List<dynamic> _allHotels = [];
  List<dynamic> _filteredHotels = [];
  BookingInfo? _bookingInfo;

  // กำหนดข้อมูลการจองเริ่มต้น เช่น เช็คอินวันนี้ เช็คเอาท์พรุ่งนี้
  final BookingInfo _defaultBookingInfo = BookingInfo(
    checkIn: DateTime.now(),
    checkOut: DateTime.now().add(const Duration(days: 1)),
    rooms: 1,
    guests: 2,
  );

  @override
  void initState() {
    super.initState();
    _bookingInfo = _defaultBookingInfo; // กำหนดค่า default
    _fetchHotels(); // โหลดข้อมูลโรงแรมจาก backend
  }

  // โหลดข้อมูลโรงแรมทั้งหมด
  Future<void> _fetchHotels() async {
    try {
      final response = await http.get(
        Uri.parse('https://hotel-api-six.vercel.app/hotels'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allHotels = data;
          _filteredHotels = data; // แสดงทั้งหมดตอนเริ่ม
        });
      }
    } catch (e) {
      print("Error fetching hotels: \$e");
    }
  }

  // ฟังก์ชันสำหรับกรองโรงแรมตาม keyword และบันทึกข้อมูลการจอง
  void _filterHotels(String keyword, BookingInfo info) {
    _bookingInfo = info; // อัปเดตข้อมูลการจอง
    final search = keyword.toLowerCase();
    setState(() {
      _filteredHotels = _allHotels.where((hotel) {
        final city = (hotel['city'] ?? '').toString().toLowerCase();
        final province = (hotel['province'] ?? '').toString().toLowerCase();
        return city.contains(search) || province.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        // ใช้ sliver สำหรับ scroll ที่ลื่นไหล
        slivers: [
          const SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            elevation: 1,
            title: Text('Hotel DD', style: TextStyle(color: Colors.black)),
            centerTitle: true,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBoxDelegate(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBox(onSearch: _filterHotels), // กำหนด callback
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Home",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final hotel = _filteredHotels[index];
                  return InkWell(
                    onTap: () {
                      if (_bookingInfo == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please press Search first')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelDetailPage(
                            hotelId: hotel['hotel_id'],
                            bookingInfo: _bookingInfo!,
                          ),
                        ),
                      );
                    },
                    child: HotelCard(hotel: hotel), // สร้างการ์ดโรงแรม
                  );
                },
                childCount: _filteredHotels.length, // จำนวนโรงแรมที่กรองได้
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // แสดง 2 คอลัมน์
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Delegate ของ SliverPersistentHeader สำหรับแสดง SearchBox
class _SearchBoxDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SearchBoxDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      color: Colors.white,
      child: child,
    );
  }

  @override
  double get maxExtent => 268;
  @override
  double get minExtent => 268;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

// วิดเจ็ตการ์ดแสดงข้อมูลโรงแรม
class HotelCard extends StatelessWidget {
  final dynamic hotel;
  const HotelCard({super.key, required this.hotel});

  // คำนวณค่าเฉลี่ยดาวจากรีวิว
  double _averageRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0;
    double sum = 0;
    for (var r in reviews) {
      final rating = r['rating'];
      if (rating != null) sum += rating.toDouble();
    }
    return sum / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final reviews = hotel['reviews'] ?? [];
    final avgRating = _averageRating(reviews);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพโรงแรม
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              image: hotel['hotel_image'] != null && hotel['hotel_image'] != ""
                  ? DecorationImage(
                      image: NetworkImage(hotel['hotel_image']),
                      fit: BoxFit.cover)
                  : null,
            ),
            child: hotel['hotel_image'] == null || hotel['hotel_image'] == ""
                ? const Center(child: Icon(Icons.image, color: Colors.grey))
                : null,
          ),

          // ข้อมูลโรงแรม
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel['hotel_name'] ?? 'No name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // ที่อยู่
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${hotel['city'] ?? 'Unknown'}, ${hotel['province'] ?? ''}",
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // รีวิว
                reviews.isNotEmpty
                    ? Row(
                        children: [
                          const Icon(Icons.star,
                              size: 12,
                              color: Color.fromARGB(255, 255, 131, 218)),
                          const SizedBox(width: 4),
                          Text(avgRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text("· ${reviews.length} reviews",
                              style: const TextStyle(fontSize: 12)),
                        ],
                      )
                    : const Text("No reviews", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
