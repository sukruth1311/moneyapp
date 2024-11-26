// import 'package:encrypt/encrypt.dart' as encrypt;
// import 'package:encrypt/encrypt.dart';

// class EncryptionUtil {
//   // 32-byte key and 16-byte IV
//   static final encrypt.Key _key =
//       encrypt.Key.fromUtf8('my32charsecurepassword');
//   static final encrypt.IV _iv = encrypt.IV.fromLength(16);

//   /// Encrypts the given [text] and returns the encrypted string.
//   static String encrypt(String text) {
//     final encrypter = encrypt.Encrypter(encrypt.AES(_key));
//     return encrypter.encrypt(text, iv: _iv).base64;
//   }

//   /// Decrypts the given [encryptedText] and returns the original string.
//   static String decrypt(String encryptedText) {
//     final encrypter = encrypt.Encrypter(encrypt.AES(_key));
//     return encrypter.decrypt64(encryptedText, iv: _iv);
//   }
// }
