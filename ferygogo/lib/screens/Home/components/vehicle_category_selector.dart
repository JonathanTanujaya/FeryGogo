import 'package:flutter/material.dart';
import '../../../models/vehicle_category.dart';

class VehicleCategorySelector extends StatelessWidget {
  final VehicleCategory? selectedCategory;
  final Function(VehicleCategory?) onCategoryChanged;
  final String serviceType;

  const VehicleCategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.serviceType,
  }) : super(key: key);

  double getPriceWithServiceType(double basePrice, String serviceType) {
    return serviceType == 'Regular' ? basePrice : basePrice * 1.5;
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar indicator
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]
                    : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Pilih Golongan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close,
                        color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[300],
              ),
              // List of categories
              Expanded(
                child: ListView.builder(
                  itemCount: VehicleInfo.categories.length,
                  itemBuilder: (context, index) {
                    final category = VehicleInfo.categories.keys.elementAt(index);
                    final vehicleInfo = VehicleInfo.categories[category]!;
                    final price = getPriceWithServiceType(vehicleInfo.basePrice, serviceType);
                    final isSelected = selectedCategory == category;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicleInfo.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vehicleInfo.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      ),
                                    ),
                                    if (vehicleInfo.example != '-') ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Contoh: ${vehicleInfo.example}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Rp ${price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          leading: Radio<VehicleCategory>(
                            value: category,
                            groupValue: selectedCategory,
                            onChanged: (value) {
                              onCategoryChanged(value);
                              Navigator.pop(context);
                            },
                          ),
                          selected: isSelected,
                          selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          onTap: () {
                            onCategoryChanged(category);
                            Navigator.pop(context);
                          },
                        ),
                        if (index < VehicleInfo.categories.length - 1)
                          Divider(
                            height: 1,
                            color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[300],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicleInfo = selectedCategory != null ? 
        VehicleInfo.categories[selectedCategory] : null;
    final price = selectedVehicleInfo != null ? 
        getPriceWithServiceType(selectedVehicleInfo.basePrice, serviceType) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Golongan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showCategoryPicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedVehicleInfo?.name ?? 'Pilih Golongan',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedVehicleInfo != null
                            ? Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black
                            : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      if (selectedVehicleInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          selectedVehicleInfo.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (price != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      'Rp ${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
