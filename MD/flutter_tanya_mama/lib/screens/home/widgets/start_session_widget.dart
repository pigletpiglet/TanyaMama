import 'package:flutter/material.dart';
import 'package:flutter_tanya_mama/configs/configs.dart';
import 'package:flutter_tanya_mama/widgets/custom/custom_text.dart';
import 'package:flutter_tanya_mama/widgets/long_raised_button.dart';

class StartSessionWidget extends StatelessWidget {
  final Function() onPressedStartSession;
  const StartSessionWidget({
    Key? key,
    required this.onPressedStartSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/Mama_HadapKeatas.png",
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 1,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Kamu butuh bantuan Mama?',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                LongRaisedButton(
                  height: 50,
                  dividedBy: 1.2,
                  color: Colors.transparent,
                  onPressed: onPressedStartSession,
                  child: const CustomText(
                    "Chat Sekarang",
                    color: Configs.backgroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                LongRaisedButton(
                  height: 50,
                  dividedBy: 1.2,
                  color: Configs.pentiaryColor,
                  onPressed: onPressedStartSession,
                  child: const CustomText(
                    "Quick Chat",
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
