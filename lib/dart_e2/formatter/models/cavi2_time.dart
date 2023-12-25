class Cavi2Time {
  final DateTime? deviceTime;
  final DateTime? hostTime;
  final DateTime? internetTime;

  Cavi2Time({
    this.deviceTime,
    this.hostTime,
    this.internetTime,
  });

  factory Cavi2Time.fromMap(Map<String, dynamic> json) => Cavi2Time(
        deviceTime:
            (json['deviceTime'] as String).isEmpty || json["deviceTime"] == null
                ? null
                : DateTime.parse(json["deviceTime"]),
        hostTime:
            (json['hostTime'] as String).isEmpty || json["hostTime"] == null
                ? null
                : DateTime.parse(json["hostTime"]),
        internetTime: (json['internetTime'] as String).isEmpty ||
                json["internetTime"] == null
            ? null
            : DateTime.parse(json["internetTime"]),
      );

  Map<String, dynamic> toMap() => {
        "deviceTime": deviceTime?.toIso8601String(),
        "hostTime": hostTime?.toIso8601String(),
        "internetTime": internetTime?.toIso8601String(),
      };
}
