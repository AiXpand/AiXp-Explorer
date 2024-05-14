import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

const ADDR_PREFIX = ['aixp_', '0xai_'];

const INITIATORIDPREFIX = 'explorer_';

Uint8List bigIntToUint8List(BigInt bigInt) {
  // Convert BigInt to a byte list
  var byteList = bigInt.toRadixString(16).padLeft(64, '0'); // Ensure 32 bytes
  return Uint8List.fromList(List.generate(byteList.length ~/ 2,
      (i) => int.parse(byteList.substring(i * 2, i * 2 + 2), radix: 16)));
}

String minimfyAdddressToShow(String walletAddress) {
  if (walletAddress.length < 3) {
    return '...';
  }
  if (walletAddress.length < 15) {
    walletAddress.replaceRange((walletAddress.length / 2).round() - 1,
        (walletAddress.length / 2).round(), '..');
  }
  return walletAddress.replaceRange(9, walletAddress.length - 5, '...');
}

BigInt bytesToBigInt(Uint8List bytes) {
  return BigInt.parse(hex.encode(bytes), radix: 16);
}

String urlSafeBase64ToBase64(String urlSafeBase64) {
  return urlSafeBase64.replaceAll('-', '+').replaceAll('_', '/');
}

String base64ToUrlSafeBase64(String base64) {
  return base64.replaceAll('+', '-').replaceAll('/', '_');
}

dynamic deterministicJsonEncode(dynamic value) {
  // If the value is a Map, sort it recursively
  if (value is Map) {
    final sortedMap = <String, dynamic>{};
    var keys = value.keys.toList()..sort();
    for (var key in keys) {
      sortedMap[key] = deterministicJsonEncode(value[key]);
    }
    return jsonEncode(sortedMap);
  }
  // If the value is a List, apply the function to each element
  else if (value is List) {
    return jsonEncode(
        value.map((item) => deterministicJsonEncode(item)).toList());
  }
  // For other types, just return the value
  else {
    return value;
  }
}
