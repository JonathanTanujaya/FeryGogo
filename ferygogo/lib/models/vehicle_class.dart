class VehicleClass {
  final String code;
  final String name;
  final String description;
  final double basePrice;
  final bool isPricePerPerson;

  const VehicleClass({
    required this.code,
    required this.name,
    required this.description,
    required this.basePrice,
    this.isPricePerPerson = false,
  });

  double getPriceWithServiceType(String serviceType) {
    return serviceType == 'Regular' ? basePrice : basePrice * 1.5;
  }

  static final List<VehicleClass> allClasses = [
    VehicleClass(
      code: 'PEDESTRIAN',
      name: 'Pejalan Kaki',
      description: 'Dewasa: Rp 15.000\nAnak-anak: Rp 10.000',
      basePrice: 15000, // Base price for adults
      isPricePerPerson: true,
    ),
    VehicleClass(
      code: 'GOL1',
      name: 'Golongan I',
      description: 'Sepeda',
      basePrice: 25000,
    ),
    VehicleClass(
      code: 'GOL2',
      name: 'Golongan II',
      description: 'Sepeda Motor < 500cc',
      basePrice: 50000,
    ),
    VehicleClass(
      code: 'GOL3',
      name: 'Golongan III',
      description: 'Sepeda Motor ≥ 500cc',
      basePrice: 70000,
    ),
    VehicleClass(
      code: 'GOL4A',
      name: 'Golongan IV A',
      description: 'Mobil Penumpang',
      basePrice: 150000,
    ),
    VehicleClass(
      code: 'GOL4B',
      name: 'Golongan IV B',
      description: 'Mobil Barang',
      basePrice: 200000,
    ),
    VehicleClass(
      code: 'GOL5A',
      name: 'Golongan V A',
      description: 'Bus Sedang',
      basePrice: 300000,
    ),
    VehicleClass(
      code: 'GOL5B',
      name: 'Golongan V B',
      description: 'Truk Sedang',
      basePrice: 400000,
    ),
    VehicleClass(
      code: 'GOL6A',
      name: 'Golongan VI A',
      description: 'Bus Besar',
      basePrice: 500000,
    ),
    VehicleClass(
      code: 'GOL6B',
      name: 'Golongan VI B',
      description: 'Truk Besar',
      basePrice: 600000,
    ),
    VehicleClass(
      code: 'GOL7',
      name: 'Golongan VII',
      description: 'Truk Gandeng',
      basePrice: 700000,
    ),
    VehicleClass(
      code: 'GOL8',
      name: 'Golongan VIII',
      description: 'Truk Trailer',
      basePrice: 800000,
    ),
    VehicleClass(
      code: 'GOL9',
      name: 'Golongan IX',
      description: 'Truk Trailer Besar',
      basePrice: 900000,
    ),
  ];
}
