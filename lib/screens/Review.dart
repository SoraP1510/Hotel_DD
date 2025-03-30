import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review'), leading: const BackButton()),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // กล่องสรุปรีวิว
            _buildSummaryBox(),

            const SizedBox(height: 16),

            // ฟอร์มรีวิว
            _buildReviewForm(),

            const SizedBox(height: 16),

            // รายการรีวิวตัวอย่าง
            _buildReviewItem(
              name: 'John Cena',
              date: '01-03-2025',
              detail: 'good price nice one',
              stars: 5,
            ),
            const SizedBox(height: 12),
            _buildReviewItem(
              name: 'John Cena',
              date: '27-02-2025',
              detail: 'good price nice one',
              stars: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
      ),
      child: const Column(
        children: [
          Text("Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text("335 Review", style: TextStyle(color: Colors.pinkAccent)),
          Text("6"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.pinkAccent),
              Icon(Icons.star, color: Colors.pinkAccent),
              Icon(Icons.star, color: Colors.pinkAccent),
              Icon(Icons.star, color: Colors.pinkAccent),
              Icon(Icons.star_border, color: Colors.pinkAccent),
            ],
          ),
          SizedBox(height: 4),
          Text("Good"),
        ],
      ),
    );
  }

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border, color: Colors.pinkAccent),
              Icon(Icons.star_border, color: Colors.pinkAccent),
              Icon(Icons.star_border, color: Colors.pinkAccent),
              Icon(Icons.star_border, color: Colors.pinkAccent),
              Icon(Icons.star_border, color: Colors.pinkAccent),
            ],
          ),
          const SizedBox(height: 12),
          const TextField(decoration: InputDecoration(hintText: "Your name")),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(hintText: "Leave a comment"),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCCAFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Send"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required String detail,
    required int stars,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                  stars,
                  (index) => const Icon(Icons.star, size: 16, color: Colors.pinkAccent),
                ),
              ),
            ],
          ),
          Text(date),
          const SizedBox(height: 8),
          const Text("Detail"),
          Text(detail),
        ],
      ),
    );
  }
}
