import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  DeliveryScreenState createState() => DeliveryScreenState();
}

class DeliveryScreenState extends State<DeliveryScreen> {
  String? selectedDeliveryMethod;
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(55.751244, 37.618423); // Москва

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор доставки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Выбор способа доставки
            const Text(
              'Способ доставки',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedDeliveryMethod,
              onChanged: (value) {
                setState(() {
                  selectedDeliveryMethod = value;
                });
              },
              items: ['Курьер', 'Самовывоз']
                  .map((method) => DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Карта для выбора адреса
            if (selectedDeliveryMethod == 'Курьер')
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14.0,
                  ),
                  onMapCreated: _onMapCreated,
                ),
              ),
            if (selectedDeliveryMethod == 'Самовывоз')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Точки самовывоза',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: 3, // Пример: 3 точки самовывоза
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Точка $index'),
                        subtitle: const Text('Адрес: Улица, дом'),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Кнопка подтверждения
            ElevatedButton(
              onPressed: () {
                if (selectedDeliveryMethod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Выберите способ доставки')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Доставка выбрана')),
                  );
                }
              },
              child: const Text('Подтвердить'),
            ),
          ],
        ),
      ),
    );
  }
}
