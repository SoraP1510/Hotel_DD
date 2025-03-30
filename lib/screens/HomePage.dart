import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test3/screens/Detail.dart';
import 'package:test3/screens/SearchBox.dart'; // ต้องใช้ตัวใหม่ที่รับ onSearch

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _allHotels = [];
  List<dynamic> _filteredHotels = [];

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    try {
      final response = await http.get(
        Uri.parse('https://hotel-api-six.vercel.app/hotels'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allHotels = data;
          _filteredHotels = data;
        });
      } else {
        print("Failed to load hotels: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching hotels: $e");
    }
  }

  void _filterHotels(String keyword) {
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBox(onSearch: _filterHotels), // ✅ ส่งฟังก์ชันเข้าไป
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HotelDetailPage(),
                        ),
                      );
                    },
                    child: HotelCard(hotel: hotel),
                  );
                },
                childCount: _filteredHotels.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
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

// เหมือนเดิม
class _SearchBoxDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SearchBoxDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class HotelCard extends StatelessWidget {
  final dynamic hotel;
  const HotelCard({super.key, required this.hotel});

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปโรงแรม
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
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hotel['hotel_image'] == null || hotel['hotel_image'] == ""
                ? const Center(child: Icon(Icons.image, color: Colors.grey))
                : null,
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel['hotel_name'] ?? 'No name',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${hotel['city'] ?? 'Unknown'}, ${hotel['province'] ?? ''}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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