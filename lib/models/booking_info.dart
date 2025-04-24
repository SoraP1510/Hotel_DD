class BookingInfo {
  final DateTime checkIn;
  final DateTime checkOut;
  final int rooms;
  final int guests;
  final int? hotelId;
  final int? roomId;
  final int? userId;

  BookingInfo({
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.guests,
    this.hotelId,
    this.roomId,
    this.userId,
  });
}
