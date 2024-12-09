import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/common/index.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'index.dart';

class QrcodeScannerPage extends GetView<QrcodeScannerController> {
  const QrcodeScannerPage({Key? key}) : super(key: key);

  // 主视图
  Widget _buildView(BuildContext context) {
    return _buildQrView(context);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QrcodeScannerController>(
      init: QrcodeScannerController(),
      id: "qrcode_scanner",
      builder: (_) {
        return Scaffold(
          appBar: MyAppBar(
            context,
            '扫描二维码',
            showBackIcon: true,
          ),
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: controller.qrKey,
      onQRViewCreated: controller.onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
