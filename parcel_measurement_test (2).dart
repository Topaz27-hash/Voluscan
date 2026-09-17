import 'package:flutter_test/flutter_test.dart';
import 'package:voluscan/models/parcel_measurement.dart';

void main() {
  test('calculates volumetric and chargeable weight', () {
    const parcel = ParcelMeasurement(length: 40, width: 30, height: 25, divisor: 5000, actualWeight: 4.2);
    expect(parcel.volumetricWeight, 6);
    expect(parcel.chargeableWeight, 6);
  });

  test('actual weight wins when greater', () {
    const parcel = ParcelMeasurement(length: 20, width: 20, height: 20, divisor: 5000, actualWeight: 3);
    expect(parcel.chargeableWeight, 3);
  });
}
