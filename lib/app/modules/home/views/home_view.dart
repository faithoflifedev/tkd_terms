import 'package:flutter/material.dart';

import 'package:flip_card/flip_card.dart';
import 'package:get/get.dart';
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
            child: Obx(
              () => Column(children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Right: ${controller.score.value.right}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Wrong: ${controller.score.value.wrong}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Remaining: ${controller.score.value.remaining}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))
                    ]),
                FlipCard(
                  onFlip: () => controller.hasData = false,
                  onFlipDone: (isFront) => controller.hasData = true,
                  key: cardKey,
                  fill: Fill
                      .fillBack, // Fill the back side of the card to make in the same size as the front.
                  direction: FlipDirection.HORIZONTAL, // default
                  front: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                            color: Colors.green,
                            width: 400.0,
                            height: 400.0,
                            child: Align(
                                alignment: Alignment.center,
                                child: controller.hasData
                                    ? Text(
                                        '${controller.cards[controller.cardIndex()].english}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold))
                                    : CircularProgressIndicator())),
                      ),
                    ),
                  ),
                  back: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                            color: Colors.blue,
                            width: 400.0,
                            height: 400.0,
                            child: Align(
                                alignment: Alignment.center,
                                child: controller.hasData
                                    ? Text(
                                        '${controller.cards[controller.cardIndex()].korean}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold))
                                    : CircularProgressIndicator())),
                      ),
                    ),
                  ),
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
                                  fontSize: 30, fontWeight: FontWeight.bold))),
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
                                  fontSize: 30, fontWeight: FontWeight.bold))),
                    ])
              ]),
            ),
          )),
        ));
  }
}
