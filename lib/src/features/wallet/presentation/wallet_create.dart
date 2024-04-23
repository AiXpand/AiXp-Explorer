import 'package:e2_explorer/main.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/common_widgets/layout/loading_parent_widget.dart';
import 'package:e2_explorer/src/features/wallet/widgets/header.dart';
import 'package:e2_explorer/src/features/wallet/widgets/stack_background.dart';
import 'package:e2_explorer/src/features/wallet/widgets/wallet_form_field.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/form_utils.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class WalletCreate extends StatefulWidget {
  const WalletCreate({super.key});

  @override
  State<WalletCreate> createState() => _WalletCreateState();
}

class _WalletCreateState extends State<WalletCreate> {
  bool isAgreeTermsCondition = false;
  bool isLoading = false;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameController.addListener(() {
      _formKey.currentState?.validate();
      setState(() {});
    });
    passwordController.addListener(() {
      _formKey.currentState?.validate();
      setState(() {});
    });
    super.initState();
  }

  bool get isValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StackWalletBackground(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            walletPageHeader(title: "Create New Wallet"),
            Container(
              width: 453,
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 31),
              decoration: BoxDecoration(
                color: AppColors.containerBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CREATE ACCOUNT',
                      style: TextStyles.body(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This password will encrypt your private key.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyles.body(color: AppColors.textSecondaryColor),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    const SizedBox(height: 18),
                    WalletFormFieldWidget(
                      hintText: "Set an Username",
                      controller: usernameController,
                      validator: (value) =>
                          FormUtils.validateRequiredField(context, value),
                    ),
                    const SizedBox(height: 18),
                    WalletFormFieldWidget(
                      hintText: "Set an Password",
                      controller: passwordController,
                      obscureText: true,
                      maxLines: 1,
                      validator: (value) =>
                          FormUtils.validatePassword(context, value),
                    ),
                    const SizedBox(height: 31),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          value: isAgreeTermsCondition,
                          onChanged: (value) {
                            setState(() {
                              isAgreeTermsCondition = value!;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Flexible(
                          child: Text(
                            "I understand that AiXpand cannot recover or reset my\npassword or the keystore file. I will make a backup of the keystore file / password, keep them secret, complete all wallet creation steps.",
                            style: TextStyles.small(
                                color: AppColors.textSecondaryColor),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 31),
                    LoadingParentWidget(
                      isLoading: isLoading,
                      child: ClickableButton(
                        isValid: isValid && isAgreeTermsCondition,
                        onTap: isValid && isAgreeTermsCondition
                            ? () async {
                                if (isAgreeTermsCondition &&
                                    FormUtils.validatePassword(
                                          context,
                                          passwordController.text,
                                        ) ==
                                        null) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    await kAIXpWallet
                                        ?.createWallet(passwordController.text);
                                    context.goNamed(RouteNames.createCopyCode);
                                  } catch (e) {
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              }
                            : null,
                        text: "Create a Wallet",
                        backgroundColor: AppColors.buttonPrimaryBgColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have a wallet? ",
                  style: TextStyles.body()
                      .copyWith(color: const Color(0xFF92A3D6)),
                ),
                InkWell(
                    onTap: () => context.goNamed(RouteNames.walletImport),
                    child: Text(
                      "Unlock Wallet",
                      style: TextStyles.body().copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4E4BDE),
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
