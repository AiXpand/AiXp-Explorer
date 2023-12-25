import 'dart:convert';
import 'dart:io';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/simple_tooltip.dart';
import 'package:e2_explorer/src/features/e2_status/application/client_messages/payload_message.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/common/tab_display.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/payload_image_preview.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart';

class PayloadMessageView extends StatefulWidget {
  const PayloadMessageView({
    required this.selectedMessage,
    super.key,
  });

  final PayloadMessage? selectedMessage;

  @override
  State<PayloadMessageView> createState() => _PayloadMessageViewState();
}

class _PayloadMessageViewState extends State<PayloadMessageView> {
  late bool hasImages = false;
  List<String> base64Images = [];
  PayloadMessage? selectedMessage;
  final DataExplorerStore store = DataExplorerStore();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // final imgField = widget.selectedMessage?.content['data']?['img']['id'];
    final imgField = null;
    selectedMessage = widget.selectedMessage;
    store.buildNodes(json.decode(jsonEncode(selectedMessage)));
    if (imgField != null) {
      if (imgField is List) {
        // base64Images = imgField.map((e) => (e as Map<String, dynamic>)['id'] as String).toList();
        base64Images = imgField.map((e) => e as String).toList();
        hasImages = true;
      } else if (imgField is String) {
        base64Images = [imgField as String];
        hasImages = true;
      } else {
        hasImages = false;
      }
    } else {
      hasImages = false;
    }
  }

  @override
  void didUpdateWidget(PayloadMessageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMessage?.payload.hash !=
        oldWidget.selectedMessage?.payload.hash) {
      print('Message view different');
      selectedMessage = widget.selectedMessage;
      store.buildNodes(
          json.decode(jsonEncode(selectedMessage?.payload.messageBody)));

      // final imgField = widget.selectedMessage?.content['data']?['img']['id'];
      final imgField = null;

      if (imgField != null) {
        if (imgField is List) {
          base64Images = imgField.map((e) => e as String).toList();
          hasImages = true;
        } else if (imgField != null && imgField is String) {
          base64Images = [
            imgField as String,
          ];
          hasImages = true;
        } else {
          hasImages = false;
          base64Images = <String>[];
        }
      } else {
        hasImages = false;
        base64Images = <String>[];
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('Changed dependencies');
    // final imgField = widget.selectedMessage?['data']?['img'];
    //
    // setState(() {
    //   if (imgField != null) {
    //     if (imgField is List) {
    //       base64Images = imgField.map((e) => (e as Map<String, dynamic>)['id'] as String).toList();
    //       hasImages = true;
    //     } else if (imgField['id'] is String) {
    //       base64Images = [imgField['id']];
    //       hasImages = true;
    //     } else {
    //       hasImages = false;
    //     }
    //   } else {
    //     hasImages = false;
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return selectedMessage != null
        ? ChangeNotifierProvider.value(
            value: store,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: const Color(0xff161616),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Builder(builder: (context) {
                      if (!hasImages && false) {
                        return SelectableText(
                          const JsonEncoder.withIndent('    ')
                              .convert(widget.selectedMessage),
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        );
                      } else {
                        return TabDisplay(
                          tabNames: const <String>['Body', 'Images'],
                          children: <Widget>[
                            Container(
                              // color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 60,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: searchController,
                                              onChanged: (term) =>
                                                  store.search(term),
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                color: ColorStyles.light100,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              decoration: InputDecoration(
                                                hintStyle: GoogleFonts.lato(
                                                  color: ColorStyles.light900,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          ColorStyles.light100),
                                                ),
                                                // focusedBorder: UnderlineInputBorder(
                                                //   borderSide: BorderSide(color: theColor),
                                                // ),
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          ColorStyles.light100),
                                                ),
                                                hintText: 'Search',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          IconButton(
                                            onPressed:
                                                store.focusPreviousSearchResult,
                                            icon: const Icon(
                                              Icons.arrow_drop_up,
                                              color: ColorStyles.light100,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed:
                                                store.focusNextSearchResult,
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: ColorStyles.light100,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SimpleTooltip(
                                          message: 'Copy file to clipboard',
                                          child: InkWell(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text: const JsonEncoder
                                                              .withIndent(
                                                              '    ')
                                                          .convert(
                                                              selectedMessage)));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Message copied to clipboard!')));
                                            },
                                            child: Icon(
                                              CarbonIcons.copy,
                                              color: ColorStyles.light100,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        SimpleTooltip(
                                          message: 'Save file to computer',
                                          child: InkWell(
                                            onTap: () async {
                                              String selectedDirectory =
                                                  await FilePicker.platform
                                                          .getDirectoryPath() ??
                                                      '';
                                              if (selectedDirectory
                                                  .isNotEmpty) {
                                                final messageId =
                                                    selectedMessage
                                                            ?.payload.hash ??
                                                        'savedJson';
                                                final File file = File(
                                                    '$selectedDirectory/$messageId.json');
                                                await file.writeAsString(
                                                  const JsonEncoder.withIndent(
                                                          '    ')
                                                      .convert(selectedMessage),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Message saved to $selectedDirectory!')));
                                              }
                                            },
                                            child: Icon(
                                              CarbonIcons.save,
                                              color: ColorStyles.light100,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        color: ColorStyles.dark900,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Consumer<DataExplorerStore>(
                                            builder: (context, state, child) =>
                                                JsonDataExplorer(
                                              nodes: state.displayNodes,
                                              collapsableToggleBuilder:
                                                  (context, node) {
                                                if (node.isCollapsed) {
                                                  return const Icon(
                                                    CarbonIcons.chevron_right,
                                                    color: ColorStyles.light100,
                                                    size: 12,
                                                  );
                                                } else {
                                                  return const Icon(
                                                    CarbonIcons.chevron_down,
                                                    color: ColorStyles.light100,
                                                    size: 12,
                                                  );
                                                }
                                              },
                                              valueFormatter: (value) {
                                                var newValue = value.toString();

                                                /// Temporary to ignore the big image field
                                                /// ToDo: modify the package for custom functionality
                                                if (newValue.length > 500) {
                                                  return newValue.replaceRange(
                                                      10,
                                                      newValue.length,
                                                      '...');
                                                }
                                                return newValue;
                                              },
                                              theme: DataExplorerTheme(
                                                rootKeyTextStyle:
                                                    GoogleFonts.inconsolata(
                                                  color: ColorStyles.light100,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                propertyKeyTextStyle:
                                                    GoogleFonts.inconsolata(
                                                  color: ColorStyles.light200,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                keySearchHighlightTextStyle:
                                                    GoogleFonts.inconsolata(
                                                  color: Colors.black,
                                                  backgroundColor:
                                                      const Color(0xFFFFEDAD),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                focusedKeySearchHighlightTextStyle:
                                                    GoogleFonts.inconsolata(
                                                  color: Colors.black,
                                                  backgroundColor:
                                                      const Color(0xFFF29D0B),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                valueTextStyle:
                                                    GoogleFonts.inconsolata(
                                                  color: ColorStyles.yellow,
                                                  fontSize: 16,
                                                ),
                                                valueSearchHighlightTextStyle:
                                                    GoogleFonts.inconsolata(
                                                  color:
                                                      const Color(0xFFCA442C),
                                                  backgroundColor:
                                                      const Color(0xFFFFEDAD),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                focusedValueSearchHighlightTextStyle:
                                                    GoogleFonts.inconsolata(
                                                  color: Colors.black,
                                                  backgroundColor:
                                                      const Color(0xFFF29D0B),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                indentationLineColor:
                                                    const Color(0xFFE1E1E1),
                                                highlightColor:
                                                    ColorStyles.dark600,
                                              ),

                                              ///TODO add theme
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SelectableText(
                            //   const JsonEncoder.withIndent('    ').convert(selectedMessage),
                            //   style: const TextStyle(
                            //     color: Colors.white70,
                            //   ),
                            // ),
                            PayloadImagePreview(
                              message: widget.selectedMessage!,
                              base64Images: base64Images,
                            ),
                            // Container(
                            //   height: double.infinity,
                            //   width: double.infinity,
                            //   color: Colors.red,
                            // ),
                          ],
                        );
                      }
                    }),
                  ),
                ],
              ),
            ),
          )
        : const Center(
            child: Text(
              'No message selected',
              style: TextStyle(
                color: Colors.white38,
              ),
            ),
          );
  }
}
