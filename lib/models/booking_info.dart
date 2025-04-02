class BookingInfo {
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int guests;
  final int? hotelId; // ✅ เปลี่ยนจาก int → int?
  final int? roomId;
  final int? userId;

  BookingInfo({
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.guests,
    this.hotelId, // ✅ ไม่ต้อง required แล้ว
    this.roomId,
    this.userId,
  });
}
