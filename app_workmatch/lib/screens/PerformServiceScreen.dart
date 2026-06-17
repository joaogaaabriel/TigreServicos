import 'package:app_workmatch/tigreservicos/core/model/CustomerModel.dart';
import 'package:app_workmatch/tigreservicos/core/repositories/ServiceOrderRepository.dart';
import 'package:flutter/material.dart';

class PerformServiceScreen extends StatelessWidget {
  final CustomerModel customer;
  final ServiceOrderRepository repository;

  const PerformServiceScreen({
    super.key,
    required this.customer,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(customer.name)),
    );
  }
}
