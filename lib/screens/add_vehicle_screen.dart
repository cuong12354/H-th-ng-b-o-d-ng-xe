import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  String _vehicleType = 'Xe tay ga'; // Default

  final List<String> _types = ['Xe tay ga', 'Xe số', 'Xe côn tay', 'Khác'];

  void _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      final success = await provider.addVehicle(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        color: _colorController.text.trim(),
        vehicleType: _vehicleType,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm phương tiện thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF26522)),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thêm phương tiện mới'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.directions_bike, size: 60, color: Color(0xFFF26522)),
                  const SizedBox(height: 24),
                  _buildInput('Hãng xe (VD: Honda, Yamaha...)', _brandController),
                  _buildInput('Dòng xe (VD: AirBlade, Exciter...)', _modelController),
                  _buildInput('Biển số xe (VD: 59X1-123.45)', _licensePlateController),
                  
                  Row(
                    children: [
                      Expanded(child: _buildInput('Năm sản xuất', _yearController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInput('Màu sắc', _colorController)),
                    ],
                  ),
                  
                  DropdownButtonFormField<String>(
                    value: _vehicleType,
                    decoration: InputDecoration(
                      labelText: 'Loại xe',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (value) => setState(() => _vehicleType = value!),
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _addVehicle,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFF26522),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('LƯU PHƯƠNG TIỆN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
