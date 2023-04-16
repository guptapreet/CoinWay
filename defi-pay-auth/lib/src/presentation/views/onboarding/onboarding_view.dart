import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../shared/utils/color.dart';
import '../../shared/utils/font.dart';
import '../auth/auth_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({Key? key}) : super(key: key);
  static const routeName = '/onboarding';

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _controller = PageController();

  final _dataList = [
    _PageData(
        lottie: 'https://assets8.lottiefiles.com/packages/lf20_fdd5z83w.json',
        title: 'Convenience of UPI'),
    _PageData(
        lottie:
            'https://assets8.lottiefiles.com/private_files/lf30_tw05dqnq.json',
        title: 'Security of Crypto'),
    _PageData(
        lottie: 'https://assets4.lottiefiles.com/packages/lf20_3hzWiO.json',
        title: 'Trust of Gold'),
    _PageData(
      lottie: 'https://assets10.lottiefiles.com/packages/lf20_xxeypw7y.json',
      title: 'Aurum',
    ),
  ];

  int _currentPage = 0;

  bool get isLastPage => _currentPage == _dataList.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: PageView.builder(
              controller: _controller,
              itemCount: _dataList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(
                        _dataList[index].title,
                        style: FontUtils.heading.copyWith(
                            fontSize: 34,
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex: 2,
                        child: Lottie.network(_dataList[index].lottie),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
              onPageChanged: (value) => setState(() => _currentPage = value),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: isLastPage ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: isLastPage ? null : finishOnBoarding,
                          child: const Text(
                            'Skip',
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(
                        // To balance extra 10 margin on right by last dot
                        width: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _dataList.length,
                          (int index) => _buildDots(index: index),
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: isLastPage ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: isLastPage
                              ? null
                              : () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  );
                                },
                          child: const Text(
                            'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  left: 0,
                  right: 0,
                  top: isLastPage ? 0 : 140,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: FloatingActionButton.extended(
                      onPressed: finishOnBoarding,
                      backgroundColor: ColorUtils.primary,
                      label: Text(
                        "Awesome",
                        style: FontUtils.textStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AnimatedContainer _buildDots({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
        boxShadow: _currentPage == index
            ? [
                BoxShadow(
                  color: ColorUtils.primary.withOpacity(0.4),
                  spreadRadius: 2,
                ),
              ]
            : null,
        color: _currentPage == index ? Colors.white : ColorUtils.primary,
      ),
      margin: const EdgeInsets.only(right: 10),
      height: _currentPage == index ? 12 : 9,
      curve: Curves.easeIn,
      width: _currentPage == index ? 12 : 9,
    );
  }

  void finishOnBoarding() {
    Navigator.pushNamed(context, AuthView.routeName);
  }
}

class _PageData {
  final String lottie;
  final String title;
  _PageData({required this.title, required this.lottie});
}
