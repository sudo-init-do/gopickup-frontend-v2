import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';

class WalletTransaction {
  final double amount;
  final String type;
  final String reference;
  final String status;
  final DateTime createdAt;

  WalletTransaction({
    required this.amount,
    required this.type,
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      reference: json['reference'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository(this._apiClient);

  Future<double> getBalance() async {
    try {
      final response = await _apiClient.get('/wallet/balance');
      return (response.data['balance'] as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<WalletTransaction>> getTransactions() async {
    try {
      final response = await _apiClient.get('/wallet/transactions');
      final List<dynamic> data = response.data;
      return data.map((json) => WalletTransaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> topUp(double amount) async {
    try {
      final response = await _apiClient.post('/wallet/topup', data: {
        'amount': amount,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(apiClientProvider));
});

final balanceProvider = FutureProvider<double>((ref) {
  return ref.watch(walletRepositoryProvider).getBalance();
});

final transactionsProvider = FutureProvider<List<WalletTransaction>>((ref) {
  return ref.watch(walletRepositoryProvider).getTransactions();
});
