class ParcelMeasurement {
  const ParcelMeasurement({
    required this.length,
    required this.width,
    required this.height,
    required this.divisor,
    this.actualWeight,
    this.reference = '',
  });

  final double length;
  final double width;
  final double height;
  final double divisor;
  final double? actualWeight;
  final String reference;

  double get volumetricWeight => length * width * height / divisor;
  double get chargeableWeight => actualWeight == null
      ? volumetricWeight
      : (actualWeight! > volumetricWeight ? actualWeight! : volumetricWeight);
}
