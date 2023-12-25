import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttServerRepository {
  factory MqttServerRepository() => _singleton;

  MqttServerRepository._internal() : super();

  static final MqttServerRepository _singleton =
      MqttServerRepository._internal();

  static const String _mqttServersKey = 'mqtt_servers';
  static const String _selectedServerNameKey = 'selected_server_name';

  /// Retrieves the list of MQTT servers from SharedPreferences.
  /// Returns an empty list if no servers are found.
  Future<List<MqttServer>> getMqttServers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? serverStrings = prefs.getStringList(_mqttServersKey);

    if (serverStrings != null) {
      return serverStrings.map((serverString) {
        final serverData = jsonDecode(serverString);
        return MqttServer(
          name: serverData['name'],
          host: serverData['host'],
          port: serverData['port'],
          username: serverData['username'],
          password: serverData['password'],
        );
      }).toList();
    }

    return [];
  }

  /// Saves the list of MQTT servers to SharedPreferences.
  Future<void> saveMqttServers(List<MqttServer> servers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> serverStrings = servers.map((server) {
      Map<String, dynamic> serverData = {
        'name': server.name,
        'host': server.host,
        'port': server.port,
        'username': server.username,
        'password': server.password,
      };
      return jsonEncode(serverData);
    }).toList();
    await prefs.setStringList(_mqttServersKey, serverStrings);
  }

  /// Adds and saves a single new MQTT server to SharedPreferences.
  /// Returns true if the server was successfully added, false otherwise.
  Future<bool> addMqttServer(MqttServer server) async {
    if (await hasServerWithName(server.name)) {
      return false; // Server with the same name already exists
    }

    List<MqttServer> servers = await getMqttServers();
    servers.add(server);
    await saveMqttServers(servers);
    return true;
  }

  /// Removes a single new MQTT server to SharedPreferences.
  Future<void> removeMqttServer(MqttServer server) async {
    final MqttServer? selectedServer = await getSelectedMqttServer();
    if (selectedServer != null && selectedServer.name == server.name) {
      await saveSelectedServerName(null);
    }
    List<MqttServer> servers = await getMqttServers();
    servers.removeWhere((element) => element.name == server.name);
    await saveMqttServers(servers);
  }

  /// Checks if a server with the given [name] exists in SharedPreferences.
  /// Returns true if a server with the name exists, false otherwise.
  Future<bool> hasServerWithName(String name) async {
    List<MqttServer> servers = await getMqttServers();
    return servers.any((server) => server.name == name);
  }

  /// Saves the name of the selected MQTT server to SharedPreferences.
  /// If we set [serverName] to null, the key will be deleted and thus the default server will be used.
  Future<void> saveSelectedServerName(String? serverName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (serverName != null) {
      await prefs.setString(_selectedServerNameKey, serverName);
    } else {
      await prefs.remove(_selectedServerNameKey);
    }
  }

  /// Retrieves the name of the selected MQTT server from SharedPreferences.
  /// Returns null if no server name is found.
  Future<String?> getSelectedServerName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedServerNameKey);
  }

  /// Retrieves the MQTT server with the specified [name] from SharedPreferences.
  /// Returns the server if found, or null otherwise.
  Future<MqttServer?> getMqttServerByName(String name) async {
    List<MqttServer> servers = await getMqttServers();
    return servers.firstWhereOrNull((server) => server.name == name);
  }

  /// Retrieves the selected MQTT server from SharedPreferences.
  /// Returns the selected server as an `MqttServer` object if found, or `null` otherwise.
  Future<MqttServer?> getSelectedMqttServer() async {
    String? serverName = await getSelectedServerName();
    if (serverName != null) {
      return getMqttServerByName(serverName);
    }
    return null;
  }
}
