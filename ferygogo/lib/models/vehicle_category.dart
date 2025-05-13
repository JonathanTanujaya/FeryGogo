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
  });  static Map<VehicleCategory, VehicleInfo> get categories => {
    VehicleCategory.none: VehicleInfo(
      category: VehicleCategory.none,
      name: 'Gol 1',
      description: 'Pejalan Kaki',
      example: 'Penumpang tanpa kendaraan',
      basePrice: 25000,
    ),
    VehicleCategory.golongan1: VehicleInfo(
      category: VehicleCategory.golongan1,
      name: 'Gol 2',
      description: 'Sepeda',
      example: 'Gowes/bike',
      basePrice: 50000,
    ),    VehicleCategory.golongan2: VehicleInfo(
      category: VehicleCategory.golongan2,
      name: 'Gol 3',
      description: 'Sepeda motor < 500cc',
      example: 'Motor bebek/matic kecil',
      basePrice: 80000,
    ),    VehicleCategory.golongan3: VehicleInfo(
      category: VehicleCategory.golongan3,
      name: 'Gol 3',
      description: 'Sepeda motor ≥ 500cc',
      example: 'Motor sport besar',
      basePrice: 100000,
    ),
    VehicleCategory.golongan4A: VehicleInfo(
      category: VehicleCategory.golongan4A,
      name: 'Gol 4A',
      description: 'Mobil penumpang kecil',
      example: 'Sedan, Avanza, Mobilio',
      basePrice: 575000,
    ),
    VehicleCategory.golongan4B: VehicleInfo(
      category: VehicleCategory.golongan4B,
      name: 'Gol 4B',
      description: 'Mobil barang kecil',
      example: 'Pickup',
      basePrice: 600000,
    ),
    VehicleCategory.golongan5A: VehicleInfo(
      category: VehicleCategory.golongan5A,
      name: 'Gol 5A',
      description: 'Bus kecil',
      example: 'ELF, APV',
      basePrice: 850000,
    ),
    VehicleCategory.golongan5B: VehicleInfo(
      category: VehicleCategory.golongan5B,
      name: 'Gol 5B',
      description: 'Truk kecil',
      example: 'Truk Colt Diesel (engkel)',
      basePrice: 950000,
    ),
    VehicleCategory.golongan6A: VehicleInfo(
      category: VehicleCategory.golongan6A,
      name: 'Gol 6A',
      description: 'Bus sedang',
      example: 'Bus medium',
      basePrice: 1200000,
    ),
    VehicleCategory.golongan6B: VehicleInfo(
      category: VehicleCategory.golongan6B,
      name: 'Gol 6B',
      description: 'Truk sedang',
      example: 'Truk dua gandar',
      basePrice: 1300000,
    ),
    VehicleCategory.golongan7: VehicleInfo(
      category: VehicleCategory.golongan7,
      name: 'Gol 7',
      description: 'Bus besar',
      example: 'Bus tingkat',
      basePrice: 1500000,
    ),
    VehicleCategory.golongan8: VehicleInfo(
      category: VehicleCategory.golongan8,
      name: 'Gol 8',
      description: 'Truk besar',
      example: 'Truk tiga sumbu',
      basePrice: 1800000,
    ),
    VehicleCategory.golongan9: VehicleInfo(
      category: VehicleCategory.golongan9,
      name: 'Gol 9',
      description: 'Truk trailer',
      example: 'Trailer gandeng',
      basePrice: 2500000,
    ),
  };
}