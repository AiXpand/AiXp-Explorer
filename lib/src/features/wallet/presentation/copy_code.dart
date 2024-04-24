import 'package:e2_explorer/main.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/common_widgets/copy_widget.dart';
import 'package:e2_explorer/src/features/wallet/widgets/header.dart';
import 'package:e2_explorer/src/features/wallet/widgets/stack_background.dart';
import 'package:e2_explorer/src/routes/routes.dart';

import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class CopyCodeScreen extends StatefulWidget {
  const CopyCodeScreen({super.key});

  @override
  State<CopyCodeScreen> createState() => _CopyCodeScreenState();
}

class _CopyCodeScreenState extends State<CopyCodeScreen> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    // print(kAIXpWallet?.privateKeyHex);
    return StackWalletBackground(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            walletPageHeader(title: "Create New Wallet"),
            Container(
              width: 465,
              height: 465,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
              decoration: BoxDecoration(
                  color: AppColors.containerBgColor,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BACKUP YOUR PRIVATE KEY',
                    style: TextStyles.body(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Backup the text below on paper or digitally and keep it somewhere safe and secure.',
                    textAlign: TextAlign.center,
                    style: TextStyles.body(color: AppColors.textSecondaryColor),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.sideNavSelectedTileIndicatorColor),
                        color: AppColors.dropdownFieldFillColor),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Text(
                          isVisible
                              ? kAIXpWallet?.privateKeyPem ?? ''
                              : "**************************************************************************************************************************************************************************************************************************************************************************",
                          textAlign: TextAlign.center,
                          style: TextStyles.body(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 100,
                        child: CopyTextWidget(
                          text: kAIXpWallet?.privateKeyPem ?? '',
                          allowCopy: isVisible,
                        ),
                      ),
                      Container(
                        width: 100,
                        child: ShowHideWidget(
                          isVisible: isVisible,
                          onToggle: (a) {
                            setState(() {
                              isVisible = a;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ClickableButton(
                    onTap: () => context.goNamed(RouteNames.createWalletReady),
                    text: "Continue",
                    backgroundColor: AppColors.buttonPrimaryBgColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
