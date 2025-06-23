import 'package:flutter/material.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/device_card.dart';

class DevicesList extends StatelessWidget {
  final List devices;
  final List<Color> Function(int) getDeviceColors;
  final IconData Function(String) getDeviceIcon;
  final Function(Map<String, dynamic>) onDeviceTap;

  const DevicesList({
    Key? key,
    required this.devices,
    required this.getDeviceColors,
    required this.getDeviceIcon,
    required this.onDeviceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return DeviceCard(
          device: device,
          index: index,
          colors: getDeviceColors(index),
          icon: getDeviceIcon(device['name']),
          onTap: () => onDeviceTap(device),
        );
      },
    );
  }
}
