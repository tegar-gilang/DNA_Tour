// Provider definitions for core dependencies
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';

/// Provides a singleton [ApiClient] instance.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Provides a singleton [SecureStorage] instance.
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());
