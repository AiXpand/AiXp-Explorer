import 'dart:convert';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:e2_explorer/dart_e2/ec_signature_verify/utils.dart';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class EcSignatureAndVerifier {
  // Initialize elliptic curve parameters for secp256k1
  var secp256k1DomainParameter = ECDomainParameters('secp256k1');

  // Use secp256k1/s-256 curver
  ECCurve get curve => secp256k1DomainParameter.curve;

  SecureRandom getSecureRandom() {
    final seed = Uint8List(32); // 256 bits
    final random = Random.secure();
    for (int i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    final secureRandom = FortunaRandom();
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> generateSecp256k1KeyPair() {
    ///Intialize 256 Seed Randomizer
    final secureRandom = getSecureRandom();
    final keyGenerationParameters =
        ECKeyGeneratorParameters(secp256k1DomainParameter);
    final generator = KeyGenerator('EC');
    generator.init(ParametersWithRandom(keyGenerationParameters, secureRandom));
    return generator.generateKeyPair();
  }

  String unCompressPublicKey(ECPublicKey publicKey) {
    // Get the X coordinate
    var xCoord = publicKey.Q!.x!.toBigInteger();

    // Determine the prefix based on the Y coordinate's parity
    var prefix = publicKey.Q!.y!.toBigInteger()!.isEven ? '02' : '03';

    // Convert the X coordinate to a hex string and pad it to ensure it's 64 characters long
    var xHex = xCoord?.toRadixString(16).padLeft(64, '0');

    // Concatenate the prefix and the X coordinate hex string
    return prefix + xHex!;
  }

  String compressPublicKey(ECPublicKey publicKey) {
    // Get the X coordinate
    var xCoord = publicKey.Q!.x!.toBigInteger();

    // Determine the prefix based on the Y coordinate's parity
    var prefix = publicKey.Q!.y!.toBigInteger()!.isEven ? '02' : '03';

    // Convert the X coordinate to a hex string and pad it to ensure it's 64 characters long
    var xHex = xCoord?.toRadixString(16).padLeft(64, '0');

    // Concatenate the prefix and the X coordinate hex string
    return prefix + xHex!;
  }

  String getCompressedPublicKeyBase64(ECPublicKey publicKey,
      {bool isUrlSaveBase64 = false}) {
    String compressedPublicKey = compressPublicKey(publicKey);
    Uint8List publicKeyBytes =
        Uint8List.fromList(hex.decode(compressedPublicKey));
    String base64CompressedPublicKey = base64.encode(publicKeyBytes);
    return isUrlSaveBase64
        ? base64ToUrlSafeBase64(base64CompressedPublicKey)
        : base64CompressedPublicKey;
  }

  String getAddressFromPublicKey(ECPublicKey publicKey) {
    return ADDR_PREFIX[0] +
        getCompressedPublicKeyBase64(publicKey, isUrlSaveBase64: true);
  }

  // Load the public key from Uint8List/Buffer Data
  ECPublicKey derivePublicKey(ECPrivateKey privateKey) {
    // Obtain the domain parameters. For secp256k1, you can use:
    final domainParams = ECDomainParameters('secp256k1');

    // Get the generator point (G) from the domain parameters
    final G = domainParams.G;

    // Multiply the generator point (G) by the private key (d)
    final Q = G * privateKey.d;

    // Create the public key from Q
    return ECPublicKey(Q, domainParams);
  }

  // Load the public key from Uint8List/Buffer Data
  ECPublicKey loadPublicKey(Uint8List bytes) {
    ECPoint point = secp256k1DomainParameter.curve.decodePoint(bytes)!;
    return ECPublicKey(point, secp256k1DomainParameter);
  }

  String signHashToBase64(String hashHex, ECPrivateKey privateKey) {
    // Convert the hex-encoded hash string to bytes
    Uint8List hashBytes = Uint8List.fromList(hex.decode(hashHex));

    // a suitable random number generator - create it just once and reuse
    final rand = Random.secure();
    final fortunaPrng = FortunaRandom()
      ..seed(KeyParameter(Uint8List.fromList(List<int>.generate(
        32,
        (_) => rand.nextInt(256),
      ))));

    // the ECDSA signer using SHA-256
    final signer = ECDSASigner(SHA256Digest())
      ..init(
        true,
        ParametersWithRandom(
          PrivateKeyParameter(privateKey),
          fortunaPrng,
        ),
      );

    final ecSignature = signer.generateSignature(hashBytes) as ECSignature;

    final encoded = ASN1Sequence(elements: [
      ASN1Integer(ecSignature.r),
      ASN1Integer(ecSignature.s),
    ]).encode();

    // Convert the signature bytes to a base64 string
    return base64ToUrlSafeBase64(base64Encode(encoded));
  }

  ECSignature parseBase64EncodedSignature(String base64Signature) {
    Uint8List signatureBytes = base64Decode(
      urlSafeBase64ToBase64(base64Signature),
    );

    // The signature format and length might vary. This is an example.
    // secp256k1 signatures typically contain two 32-byte components (r and s).
    int splitIndex = signatureBytes.length ~/ 2;
    Uint8List rBytes = signatureBytes.sublist(0, splitIndex);
    Uint8List sBytes = signatureBytes.sublist(splitIndex);

    BigInt r = bytesToBigInt(rBytes);
    BigInt s = bytesToBigInt(sBytes);

    return ECSignature(r, s);
  }

  BigInt bytesToBigInt(Uint8List bytes) {
    return BigInt.parse(hex.encode(bytes), radix: 16);
  }

  bool verifySignature(
    String base64Signature,
    String hashHex,
    ECPublicKey publicKey,
  ) {
    // Decode the base64 signature to bytes
    Uint8List signatureBytes = base64Decode(base64Signature);

    // Decode ASN.1 signature to extract r and s values
    ASN1Parser parser = ASN1Parser(signatureBytes);
    ASN1Sequence sequence = parser.nextObject() as ASN1Sequence;
    ECSignature ecSignature = ECSignature(
      (sequence.elements?[0] as ASN1Integer).integer!,
      (sequence.elements?[1] as ASN1Integer).integer!,
    );

    // Convert the hex-encoded hash string to bytes
    Uint8List hashBytes = Uint8List.fromList(hex.decode(hashHex));

    // Initialize the ECDSA signer for verification
    final signer = ECDSASigner(SHA256Digest());
    signer.init(
      false, // false for verification
      PublicKeyParameter<ECPublicKey>(publicKey),
    );

    // Verify the signature
    return signer.verifySignature(hashBytes, ecSignature);
  }
}
