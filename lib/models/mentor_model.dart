// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Mentor {
  String uid;
  String name;
  List<String> studentsAssign;
  Mentor({
    required this.uid,
    required this.name,
    required this.studentsAssign,
  });

  Mentor copyWith({
    String? uid,
    String? name,
    List<String>? studentAssign,
  }) {
    return Mentor(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      studentsAssign: studentAssign ?? studentsAssign,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'studentAssign': studentsAssign,
    };
  }

  factory Mentor.fromMap(Map<String, dynamic> map) {
    return Mentor(
        uid: map['uid'] as String,
        name: map['name'] as String,
        studentsAssign: List<String>.from(
          (map['studentAssign'] as List<String>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory Mentor.fromJson(String source) =>
      Mentor.fromMap(json.decode(source) as Map<String, dynamic>);
}
