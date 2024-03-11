// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Student {
  String uid;
  String execution;
  String ideation;
  String viva;
  String name;
  bool isAssigned;
  Student({
    required this.uid,
    required this.execution,
    required this.ideation,
    required this.viva,
    required this.name,
    required this.isAssigned,
  });

  Student copyWith({
    String? uid,
    String? execution,
    String? ideation,
    String? viva,
    String? name,
    bool? isAssigned,
  }) {
    return Student(
      uid: uid ?? this.uid,
      execution: execution ?? this.execution,
      ideation: ideation ?? this.ideation,
      viva: viva ?? this.viva,
      name: name ?? this.name,
      isAssigned: isAssigned ?? this.isAssigned,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'execution': execution,
      'ideation': ideation,
      'viva': viva,
      'name': name,
      'isAssigned':isAssigned,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      uid: map['uid'] as String,
      execution: map['execution'] as String,
      ideation: map['ideation'] as String,
      viva: map['viva'] as String,
      name: map['name'] as String,
      isAssigned: map['isAssigned'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source) as Map<String, dynamic>);
}