import 'package:yaml/yaml.dart';

class Card {
  String? english;
  String? korean;

  Card({this.english, this.korean});

  Card.fromJson(YamlMap json) {
    english = json['english'];
    korean = json['korean'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['english'] = english;
    data['korean'] = korean;
    return data;
  }
}
