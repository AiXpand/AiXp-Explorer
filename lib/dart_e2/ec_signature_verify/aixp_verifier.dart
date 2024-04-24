import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:e2_explorer/dart_e2/ec_signature_verify/ec_signature_verify.dart';
import 'package:e2_explorer/dart_e2/ec_signature_verify/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

class CustomJsonEncoder {
  static num _formatFloat(num value) {
    final representation = value.toString();
    final response = representation.endsWith('.0')
        ? representation.substring(0, representation.length - 2)
        : representation;
    return num.parse(response);
  }

  static Map<String, dynamic> _handleMap(Map value) {
    Map tmpMap = value as Map;
    if (tmpMap.isNotEmpty) {
      return cleanedAndRearrangedMap(value as Map<String, dynamic>);
    } else {
      return {};
    }
  }

  static dynamic _handleKnowDataType(var value) {
    if (value is double) {
      return _formatFloat(value);
    }
    if (value is List) {
      return value.map((e) {
        return _handleKnowDataType(e);
      }).toList();
    }
    if (value is Map) {
      return _handleMap(value);
    }
    return value;
  }

  /// Set keys of in alphabetical/lexicographioc order
  /// Remove format floate ie. 89.0 -> 89
  static Map<String, dynamic> cleanedAndRearrangedMap(
    Map<String, dynamic> data,
  ) {
    Map<String, dynamic> finalData = {};
    List<String> keys = data.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    for (var key in keys) {
      var value = data[key];
      finalData[key] = _handleKnowDataType(value);
    }
    return finalData;
  }

  static String encode(Map<String, dynamic> jsonData) {
    return jsonEncode(cleanedAndRearrangedMap(jsonData));
  }
}

class AixpVerifier {
  final bool isDebug;
  AixpVerifier({this.isDebug = false});

  final _ecInstance = EcSignatureAndVerifier();
  bool _checkIfVerifiicationNeeded(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey('EE_SIGN') && jsonData.containsKey('EE_SENDER')) {
      return true;
    }
    return false;
  }

// Input: message string
// Perform: Sign a message string with our private key
// Returns: Base64 encoded hex signture
  bool verifyMessage(Map<String, dynamic> data) {
    if (_checkIfVerifiicationNeeded(data)) {
      var decoded = {...data};
      var eeSign = urlSafeBase64ToBase64(decoded["EE_SIGN"]);
      var eeSender = decoded["EE_SENDER"];
      var eeHash = decoded["EE_HASH"];
      decoded.remove("EE_SIGN");
      decoded.remove("EE_SENDER");
      decoded.remove("EE_HASH");
      var jsonData = CustomJsonEncoder.encode(decoded);
      var bytes = utf8.encode(jsonData); // Data being hashed
      var digest = sha256.convert(bytes);
      String hashHex = digest.toString();

      String sender =
          urlSafeBase64ToBase64(eeSender.replaceFirst(ADDR_PREFIX, ''));
      Uint8List publicKeyBytes = base64.decode(sender);
      ECPublicKey publicKey = _ecInstance.loadPublicKey(publicKeyBytes);

      if (eeHash == hashHex) {
        //Verify Signature with messaged hash
        bool isVerified =
            _ecInstance.verifySignature(eeSign, eeHash, publicKey);

        if (isVerified) {
          //Verify Signature with messaged hash
          isVerified = _ecInstance.verifySignature(
            eeSign,
            hashHex,
            publicKey,
          );
          if (isDebug) {
            print("EESIGN: $eeSign");
            print("EEHASH: ${eeHash}");
            print("Generated Hex:  ${digest}");
            print("EESENDER: $eeSender");
            print("Signature Verifier $isVerified");
          }

          return isVerified;
        }
      }
      print(
          " \n\n\n\n------- Verification Failed(${decoded['EE_PAYLOAD_PATH']}) ------ \n\n");

      return false;
    } else {
      return true;
    }
  }
}
