import 'package:flutter/material.dart';
import 'package:test3/screens/Payment.dart';
import 'package:test3/screens/Review.dart';

class HotelDetailPage extends StatelessWidget {
  const HotelDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail"), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel picture
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[400],
              child: const Center(child: Icon(Icons.image, size: 60)),
            ),
            const SizedBox(height: 8),
            const Text("Hotel Picture", textAlign: TextAlign.center),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Hotel Name",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReviewPage()),
                    );
                  },
                  child: const Text(
                    "335 Review",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.star, color: Colors.pink, size: 20),
                Icon(Icons.star, color: Colors.pink, size: 20),
                Icon(Icons.star, color: Colors.pink, size: 20),
                Icon(Icons.star, color: Colors.pink, size: 20),
                Icon(Icons.star_border, color: Colors.pink, size: 20),
              ],
            ),

            const Divider(height: 32),

            const Text("Detail", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Row(children: [
              Chip(label: Text("non-smoke")),
              SizedBox(width: 8),
              Chip(label: Text("free breakfast")),
            ]),

            const SizedBox(height: 16),
            const Text("Location",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(child: Text("Google Map Placeholder")),
            ),

            const SizedBox(height: 16),
            const Text("tag", style: TextStyle(fontWeight: FontWeight.bold)),
            const Wrap(
              spacing: 8,
              children: [
                Chip(label: Text("#Bangkok")),
                Chip(label: Text("#Thailand")),
              ],
            ),

            const Divider(height: 32),
            const Text("Room", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _roomItem(context, "Suite room", "Price"),
            _roomItem(context, "King room", "Price"),
            _roomItem(context, "Twin bed", "Price"),
          ],
        ),
      ),
    );
  }

  Widget _roomItem(BuildContext context, String roomType, String price) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          color: Colors.grey[400],
          child: const Center(child: Icon(Icons.image)),
        ),
        title: Text(roomType),
        subtitle: Text(price),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFCCAFF),
            foregroundColor: Colors.black,
          ),
          child: const Text("Book now"),
        ),
      ),
    );
  }
}
