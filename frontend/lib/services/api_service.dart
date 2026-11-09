import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl;

  ApiService() : _baseUrl = dotenv.env['API_URL'] ?? 'https:/localhost:5000';

  Future<List<Map<String, dynamic>>> analyzeXRay(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/predict',
        data: formData,
      );

      if (response.statusCode == 200) {
        final List<dynamic> predictions = response.data['predictions'];
        return predictions.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to analyze X-ray');
      }
    } catch (e) {
      throw Exception('Error analyzing X-ray: $e');
    }
  }
}
