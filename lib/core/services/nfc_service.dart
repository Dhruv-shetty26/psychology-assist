import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:ndef_record/ndef_record.dart';

class NfcService {
  static final NfcService _instance = NfcService._internal();

  factory NfcService() {
    return _instance;
  }

  NfcService._internal();

  Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      return false;
    }
  }

  Future<bool> writeFeatureToTag(String featureId) async {
    final completer = Completer<bool>();
    
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          
          Uint8List uriBytes = Uint8List.fromList(utf8.encode('calmora://feature/$featureId'));
          Uint8List payload = Uint8List(uriBytes.length + 1);
          payload[0] = 0x00; // No prefix
          payload.setAll(1, uriBytes);

          NdefRecord uriRecord = NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([0x55]), // 'U'
            identifier: Uint8List(0),
            payload: payload,
          );

          NdefMessage message = NdefMessage(records: [uriRecord]);

          if (ndef == null) {
            // Tag is not NDEF formatted, try to format it if on Android
            if (defaultTargetPlatform == TargetPlatform.android) {
              var formatable = NdefFormatableAndroid.from(tag);
              if (formatable != null) {
                try {
                  await formatable.format(message);
                  NfcManager.instance.stopSession();
                  if (!completer.isCompleted) completer.complete(true);
                  return;
                } catch (e) {
                  NfcManager.instance.stopSession(errorMessageIos: 'Failed to format tag');
                  if (!completer.isCompleted) completer.complete(false);
                  return;
                }
              }
            }
            NfcManager.instance.stopSession(errorMessageIos: 'Tag is not writable');
            if (!completer.isCompleted) completer.complete(false);
            return;
          }

          if (!ndef.isWritable) {
            NfcManager.instance.stopSession(errorMessageIos: 'Tag is not writable');
            if (!completer.isCompleted) completer.complete(false);
            return;
          }

          try {
            await ndef.write(message: message);
            NfcManager.instance.stopSession();
            if (!completer.isCompleted) completer.complete(true);
          } catch (e) {
            NfcManager.instance.stopSession(errorMessageIos: 'Failed to write tag');
            if (!completer.isCompleted) completer.complete(false);
          }
        },
      );
    } catch (e) {
      debugPrint('Error starting NFC session: $e');
      if (!completer.isCompleted) completer.complete(false);
    }
    
    return completer.future;
  }
}
