import 'package:flutter/services.dart' show rootBundle;

import 'package:get/get.dart';
import 'package:yaml/yaml.dart';

import '../card_model.dart';

class CardsProvider extends GetConnect {
  @override
  void onInit() {}

  Future<List<Card>> getCards() async {
    final List<Card> cards = [];

    final String data = await rootBundle.loadString("assets/cards.yaml");

    final List<dynamic> jsonResult = loadYaml(data);

    jsonResult.forEach((jsonCard) => cards.add(Card.fromJson(jsonCard)));

    return cards;
  }
}
