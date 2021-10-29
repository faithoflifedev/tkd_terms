import 'package:get/get.dart';
import 'package:tkd_terms/app/modules/home/providers/cards_provider.dart';

import '../card_model.dart';
import '../score_model.dart';

class HomeController extends GetxController {
  final CardsProvider provider = CardsProvider();

  final cards = <Card>[].obs;

  final cardIndex = 0.obs;

  final score = Score(right: 0, wrong: 0, remaining: -1).obs;

  var _hasData = false.obs;

  bool get hasData => _hasData();

  set hasData(bool value) {
    _hasData.value = value;
  }

  var done = false.obs;

  @override
  void onInit() {
    super.onInit();

    init();
  }

  Future<void> init() async {
    _getAllCards();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  void next({bool isCorrect = false}) {
    //last card
    if (cardIndex() < cards.length) {
      score.value.remaining--;

      isCorrect ? score.value.right++ : score.value.wrong++;

      score.refresh();

      cardIndex.value++;

      if (cardIndex() == cards.length - 1) {
        done.value = true;
      }
    }
  }

  void _getAllCards() async {
    final providedCards = await provider.getCards();

    hasData = false;

    cardIndex.value = 0;

    done.value = false;

    score.update((value) {
      if (value == null) return;

      value.remaining = providedCards.length;
      value.right = 0;
      value.wrong = 0;
    });

    providedCards.shuffle();

    if (cards.length > 0) cards.clear();

    cards.addAll(providedCards);

    cards.add(Card(english: 'done!', korean: 'keumahn'));

    hasData = true;
  }
}
