// import แพ็กเกจและโมเดล BookingInfo ที่จำเป็น
import 'package:flutter/material.dart';
import 'package:test3/models/booking_info.dart';

// StatefulWidget สำหรับกล่องค้นหาโรงแรม
class SearchBox extends StatefulWidget {
  final Function(String, BookingInfo)
      onSearch; // callback function สำหรับส่งค่าการค้นหาไปยังหน้า HomePage

  const SearchBox({super.key, required this.onSearch});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  // controller สำหรับช่องพิมพ์สถานที่
  final TextEditingController _locationController = TextEditingController();

  // ค่าดีฟอลต์ของวันเข้าพัก วันออก ห้อง และจำนวนคน
  DateTime? _checkInDate = DateTime.now();
  DateTime? _checkOutDate = DateTime.now().add(const Duration(days: 1));
  int _rooms = 1;
  int _person = 2;

  // ฟังก์ชันเปิดปฏิทินเลือกวัน (check-in หรือ check-out)
  Future<void> _selectDate(bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate! : _checkOutDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // ปรับ check-out ให้อย่างน้อย 1 วันหลัง check-in
          if (_checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  // Modal แสดงการเลือกจำนวนห้องและคนเข้าพัก
  void _showGuestPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Select Guests",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // แถวเลือกจำนวนห้อง
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Rooms"),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _rooms > 1
                              ? () => setSheetState(() => _rooms--)
                              : null,
                        ),
                        Text(_rooms.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setSheetState(() => _rooms++),
                        ),
                      ],
                    ),
                  ],
                ),
                // แถวเลือกจำนวนคน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("person"),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _person > 1
                              ? () => setSheetState(() => _person--)
                              : null,
                        ),
                        Text(_person.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setSheetState(() => _person++),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ปุ่ม Done เพื่อปิด modal
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // รีเฟรช UI หลัก
                    Navigator.pop(context);
                  },
                  child: const Text("Done"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ฟังก์ชันเมื่อกดปุ่ม Search → ส่งข้อมูลกลับผ่าน onSearch
  void _onSearchPressed() {
    final keyword = _locationController.text.trim(); // ดึงคำค้นหาจากช่อง
    final booking = BookingInfo(
      checkIn: _checkInDate!,
      checkOut: _checkOutDate!,
      rooms: _rooms,
      guests: _person,
    );
    widget.onSearch(
        keyword, booking); // เรียก callback ส่งค่ากลับไปยัง HomePage
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // ช่องใส่สถานที่ค้นหา
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Where to?',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ปุ่มเลือกวันเข้าและวันออก
          Row(
            children: [
              Expanded(
                child: _SearchTile(
                  icon: Icons.calendar_today,
                  text: "${_checkInDate!.month}/${_checkInDate!.day}",
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SearchTile(
                  icon: Icons.calendar_today,
                  text: "${_checkOutDate!.month}/${_checkOutDate!.day}",
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ปุ่มเลือกจำนวนห้องและคน
          _SearchTile(
            icon: Icons.person,
            text: "$_rooms room · $_person person",
            onTap: _showGuestPicker,
          ),
          const SizedBox(height: 16),

          // ปุ่มค้นหา
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onSearchPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 131, 218),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Search",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// คอมโพเนนต์ย่อยสำหรับ tile ที่ใช้แสดงวัน/คน ใน UI
class _SearchTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _SearchTile({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
