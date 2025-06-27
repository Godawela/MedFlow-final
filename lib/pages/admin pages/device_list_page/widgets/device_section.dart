import 'package:flutter/material.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/device_header.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/device_list.dart';
import 'package:med/pages/admin%20pages/device_list_page/widgets/empty_device_widget.dart';

class DevicesSection extends StatelessWidget {
  final List devices;
  final String category;
  final List<Color> Function(int) getDeviceColors;
  final IconData Function(String) getDeviceIcon;
  final Function(Map<String, dynamic>) onDeviceTap;

  const DevicesSection({
    super.key,
    required this.devices,
    required this.category,
    required this.getDeviceColors,
    required this.getDeviceIcon,
    required this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DevicesHeader(deviceCount: devices.length),
        const SizedBox(height: 16),
        SizedBox(
          height: 400, // Fixed height to prevent sizing issues
          child: devices.isEmpty
              ? EmptyDevicesWidget(category: category)
              : DevicesList(
                  devices: devices,
                  getDeviceColors: getDeviceColors,
                  getDeviceIcon: getDeviceIcon,
                  onDeviceTap: onDeviceTap,
                ),
        ),
      ],
    );
  }
}
