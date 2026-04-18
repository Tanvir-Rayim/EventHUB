class TicketModel {
  final String id;
  final String eventTitle;
  final String date;
  final String location;
  final String ticketType;
  final String status;
  final int quantity;
  final int totalPrice;

  TicketModel({
    required this.id,
    required this.eventTitle,
    required this.date,
    required this.location,
    required this.ticketType,
    required this.status,
    required this.quantity,
    required this.totalPrice,
  });

  factory TicketModel.fromMap(String id, Map<String, dynamic> map) {
    return TicketModel(
      id: id,
      eventTitle: map['eventTitle'] ?? '',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      ticketType: map['ticketType'] ?? '',
      status: map['status'] ?? '',
      quantity: map['quantity'] ?? 1,
      totalPrice: map['totalPrice'] ?? 0,
    );
  }
}