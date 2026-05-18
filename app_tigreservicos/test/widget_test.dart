import 'package:flutter_test/flutter_test.dart';

import 'package:app_serviceflow/tigreservicos/modules/service_order/ServiceOderModel.dart';

void main() {
  test('ServiceOrderModel serializes and deserializes correctly', () {
    final createdAt = DateTime(2026, 5, 18, 9);
    final date = DateTime(2026, 5, 18, 10);

    final order = ServiceOrderModel(
      id: 'order-1',
      createdAt: createdAt,
      customerId: 'customer-1',
      customerName: 'Cliente Teste',
      serviceName: 'Instalacao',
      status: ServiceOrderStatus.realized,
      date: date,
      entryPhotoBase64: 'entry',
      exitPhotoBase64: 'exit',
      signatureBase64: 'signature',
    );

    final restored = ServiceOrderModel.fromMap(order.toMap());

    expect(restored.id, 'order-1');
    expect(restored.createdAt, createdAt);
    expect(restored.customerId, 'customer-1');
    expect(restored.customerName, 'Cliente Teste');
    expect(restored.serviceName, 'Instalacao');
    expect(restored.status, ServiceOrderStatus.realized);
    expect(restored.date, date);
    expect(restored.entryPhotoBase64, 'entry');
    expect(restored.exitPhotoBase64, 'exit');
    expect(restored.signatureBase64, 'signature');
    expect(restored.isRealized, isTrue);
    expect(restored.isJustified, isFalse);
  });
}
