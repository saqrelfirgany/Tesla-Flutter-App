import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/constanins.dart';
import '/home_controller.dart';
import 'components/battery_status.dart';
import 'components/door_lock.dart';
import 'components/temp_btn.dart';
import 'components/temp_details.dart';
import 'components/tesla_bottom_navigationbar.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HomeController _controller = HomeController();
  late AnimationController _batteryAnimatedContainer;
  late Animation<double> _animationBattery;
  late Animation<double> _animationBatteryStatus;
  late AnimationController _tempAnimationController;
  late Animation<double> _animationCarShift;
  late Animation<double> _animationTempShowInfo;
  late Animation<double> _animationCoolGlow;

  void setupTempAnimated() {
    _tempAnimationController = AnimationController(
      vsync: this,
      duration: Duration(microseconds: 1500),
    );
    //car shift animation
    _animationCarShift = CurvedAnimation(
      parent: _tempAnimationController,
      curve: Interval(0.2, 0.4),
    );
    _animationTempShowInfo = CurvedAnimation(
      parent: _tempAnimationController,
      curve: Interval(0.45, 0.65),
    );
    _animationCoolGlow = CurvedAnimation(
      parent: _tempAnimationController,
      curve: Interval(0.7, 0.1),
    );
  }

  void setupBatteryAnimated() {
    _batteryAnimatedContainer = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animationBattery = CurvedAnimation(
      parent: _batteryAnimatedContainer,
      curve: Interval(0.0, 0.5),
    );
    _animationBatteryStatus = CurvedAnimation(
      parent: _batteryAnimatedContainer,
      curve: Interval(0.6, 1),
    );
  }

  @override
  void initState() {
    setupBatteryAnimated();
    setupTempAnimated();
    super.initState();
  }

  @override
  void dispose() {
    _batteryAnimatedContainer.dispose();
    _tempAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _batteryAnimatedContainer,
        _tempAnimationController,
      ]),
      builder: (context, _) {
        return Scaffold(
          bottomNavigationBar: TeslaBottomNavigationBar(
            onTap: (index) {
              if (index == 1)
                _batteryAnimatedContainer.forward();
              else if (_controller.selectedBottomTab == 1 && index != 1)
                _batteryAnimatedContainer.reverse(from: 0.7);
              if (index == 2)
                _tempAnimationController.forward();
              else if (_controller.selectedBottomTab == 2 && index != 2)
                _tempAnimationController.reverse(from: 0.4);
              _controller.onBottomNavigationTabChange(index);
            },
            selectedTab: _controller.selectedBottomTab,
          ),
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                  ),
                  Positioned(
                    left: constraints.maxWidth / 2 * _animationCarShift.value,
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: constraints.maxHeight * 0.1),
                      child: SvgPicture.asset(
                        "assets/icons/Car.svg",
                        width: double.infinity,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: defaultDuration,
                    right: _controller.selectedBottomTab == 0
                        ? constraints.maxWidth * 0.05
                        : constraints.maxWidth / 2,
                    child: AnimatedOpacity(
                      duration: defaultDuration,
                      opacity: _controller.selectedBottomTab == 0 ? 1 : 0,
                      child: DoorLock(
                        isLock: _controller.isRightDoorLock,
                        press: _controller.updateRightDoorLock,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: defaultDuration,
                    left: _controller.selectedBottomTab == 0
                        ? constraints.maxWidth * 0.05
                        : constraints.maxWidth / 2,
                    child: AnimatedOpacity(
                      duration: defaultDuration,
                      opacity: _controller.selectedBottomTab == 0 ? 1 : 0,
                      child: DoorLock(
                        isLock: _controller.isLeftDoorLock,
                        press: _controller.updateLeftDoorLock,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: defaultDuration,
                    top: _controller.selectedBottomTab == 0
                        ? constraints.maxHeight * 0.13
                        : constraints.maxHeight / 2,
                    child: AnimatedOpacity(
                      duration: defaultDuration,
                      opacity: _controller.selectedBottomTab == 0 ? 1 : 0,
                      child: DoorLock(
                        isLock: _controller.isBonnetLock,
                        press: _controller.updateBonnetDoorLock,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: defaultDuration,
                    bottom: _controller.selectedBottomTab == 0
                        ? constraints.maxHeight * 0.17
                        : constraints.maxHeight / 2,
                    child: AnimatedOpacity(
                      duration: defaultDuration,
                      opacity: _controller.selectedBottomTab == 0 ? 1 : 0,
                      child: DoorLock(
                        isLock: _controller.isTrunkLock,
                        press: _controller.updateTrunkDoorLock,
                      ),
                    ),
                  ),
                  //Battery

                  Opacity(
                    opacity: _animationBattery.value,
                    child: SvgPicture.asset(
                      "assets/icons/Battery.svg",
                      width: constraints.maxWidth * 0.45,
                    ),
                  ),
                  Positioned(
                    top: 50 * (1 - _animationBatteryStatus.value),
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Opacity(
                      opacity: _animationBatteryStatus.value,
                      child: BatteryStatus(constraints: constraints),
                    ),
                  ),
                  //Temp
                  Positioned(
                    height: constraints.maxHeight,
                    top: 60 * (1 - _animationTempShowInfo.value),
                    width: constraints.maxWidth,
                    child: Opacity(
                      opacity: _animationTempShowInfo.value,
                      child: TempDetails(controller: _controller),
                    ),
                  ),
                  Positioned(
                    right: -180 * (1 - _animationCoolGlow.value),
                    child: Image.asset(
                      "assets/images/Cool_glow_2.png",
                      width: 200,
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
