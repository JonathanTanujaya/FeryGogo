enum VehicleCategory {
  none,      // Pejalan kaki
  golongan1, // Sepeda kayuh
  golongan2, // Sepeda motor < 500cc
  golongan3, // Sepeda motor ≥ 500cc
  golongan4A, // Mobil penumpang kecil
  golongan4B, // Mobil barang kecil (pikap)
  golongan5A, // Bus kecil
  golongan5B, // Truk kecil
  golongan6A, // Bus sedang
  golongan6B, // Truk sedang
  golongan7, // Bus besar
  golongan8, // Truk besar (3 sumbu)
  golongan9, // Truk trailer
}

class VehicleInfo {
  final VehicleCategory category;
  final String name;
  final String description;
  final String example;
  final double basePrice;

  const VehicleInfo({
    required this.category,
    required this.name,
    required this.description,
    required this.example,
    required this.basePrice,
  });

  static Map<VehicleCategory, VehicleInfo> get categories => {
    VehicleCategory.none: VehicleInfo(
      category: VehicleCategory.none,
      name: 'Pejalan Kaki',
      description: 'Penumpang tanpa kendaraan',
      example: '-',
      basePrice: 25000, // Rp 20.000 - Rp 30.000
    ),
    VehicleCategory.golongan1: VehicleInfo(
      category: VehicleCategory.golongan1,
      name: 'Golongan I',
      description: 'Sepeda kayuh',
      example: 'Gowes/bike',
      basePrice: 50000, // Rp 40.000 - Rp 60.000
    ),
    VehicleCategory.golongan2: VehicleInfo(
      category: VehicleCategory.golongan2,
      name: 'Golongan II',
      description: 'Sepeda motor < 500cc',
      example: 'Motor bebek/matic kecil',
      basePrice: 80000, // Rp 70.000 - Rp 90.000
    ),
    VehicleCategory.golongan4A: VehicleInfo(
      category: VehicleCategory.golongan4A,
      name: 'Golongan IV A',
      description: 'Mobil penumpang kecil',
      example: 'Sedan, Avanza, Mobilio',
      basePrice: 575000, // Rp 500.000 - Rp 650.000
    ),
    VehicleCategory.golongan5B: VehicleInfo(
      category: VehicleCategory.golongan5B,
      name: 'Golongan V B',
      description: 'Truk kecil',
      example: 'Truk Colt Diesel (engkel)',
      basePrice: 950000, // Rp 800.000 - Rp 1.100.000
    ),
  };
}