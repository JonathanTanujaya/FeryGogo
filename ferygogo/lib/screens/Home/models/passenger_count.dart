class PassengerCount {
  final int adult;
  final int child;
  final int elderly;

  PassengerCount({
    this.adult = 1,
    this.child = 0,
    this.elderly = 0,
  });

  int get total => adult + child + elderly;

  Map<String, dynamic> toJson() => {
    'adult': adult,
    'child': child,
    'elderly': elderly,
  };

  factory PassengerCount.fromJson(Map<String, dynamic> json) {
    return PassengerCount(
      adult: json['adult'] as int? ?? 1,
      child: json['child'] as int? ?? 0,
      elderly: json['elderly'] as int? ?? 0,
    );
  }

  PassengerCount copyWith({
    int? adult,
    int? child,
    int? elderly,
  }) {
    return PassengerCount(
      adult: adult ?? this.adult,
      child: child ?? this.child,
      elderly: elderly ?? this.elderly,
    );
  }
}