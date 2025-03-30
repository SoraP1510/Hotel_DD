import 'package:flutter/material.dart';

class AgodaSearchBox extends StatefulWidget {
  const AgodaSearchBox({super.key});

  @override
  State<AgodaSearchBox> createState() => _AgodaSearchBoxState();
}

class _AgodaSearchBoxState extends State<AgodaSearchBox> {
  final TextEditingController _locationController = TextEditingController();

  DateTime? _checkInDate = DateTime.now();
  DateTime? _checkOutDate = DateTime.now().add(const Duration(days: 1));
  int _rooms = 1;
  int _adults = 2;

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate! : _checkOutDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Adults"),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _adults > 1
                              ? () => setSheetState(() => _adults--)
                              : null,
                        ),
                        Text(_adults.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setSheetState(() => _adults++),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
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

  void _onSearchPressed() {
    final snackBar = SnackBar(
      content: Text(
        'Searching: ${_locationController.text} | '
        '${_checkInDate?.toString().split(" ")[0]} - ${_checkOutDate?.toString().split(" ")[0]} | '
        '$_rooms Room(s), $_adults Adult(s)',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          // Location input
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

          // Date pickers
          Row(
            children: [
              Expanded(
                child: _SearchTile(
                  icon: Icons.calendar_today,
                  text: _checkInDate != null
                      ? "${_checkInDate!.month}/${_checkInDate!.day}"
                      : "Check-in",
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SearchTile(
                  icon: Icons.calendar_today,
                  text: _checkOutDate != null
                      ? "${_checkOutDate!.month}/${_checkOutDate!.day}"
                      : "Check-out",
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Guests
          _SearchTile(
            icon: Icons.person,
            text: "$_rooms room $_adults adults",
            onTap: _showGuestPicker,
          ),
          const SizedBox(height: 16),

          // Search button
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
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;

  const _FilterChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.blue,
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.blue),
          )
        ],
      ),
    );
  }
}
