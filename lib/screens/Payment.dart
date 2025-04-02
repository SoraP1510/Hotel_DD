import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test3/models/booking_info.dart';
import 'package:intl/intl.dart';
import 'package:test3/session_manager.dart'; // ✅ เพิ่มตรงนี้

class PaymentPage extends StatelessWidget {
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

  final String promptPayNumber = '0615387806';

  @override
  Widget build(BuildContext context) {
    final int rooms = bookingInfo.rooms;
    final int guests = bookingInfo.guests;
    final int nights =
        bookingInfo.checkOut.difference(bookingInfo.checkIn).inDays;

    final double subtotal = roomPrice * rooms * nights;
    final double tax = subtotal * 0.07;
    final double total = subtotal + tax;

    final qrUrl =
        'https://promptpay.io/$promptPayNumber/${total.toStringAsFixed(0)}';

    final String checkInFormatted =
        DateFormat('dd MMM yyyy').format(bookingInfo.checkIn);
    final String checkOutFormatted =
        DateFormat('dd MMM yyyy').format(bookingInfo.checkOut);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment'), leading: const BackButton()),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Room Info
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
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: roomImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(roomImageUrl!),
                                  fit: BoxFit.cover,
                                )
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
                  Text("Guests: $guests คน"),
                  Text("Rooms: $rooms ห้อง"),
                  Text("Check-in: $checkInFormatted"), // ✅ เพิ่ม
                  Text("Check-out: $checkOutFormatted"), // ✅ เพิ่ม
                  Text(
                      "Email: ${SessionManager.currentUser?['email'] ?? 'Unknown'}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Summary
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
                  Text("Nights: $nights คืน"), // ✅ เพิ่มแสดงจำนวนคืน
                  Text("ราคาห้องพัก: ฿${subtotal.toStringAsFixed(2)}"),
                  Text("ภาษี 7%: ฿${tax.toStringAsFixed(2)}"),
                  const Divider(),
                  Text("Total: ฿${total.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QR PromptPay
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

            ElevatedButton(
              onPressed: () async {
                final url =
                    Uri.parse('https://hotel-api-six.vercel.app/booking');
                final response = await http.post(
                  url,
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

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking success!')),
                  );
                  Navigator.pop(context);
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
