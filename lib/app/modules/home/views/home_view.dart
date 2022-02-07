import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';

import 'package:flip_card/flip_card.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();

  final GlobalKey<AnimatorWidgetState> frontAnimationKey =
      GlobalKey<AnimatorWidgetState>();
  final GlobalKey<AnimatorWidgetState> backAnimationKey =
      GlobalKey<AnimatorWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tae Kwon Do Terminology'),
          centerTitle: true,
        ),
        body: ResponsiveSizer(builder: (context, orientation, screenType) {
          return SmartRefresher(
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
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                width: 70.w,
                                child: LinearPercentIndicator(
                                  width: 70.w,
                                  lineHeight: 2.5.h,
                                  percent: _linearPercent(),
                                  backgroundColor: Colors.grey,
                                  progressColor: Colors.blue,
                                ),
                              ),
                            ),
                            CircularPercentIndicator(
                                radius: 12.h,
                                lineWidth: 1.25.h,
                                percent: grade,
                                center: Text(
                                    (grade * 100).round().toString() + '%',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                progressColor: Colors.green,
                                backgroundColor: Colors.red),
                            FlipCard(
                                onFlip: () => controller.showText(false),
                                onFlipDone: (isFront) {
                                  controller.showText(true);
                                  isFront
                                      ? backAnimationKey.currentState!.forward()
                                      : frontAnimationKey.currentState!
                                          .forward();
                                },
                                key: _cardKey,
                                fill: Fill
                                    .fillBack, // Fill the back side of the card to make in the same size as the front.
                                direction: FlipDirection.HORIZONTAL, // default
                                front: _getCard(true, frontAnimationKey),
                                back: _getCard(false, backAnimationKey)),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ElevatedButton(
                                      onPressed: controller.done()
                                          ? null
                                          : () {
                                              if (_cardKey.currentState !=
                                                      null &&
                                                  !_cardKey
                                                      .currentState!.isFront)
                                                _cardKey.currentState!
                                                    .toggleCard();
                                              controller.next(isCorrect: true);
                                            },
                                      child: Icon(Icons.check, size: 6.w),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.w, vertical: 4.h),
                                      )),
                                  Container(
                                    width: 10.w,
                                  ),
                                  ElevatedButton(
                                      onPressed: controller.done()
                                          ? null
                                          : () {
                                              if (_cardKey.currentState !=
                                                      null &&
                                                  !_cardKey
                                                      .currentState!.isFront) {
                                                _cardKey.currentState!
                                                    .toggleCard();
                                              }

                                              controller.next(isCorrect: false);
                                            },
                                      child:
                                          Icon(Icons.close_outlined, size: 6.w),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.w, vertical: 4.h),
                                      )),
                                ])
                          ]),
                    );
                  }),
                ),
              ));
        }));
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

  Widget _getCard(bool isFront, GlobalKey<AnimatorWidgetState> animationKey) {
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
                  width: 85.w,
                  height: 45.h,
                  child: Align(
                      alignment: Alignment.center,
                      child: controller.showText.isTrue &&
                              controller.hasData.isTrue
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  isFront
                                      ? '${controller.cards[controller.cardIndex()].english}'
                                      : '${controller.cards[controller.cardIndex()].korean}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold)),
                            )
                          : CircularProgressIndicator())),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RubberBand(
                  key: animationKey,
                  preferences: AnimationPreferences(
                      offset: Duration(seconds: 1),
                      duration: Duration(seconds: 2),
                      autoPlay: AnimationPlayStates.Forward),
                  child: CircularProfileAvatar(
                    '',
                    backgroundColor: isFront ? Colors.blue : Colors.green,
                    radius: 3.5.h,
                    elevation: 5.0,
                    child: Icon(
                      isFront ? Icons.redo : Icons.undo,
                      size: 3.h,
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
