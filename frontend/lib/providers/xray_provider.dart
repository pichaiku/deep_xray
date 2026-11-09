import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';

class XRayProvider with ChangeNotifier {
  final _picker = ImagePicker();
  final _apiService = ApiService();
  File? _currentXRay;
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = false;
  String? _error;

  File? get currentXRay => _currentXRay;
  List<Map<String, dynamic>> get predictions => _predictions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> pickXRay() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      if (image != null) {
        _currentXRay = File(image.path);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error picking image: $e';
      notifyListeners();
    }
  }

  Future<void> captureXRay() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      
      if (image != null) {
        _currentXRay = File(image.path);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error capturing image: $e';
      notifyListeners();
    }
  }

  Future<void> analyzeXRay() async {
    if (_currentXRay == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _predictions = await _apiService.analyzeXRay(_currentXRay!);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error analyzing X-ray: $e';
      notifyListeners();
    }
  }

  Future<void> saveXRay() async {
    if (_currentXRay == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedPath = '${directory.path}/xray_$timestamp.jpg';
      
      await _currentXRay!.copy(savedPath);
      _error = null;
    } catch (e) {
      _error = 'Error saving X-ray: $e';
      notifyListeners();
    }
  }

  void clearCurrentXRay() {
    _currentXRay = null;
    _predictions = [];
    _error = null;
    notifyListeners();
  }
} 