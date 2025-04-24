import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test3/models/booking_info.dart';
import 'package:intl/intl.dart';
import 'package:test3/session_manager.dart';

// StatelessWidget สำหรับหน้า Payment
class PaymentPage extends StatelessWidget {
  // รับค่าข้อมูลห้องพัก และข้อมูลการจองมาจากหน้า Detail
  final String roomType;
  final double roomPrice;
  final String? roomImageUrl;
  final BookingInfo bookingInfo;

  const PaymentPage({
    super.key,
    required this.roomType,
    required this.roomPrice,
    required this.bookingInfo,
    this.roomImageUrl,
  });

  // หมายเลขพร้อมเพย์ของร้าน
  final String promptPayNumber = '0615387806';

  @override
  Widget build(BuildContext context) {
    // แปลงข้อมูลที่ได้มา เช่น จำนวนห้อง จำนวนผู้เข้าพัก จำนวนคืน
    final int rooms = bookingInfo.rooms;
    final int guests = bookingInfo.guests;
    final int nights =
        bookingInfo.checkOut.difference(bookingInfo.checkIn).inDays;

    // คำนวณราคาห้องทั้งหมด + ภาษี
    final double subtotal = roomPrice * rooms * nights;
    final double tax = subtotal * 0.07;
    final double total = subtotal + tax;

    // ลิงก์สร้าง QR Code พร้อมจ่าย
    final qrUrl =
        'https://promptpay.io/$promptPayNumber/${total.toStringAsFixed(0)}';

    // แสดงวันที่ check-in / check-out ในรูปแบบที่อ่านง่าย
    final String checkInFormatted =
        DateFormat('dd MMM yyyy').format(bookingInfo.checkIn);
    final String checkOutFormatted =
        DateFormat('dd MMM yyyy').format(bookingInfo.checkOut);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: const BackButton(),
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // กล่องข้อมูลห้องที่เลือก
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.pink.shade100, blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Room Selected",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // รูปห้องพัก
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: roomImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(roomImageUrl!),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: roomImageUrl == null
                            ? const Center(child: Icon(Icons.image))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(roomType)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ข้อมูลจอง: จำนวนคน, ห้อง, วันเข้า/ออก, อีเมล
                  Text("Guests: $guests คน"),
                  Text("Rooms: $rooms ห้อง"),
                  Text("Check-in: $checkInFormatted"),
                  Text("Check-out: $checkOutFormatted"),
                  Text(
                      "Email: ${SessionManager.currentUser?['email'] ?? 'Unknown'}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // กล่องแสดงสรุปราคา
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.pink.shade100, blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nights: $nights คืน"),
                  Text("ราคาห้องพัก: ฿${subtotal.toStringAsFixed(2)}"),
                  Text("ภาษี 7%: ฿${tax.toStringAsFixed(2)}"),
                  const Divider(),
                  Text("Total: ฿${total.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // กล่องแสดง QR Code พร้อมจ่าย
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.pink.shade100, blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  Image.network(
                    qrUrl,
                    height: 180,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.qr_code, size: 120),
                  ),
                  const SizedBox(height: 12),
                  Text("Scan to pay ฿${total.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ปุ่ม "จ่ายเงินแล้ว" → ตรวจสอบห้องว่าง และส่งข้อมูลจอง
            ElevatedButton(
              onPressed: () async {
                final checkIn = bookingInfo.checkIn;
                final checkOut = bookingInfo.checkOut;

                // ดึง room_qty ปัจจุบันจาก backend
                final roomResp = await http.get(Uri.parse(
                    'https://hotel-api-six.vercel.app/rooms/${bookingInfo.roomId}'));
                if (roomResp.statusCode != 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('โหลดข้อมูลห้องไม่สำเร็จ')),
                  );
                  return;
                }
                final roomData = jsonDecode(roomResp.body);
                final int roomQty = roomData is List
                    ? int.tryParse(roomData[0]['room_qty'].toString()) ?? 0
                    : int.tryParse(roomData['room_qty'].toString()) ?? 0;

                // ดึงข้อมูล booking ทั้งหมด
                final bookingResp = await http
                    .get(Uri.parse('https://hotel-api-six.vercel.app/booking'));
                if (bookingResp.statusCode != 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('โหลดข้อมูลการจองไม่สำเร็จ')),
                  );
                  return;
                }

                // คำนวณจำนวนห้องที่ถูกจองในช่วงเวลาเดียวกัน
                final allBookings = jsonDecode(bookingResp.body);
                int totalBooked = 0;
                for (var b in allBookings) {
                  if (b['room_id'] != bookingInfo.roomId) continue;
                  final DateTime bIn = DateTime.parse(b['check_in']);
                  final DateTime bOut = DateTime.parse(b['check_out']);
                  final bool overlaps = bookingInfo.checkIn.isBefore(bOut) &&
                      bookingInfo.checkOut.isAfter(bIn);
                  if (overlaps) {
                    totalBooked += (b['num_rooms'] as num).toInt();
                  }
                }

                // ถ้าห้องไม่พอ → แจ้งเตือน
                if (totalBooked + bookingInfo.rooms > roomQty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ห้องเต็มในช่วงเวลานี้')),
                  );
                  return;
                }

                // ถ้าว่าง → POST ไปที่ backend เพื่อบันทึกการจอง
                final response = await http.post(
                  Uri.parse('https://hotel-api-six.vercel.app/booking'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'check_in': bookingInfo.checkIn.toIso8601String(),
                    'check_out': bookingInfo.checkOut.toIso8601String(),
                    'num_guest': bookingInfo.guests,
                    'num_rooms': bookingInfo.rooms,
                    'total_price': total.toStringAsFixed(2),
                    'hotel_id': bookingInfo.hotelId,
                    'room_id': bookingInfo.roomId,
                    'user_id': bookingInfo.userId,
                  }),
                );

                // แสดงผลลัพธ์จาก backend
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking success!')),
                  );
                  Navigator.pop(context); // กลับหน้าก่อนหน้า
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${response.body}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("จ่ายเงินแล้ว"),
            ),
          ],
        ),
      ),
    );
  }
}
