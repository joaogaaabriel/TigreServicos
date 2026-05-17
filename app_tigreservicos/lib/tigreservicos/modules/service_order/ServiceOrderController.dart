import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import 'CustomerModel.dart';
import 'ServiceOrderRepository.dart';

class ServiceOrderController extends ChangeNotifier {
  ServiceOrderController({required ServiceOrderRepository repository})
      : _repository = repository;

  final ServiceOrderRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();
  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black87,
    exportBackgroundColor: Colors.white,
  );

  String? _entryPhotoBase64;
  String? _exitPhotoBase64;
  bool _isSaving = false;

  String? get entryPhotoBase64 => _entryPhotoBase64;
  String? get exitPhotoBase64 => _exitPhotoBase64;
  bool get isSaving => _isSaving;

  // Lê direto do signatureController na hora — sem listener
  bool get canFinishRealized =>
      _entryPhotoBase64 != null &&
      _exitPhotoBase64 != null &&
      !signatureController.isEmpty;

  Future<void> pickEntryPhotoFrom(ImageSource source) async {
    _entryPhotoBase64 = await _pickImageAsBase64(source) ?? _entryPhotoBase64;
    notifyListeners();
  }

  Future<void> pickExitPhotoFrom(ImageSource source) async {
    _exitPhotoBase64 = await _pickImageAsBase64(source) ?? _exitPhotoBase64;
    notifyListeners();
  }

  void clearSignature() {
    signatureController.clear();
    notifyListeners();
  }

  Future<void> saveRealized(CustomerModel customer) async {
    final signatureBase64 = await _signatureToBase64();
    if (_entryPhotoBase64 == null ||
        _exitPhotoBase64 == null ||
        signatureBase64 == null) {
      throw Exception('Preencha foto de entrada, foto de saida e assinatura.');
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _repository.saveRealizedOrder(
        customer: customer,
        entryPhotoBase64: _entryPhotoBase64!,
        exitPhotoBase64: _exitPhotoBase64!,
        signatureBase64: signatureBase64,
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveJustified({
    required CustomerModel customer,
    required String justification,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _repository.saveJustifiedOrder(
        customer: customer,
        justification: justification,
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> _pickImageAsBase64(ImageSource source) async {
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 60,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<String?> _signatureToBase64() async {
    final pngBytes = await signatureController.toPngBytes();
    if (pngBytes == null) return null;
    return base64Encode(pngBytes);
  }

  Uint8List decodeBase64Image(String value) => base64Decode(value);

  @override
  void dispose() {
    signatureController.dispose();
    super.dispose();
  }
}
