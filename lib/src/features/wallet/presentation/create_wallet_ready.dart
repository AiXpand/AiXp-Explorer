import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/wallet/widgets/header.dart';
import 'package:e2_explorer/src/features/wallet/widgets/stack_background.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/asset_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:go_router/go_router.dart';

class CreateWalletReady extends StatelessWidget {
  const CreateWalletReady({super.key});

  @override
  Widget build(BuildContext context) {
    return StackWalletBackground(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            walletPageHeader(title: "Create New Walle hbjbt"),
            Container(
              width: 453,
              height: 450,
              padding: const EdgeInsets.only(
                  top: 71, bottom: 30, left: 41, right: 42),
              decoration: BoxDecoration(
                  color: AppColors.containerBgColor,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                      AssetUtils.getSvgIconPath("wallet_illustration")),
                  const SizedBox(height: 28),
                  Text(
                    'YOU’RE READY!',
                    style: TextStyles.body(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You are now ready to use your new AiXpand wallet.',
                    textAlign: TextAlign.center,
                    style: TextStyles.body(color: AppColors.textSecondaryColor),
                  ),
                  const Spacer(),
                  const SizedBox(height: 31),
                  ClickableButton(
                    onTap: () => context.goNamed(RouteNames.walletPassword),
                    text: "Unlock Wallet",
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
