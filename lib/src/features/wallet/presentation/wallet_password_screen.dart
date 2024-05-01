import 'package:e2_explorer/main.dart';
import 'package:e2_explorer/src/design/app_toast.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/common_widgets/layout/loading_parent_widget.dart';
import 'package:e2_explorer/src/features/wallet/widgets/header.dart';
import 'package:e2_explorer/src/features/wallet/widgets/stack_background.dart';
import 'package:e2_explorer/src/features/wallet/widgets/wallet_form_field.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/form_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

class WalletPasswordScreen extends StatefulWidget {
  const WalletPasswordScreen({super.key});

  @override
  State<WalletPasswordScreen> createState() => _WalletPasswordScreenState();
}

class _WalletPasswordScreenState extends State<WalletPasswordScreen> {
  bool isLoading = false;
  late final TextEditingController passwordController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    passwordController = TextEditingController()
      ..addListener(() {
        _formKey.currentState?.validate();
        setState(() {});
      });
    super.initState();
  }

  bool get isFormValid => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    return StackWalletBackground(
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              walletPageHeader(title: "PASSWORD"),
              Container(
                width: 453,
                padding:
                    const EdgeInsets.symmetric(horizontal: 42, vertical: 31),
                decoration: BoxDecoration(
                  color: AppColors.containerBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ENTER PASSWORD',
                      style: TextStyles.body(),
                    ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   'This password will encrypt your private key.',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyles.body(color: AppColors.textSecondaryColor),
                    // ),
                    const SizedBox(
                      height: 32,
                    ),
                    WalletFormFieldWidget(
                      hintText: "Enter your Password",
                      controller: passwordController,
                      obscureText: true,
                      maxLines: 1,
                      validator: (value) =>
                          FormUtils.validatePassword(context, value),
                    ),
                    const SizedBox(height: 31),
                    LoadingParentWidget(
                      isLoading: isLoading,
                      child: ClickableButton(
                        isValid: isFormValid,
                        onTap: isFormValid
                            ? () async {
                                final isSuccess = await kAIXpWallet!
                                    .loadWallet(passwordController.text);
                                if (isSuccess) {
                                  // ignore: use_build_context_synchronously
                                  context.goNamed(RouteNames.connection);
                                  AppToast(
                                    message: "Wallet unlocked successfully",
                                    description:
                                        'You have successfully unlocked your wallet.',
                                  ).show(
                                    context,
                                    type: ToastificationType.success,
                                  );
                                } else {
                                  AppToast(
                                    message: "Wallet unlocked failed",
                                    description:
                                        'Unable to unlock wallet with this password.',
                                  ).show(
                                    context,
                                    type: ToastificationType.error,
                                  );
                                }
                              }
                            : null,
                        // text: "Create a Wallet",
                        text: 'Unlock Wallet',
                        backgroundColor: AppColors.buttonPrimaryBgColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have a wallet? ",
                      style: TextStyles.body()
                          .copyWith(color: const Color(0xFF92A3D6))),
                  InkWell(
                      onTap: () => context.goNamed(RouteNames.walletCreate),
                      child: Text(
                        "Create Wallet",
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
      ),
    );
  }
}
