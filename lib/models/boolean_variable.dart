class BooleanVariable {
  final String name;
  bool value;

  BooleanVariable({required this.name, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}