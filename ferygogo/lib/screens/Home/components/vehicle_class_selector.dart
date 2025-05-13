import 'package:ferry_ticket_app/models/vehicle_class.dart';
import 'package:flutter/material.dart';


class VehicleClassSelector extends StatelessWidget {
  final VehicleClass? selectedVehicleClass;
  final Function(VehicleClass?) onVehicleClassChanged;
  final String serviceType;

  const VehicleClassSelector({
    Key? key,
    required this.selectedVehicleClass,
    required this.onVehicleClassChanged,
    required this.serviceType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Golongan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: VehicleClass.allClasses.length,
          itemBuilder: (context, index) {
            final vehicleClass = VehicleClass.allClasses[index];
            final isSelected = selectedVehicleClass?.code == vehicleClass.code;
            final price = vehicleClass.getPriceWithServiceType(serviceType);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => onVehicleClassChanged(vehicleClass),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vehicleClass.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                      const Divider(height: 16),
                      Text(
                        vehicleClass.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (vehicleClass.isPricePerPerson)
                        const Text(
                          '*Harga per orang',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
