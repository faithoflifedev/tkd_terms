import 'package:flutter/material.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Korean Terminology'),
        centerTitle: true,
      ),
      body: SmartRefresher(
          controller: _refreshController,
          onRefresh: () async {
            await controller.init();

            _refreshController.loadComplete();

            _refreshController.refreshCompleted();
          },
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                final double grade = controller.score.value.right > 0
                    ? controller.score.value.right /
                        (controller.score.value.right +
                            controller.score.value.wrong)
                    : 0.0;

                return SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Progress: ' + _progress(),
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: 300.0,
                            child: LinearPercentIndicator(
                              width: 300.0,
                              lineHeight: 14.0,
                              percent: _linearPercent(),
                              backgroundColor: Colors.grey,
                              progressColor: Colors.blue,
                            ),
                          ),
                        ),
                        CircularPercentIndicator(
                            radius: 75.0,
                            lineWidth: 8.0,
                            percent: grade,
                            center: Text((grade * 100).round().toString() + '%',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            progressColor: Colors.green,
                            backgroundColor: Colors.red),
                        FlipCard(
                          onFlip: () => controller.showText(false),
                          onFlipDone: (isFront) => controller.showText(true),
                          key: cardKey,
                          fill: Fill
                              .fillBack, // Fill the back side of the card to make in the same size as the front.
                          direction: FlipDirection.HORIZONTAL, // default
                          front: QuestionCard(isFront: true),
                          back: QuestionCard(isFront: false),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: controller.done()
                                      ? null
                                      : () {
                                          if (cardKey.currentState != null &&
                                              !cardKey.currentState!.isFront)
                                            cardKey.currentState!.toggleCard();
                                          controller.next(isCorrect: true);
                                        },
                                  child: Icon(Icons.check),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 20),
                                      textStyle: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold))),
                              ElevatedButton(
                                  onPressed: controller.done()
                                      ? null
                                      : () {
                                          if (cardKey.currentState != null &&
                                              !cardKey.currentState!.isFront)
                                            cardKey.currentState!.toggleCard();
                                          controller.next(isCorrect: false);
                                        },
                                  child: Icon(Icons.close_outlined),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 20),
                                      textStyle: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold))),
                            ])
                      ]),
                );
              }),
            ),
          )),
    );
  }

  double _linearPercent() {
    if (controller.cards.length == 0) return 0.0;

    if (controller.cardIndex() == 70) return controller.cardIndex() - 1;

    return controller.cardIndex() / (controller.cards.length - 1);
  }

  String _progress() {
    final limit = controller.cards.length - 1;

    var index = controller.cardIndex();

    if (index > limit) index = limit;

    return '${index} / ${limit}';
  }
}

class QuestionCard extends GetView<HomeController> {
  final bool isFront;

  QuestionCard({required this.isFront});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
            alignment: isFront ? Alignment.topRight : Alignment.topLeft,
            children: <Widget>[
              Container(
                  decoration: new BoxDecoration(
                      color: isFront ? Colors.green : Colors.blue,
                      borderRadius: new BorderRadius.circular(10.0),
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black54,
                          offset: new Offset(4.0, 4.0),
                        )
                      ]),
                  width: 360.0,
                  height: 360.0,
                  child: Obx(() => Align(
                      alignment: Alignment.center,
                      child: controller.showText.isTrue
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  isFront
                                      ? '${controller.cards[controller.cardIndex()].english}'
                                      : '${controller.cards[controller.cardIndex()].korean}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            )
                          : CircularProgressIndicator()))),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RubberBand(
                  preferences: AnimationPreferences(
                      offset: Duration(seconds: 1),
                      autoPlay: AnimationPlayStates.Loop),
                  child: CircleAvatar(
                    backgroundColor: isFront ? Colors.blue : Colors.green,
                    child: Icon(
                      isFront ? Icons.redo : Icons.undo,
                      size: 24,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
