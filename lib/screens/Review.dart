import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../session_manager.dart';

class ReviewPage extends StatefulWidget {
  final int hotelId;
  const ReviewPage({super.key, required this.hotelId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool _isLoading = false;
  List<dynamic> _reviews = [];
  List<dynamic> _users = [];

  // ตัวแปรสำหรับฟอร์มรีวิว
  final TextEditingController _commentCtrl = TextEditingController();
  int _selectedStars = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviewsAndUsers();
  }

  /// ดึงข้อมูลรีวิวทั้งหมด + ผู้ใช้ทั้งหมด จาก API
  /// แล้วกรองมาเฉพาะรีวิวที่ hotel_id = widget.hotelId
  Future<void> _fetchReviewsAndUsers() async {
    setState(() => _isLoading = true);

    try {
      // 1) ดึงข้อมูลรีวิว
      final reviewRes = await http.get(Uri.parse('https://hotel-api-six.vercel.app/reviews'));
      if (reviewRes.statusCode == 200) {
        final List<dynamic> allReviews = json.decode(reviewRes.body);
        // กรองเฉพาะของโรงแรมนี้
        _reviews = allReviews.where((r) => r['hotel_id'] == widget.hotelId).toList();
      }

      // 2) ดึงข้อมูลผู้ใช้
      final userRes = await http.get(Uri.parse('https://hotel-api-six.vercel.app/users'));
      if (userRes.statusCode == 200) {
        _users = json.decode(userRes.body);
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  /// ฟังก์ชันส่งรีวิวใหม่ (POST ไปที่ /reviews)
  Future<void> _submitReview() async {
    // เช็คว่าล็อกอินหรือยัง
    if (SessionManager.currentUser == null) {
      _showNeedLoginDialog();
      return;
    }
    if (_selectedStars == 0 || _commentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select stars and enter a comment.")),
      );
      return;
    }

    try {
      // user_id จาก session
      final userId = SessionManager.currentUser!['user_id'];
      // สร้างรีวิวใหม่
      final newReview = {
        "hotel_id": widget.hotelId,
        "user_id": userId,
        "rating": _selectedStars,         // 1-5
        "comment": _commentCtrl.text,
      };

      await http.post(
        Uri.parse('https://hotel-api-six.vercel.app/reviews'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newReview),
      );

      // ไม่เช็ค statusCode ให้ตรงนี้เลยว่า post สำเร็จ
       _selectedStars = 0;
       _commentCtrl.clear();
      await _fetchReviewsAndUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully!")),
      );
    } catch (e) {
      print("Submit review error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// หากยังไม่ล็อกอิน จะแจ้งเตือนให้ Sign In
  void _showNeedLoginDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Require Sign In"),
        content: const Text("You must sign in before leaving a review."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // อาจไปหน้า Sign In ก็ได้
              // Navigator.push(...);
            },
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }

  /// หา user ตาม user_id ของรีวิว เพื่อเอา fname มาแสดง
  Map<String, dynamic>? _getUserById(int uid) {
    return _users.firstWhere(
      (u) => u['user_id'] == uid,
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        leading: const BackButton(),
      ),
      backgroundColor: Colors.grey[300],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryBox(),
                  const SizedBox(height: 16),

                  // ถ้ายังไม่ล็อกอิน => ไม่ต้องแสดงฟอร์ม
                  if (SessionManager.currentUser != null) _buildReviewForm(),

                  const SizedBox(height: 16),

                  // รายการรีวิว
                  if (_reviews.isEmpty)
                    const Text("No reviews yet.")
                  else
                    Column(
                      children: _reviews.map((r) => _buildReviewItem(r)).toList(),
                    ),
                ],
              ),
            ),
    );
  }

  /// แสดงภาพรวมของรีวิว (จำนวนคนรีวิว, ค่าเฉลี่ยดาว)
  Widget _buildSummaryBox() {
    final count = _reviews.length;
    double sum = 0;
    for (var r in _reviews) {
      final rating = r['rating'] ?? 0;
      sum += (rating as num).toDouble();
    }
    final avg = (count == 0) ? 0 : sum / count;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text("Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text("$count Review(s)", style: const TextStyle(color: Colors.pinkAccent)),
          Text(avg.toStringAsFixed(1)), // ค่าเฉลี่ยดาว
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < avg.round() ? Icons.star : Icons.star_border,
                color: Colors.pinkAccent,
              );
            }),
          ),
        ],
      ),
    );
  }

  /// ฟอร์มสำหรับพิมพ์คอมเมนต์ + เลือกจำนวนดาว
  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
      ),
      child: Column(
        children: [
          // เลือกดาว 1-5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => IconButton(
              icon: Icon(
                index < _selectedStars ? Icons.star : Icons.star_border,
                color: Colors.pinkAccent,
              ),
              onPressed: () {
                setState(() {
                  _selectedStars = index + 1;
                });
              },
            )),
          ),
          const SizedBox(height: 12),

          // ช่อง comment
          TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(hintText: "Leave a comment"),
            maxLines: 2,
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCCAFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Send"),
            ),
          ),
        ],
      ),
    );
  }

  /// สร้าง widget แสดงรีวิวแต่ละรายการ
  Widget _buildReviewItem(dynamic review) {
    final int rating = review['rating'] ?? 0;
    final String comment = review['comment'] ?? '';
    final int userId = review['user_id'] ?? 0;

    final user = _getUserById(userId);
    final String fname = user == null ? "Unknown" : user['fname'] ?? "Unknown";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่อผู้รีวิว + ดาว
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fname, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(rating, (index) => const Icon(Icons.star, size: 16, color: Colors.pinkAccent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment),
        ],
      ),
    );
  }
}