library ai;

import 'dart:async';
import 'dart:convert';

import 'package:carbon_icons/carbon_icons.dart';
// import 'package:cavi_investigator/features/ai_plugins/index.dart';
// import 'package:cavi_investigator/features/alerts_events/presentation/dialogs/witness_viewer/index.dart';
// import 'package:cavi_investigator/features/equipments/index.dart';
// import 'package:cavi_investigator/features/language/index.dart';
// import 'package:cavi_investigator/features/locations/index.dart';
// import 'package:cavi_investigator/features/media/index.dart';
// import 'package:cavi_investigator/features/users/index.dart';
// import 'package:cavi_investigator/utils/dialog_utils.dart';
// import 'package:cavi_investigator/widgets/common_components/index.dart';
import 'package:collection/collection.dart';
import 'package:e2_explorer/http_client/index.dart';
import 'package:e2_explorer/src/data/constants_data.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/overlay_parent.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/overlay_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/options_menu/options_menu.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/dimens.dart';
import 'package:e2_explorer/src/features/node_dashboard/pages/pipeline/widgets/pipleline_tree/data/dto/business_client.dart';
import 'package:e2_explorer/src/features/node_dashboard/pages/pipeline/widgets/pipleline_tree/data/dto/equipment.dart';
import 'package:e2_explorer/src/features/node_dashboard/pages/pipeline/widgets/pipleline_tree/data/dto/equipment_dto.dart';
import 'package:e2_explorer/src/features/node_dashboard/pages/pipeline/widgets/pipleline_tree/data/dto/location.dart';
import 'package:e2_explorer/src/widgets/hf_flutter/hf_tree/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:hf_flutter/hf_flutter.dart';
// import 'package:hf_flutter/widgets/table/new_colors.dart';
// import 'package:hf_flutter/widgets/table/new_text_styles.dart';
// import 'package:hf_flutter/widgets/utils/dimens.dart';
import 'package:http/http.dart' as http;

part 'data/ai_repository.dart';
part 'data/snapshot_mock.dart';
part 'data/dto/dct_dto.dart';
part 'data/dto/pipeline_dto.dart';
part 'data/dto/plugin_action_dto.dart';
part 'data/dto/plugin_instance_dto.dart';
part 'data/dto/plugin_rule_dto.dart';
part 'data/dto/plugin_schema_dto.dart';
part 'data/dto/plugin_type_dto.dart';

part 'domain/camera_stream.dart';
part 'domain/pipeline.dart';
part 'domain/plugin_instance.dart';

part 'presentation/dialogs/add_pipeline/add_pipeline_dialog.dart';
part 'presentation/dialogs/add_pipeline/add_pipeline_fields.dart';

part 'presentation/dialogs/add_plugin/add_plugin_dialog.dart';

part 'presentation/widgets/ai_tree/ai_tree.dart';
part 'presentation/widgets/ai_tree/ai_tree_common_widgets.dart';
part 'presentation/widgets/ai_tree/ai_tree_data_source.dart';
part 'presentation/widgets/ai_tree/ai_tree_item.dart';
// part 'presentation/widgets/ai_tree/ai_tree_item_viewer.dart';
part 'presentation/widgets/ai_tree/ai_tree_item_widget.dart';
part 'presentation/widgets/dct_type_dropdown.dart';
part 'presentation/widgets/plugin_type_dropdown.dart';

// part 'presentation/screens/ai_plugins_screen.dart';
// part 'presentation/screens/ai_plugins_screen_content.dart';
