/// A calling list as returned by `GET /list?userId=`.
class CallList {
  final String id;
  final String name;
  final List<dynamic> agents;
  final String clientId;

  const CallList({
    required this.id,
    required this.name,
    this.agents = const [],
    this.clientId = '',
  });

  factory CallList.fromJson(Map<String, dynamic> json) => CallList(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: (json['name'] ?? 'Untitled List').toString(),
        agents: json['agents'] is List ? json['agents'] as List : const [],
        clientId: (json['clientId'] ?? '').toString(),
      );
}

/// A single contact / call inside a list.
class CallRecord {
  final String firstName;
  final String lastName;
  final String title;
  final String phone;
  final String email;
  final String company;
  final String status;
  final String? calledAt;
  final String? rescheduledAt;
  final int? duration;
  final String? feedback;

  const CallRecord({
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.phone,
    required this.email,
    required this.company,
    required this.status,
    this.calledAt,
    this.rescheduledAt,
    this.duration,
    this.feedback,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory CallRecord.fromJson(Map<String, dynamic> json) => CallRecord(
        firstName: (json['FirstName'] ?? '').toString(),
        lastName: (json['LastName'] ?? '').toString(),
        title: (json['Title'] ?? '').toString(),
        phone: (json['Phone'] ?? '').toString(),
        email: (json['Email'] ?? '').toString(),
        company: (json['Company'] ?? '').toString(),
        status: (json['status'] ?? 'pending').toString(),
        calledAt: json['calledAt']?.toString(),
        rescheduledAt: json['rescheduledAt']?.toString(),
        duration: json['duration'] is num
            ? (json['duration'] as num).toInt()
            : int.tryParse('${json['duration']}'),
        feedback: json['feedback']?.toString(),
      );
}

/// Response of `GET /list/{listId}`.
class CallListDetails {
  final int pending;
  final int called;
  final int rescheduled;
  final List<CallRecord> calls;

  const CallListDetails({
    required this.pending,
    required this.called,
    required this.rescheduled,
    required this.calls,
  });

  int get totalCalls =>
      calls.isNotEmpty ? calls.length : pending + called + rescheduled;

  factory CallListDetails.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final rawCalls = json['calls'] is List ? json['calls'] as List : const [];
    return CallListDetails(
      pending: asInt(json['pending']),
      called: asInt(json['called']),
      rescheduled: asInt(json['rescheduled']),
      calls: rawCalls
          .whereType<Map>()
          .map((e) => CallRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
