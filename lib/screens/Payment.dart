import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Hotel Picture
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[400],
                    child: const Center(child: Text("Hotel Picture")),
                  ),
                  const SizedBox(height: 16),

                  // Room Picture + ข้อมูลห้อง
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          color: Colors.grey[400],
                          child: const Center(child: Text("Room Picture")),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Text("ข้อมูลห้องพัก")),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // สรุปราคา
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ราคาห้องพัก:"),
                  Text("ภาษี:"),
                  Divider(),
                  Text("Total :", style: TextStyle(fontWeight: FontWeight.bold)),
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
                boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Image.network(
                    'https://promptpay.io/qr', // ใช้ลิงก์จริงหากมี
                    height: 160,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.qr_code, size: 120),
                  ),
                  const SizedBox(height: 12),
                  const Text("Scan To Pay", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
