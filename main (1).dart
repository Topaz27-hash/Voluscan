import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import 'models/parcel_measurement.dart';
import 'services/receipt_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras().catchError((_) => <CameraDescription>[]);
  runApp(VoluScanApp(cameras: cameras));
}

class VoluScanApp extends StatelessWidget {
  const VoluScanApp({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VoluScan',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7C72), primary: const Color(0xFF0A7C72), surface: const Color(0xFFF7FAF9)),
          scaffoldBackgroundColor: const Color(0xFFF7FAF9),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        ),
        home: HomePage(cameras: cameras),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 14),
              Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0A7C72), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.view_in_ar_rounded, color: Colors.white)),
                const SizedBox(width: 12),
                const Text('VoluScan', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Color(0xFF133C55))),
              ]),
              const Spacer(),
              const Text('Measure parcels.\nPrice shipments smarter.', style: TextStyle(fontSize: 34, height: 1.12, fontWeight: FontWeight.w800, color: Color(0xFF133C55))),
              const SizedBox(height: 12),
              const Text('Calculate volumetric and chargeable weight in seconds.', style: TextStyle(fontSize: 16, color: Color(0xFF60747F))),
              const SizedBox(height: 35),
              _ActionCard(icon: Icons.center_focus_strong, title: 'Scan package', subtitle: 'Use your camera and confirm measurements', filled: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScanPage(cameras: cameras)))),
              const SizedBox(height: 14),
              _ActionCard(icon: Icons.straighten, title: 'Enter manually', subtitle: 'Type length, width and height', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeasurementPage()))),
              const Spacer(flex: 2),
              const Center(child: Text('Measurements use centimetres • Weight uses kilograms', style: TextStyle(fontSize: 12, color: Color(0xFF788A92)))),
            ]),
          ),
        ),
      );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.filled = false});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap; final bool filled;
  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: filled ? const Color(0xFF0A7C72) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: filled ? BorderSide.none : const BorderSide(color: Color(0xFFE3EBE8))),
        child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Icon(icon, size: 30, color: filled ? Colors.white : const Color(0xFF0A7C72)), const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: filled ? Colors.white : const Color(0xFF133C55))), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: filled ? Colors.white70 : const Color(0xFF60747F)))])),
          Icon(Icons.arrow_forward_rounded, color: filled ? Colors.white : const Color(0xFF0A7C72)),
        ]))),
      );
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.cameras});
  final List<CameraDescription> cameras;
  @override State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? controller;
  bool captured = false;
  @override void initState() { super.initState(); if (widget.cameras.isNotEmpty) { controller = CameraController(widget.cameras.first, ResolutionPreset.high, enableAudio: false); controller!.initialize().then((_) { if (mounted) setState(() {}); }); } }
  @override void dispose() { controller?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('Scan package')),
    body: Stack(fit: StackFit.expand, children: [
      if (controller?.value.isInitialized == true) CameraPreview(controller!) else const Center(child: Text('Camera unavailable', style: TextStyle(color: Colors.white))),
      Center(child: Container(margin: const EdgeInsets.all(35), decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(24)))),
      Positioned(left: 24, right: 24, bottom: 30, child: Column(children: [
        Text(captured ? 'Photo captured. Confirm the measured dimensions.' : 'Fit the entire parcel inside the frame', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF133C55), minimumSize: const Size.fromHeight(54)), onPressed: () async {
          if (!captured && controller?.value.isInitialized == true) { await controller!.takePicture(); setState(() => captured = true); return; }
          if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MeasurementPage(cameraAssisted: true)));
        }, icon: Icon(captured ? Icons.check : Icons.camera_alt), label: Text(captured ? 'Confirm measurements' : 'Capture parcel')),
      ])),
    ]),
  );
}

class MeasurementPage extends StatefulWidget {
  const MeasurementPage({super.key, this.cameraAssisted = false});
  final bool cameraAssisted;
  @override State<MeasurementPage> createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> {
  final formKey = GlobalKey<FormState>();
  final length = TextEditingController(); final width = TextEditingController(); final height = TextEditingController();
  final actual = TextEditingController(); final divisor = TextEditingController(text: '5000'); final reference = TextEditingController();
  double? number(String value) => double.tryParse(value.trim());
  @override void dispose() { for (final c in [length,width,height,actual,divisor,reference]) { c.dispose(); } super.dispose(); }
  void calculate() {
    if (!formKey.currentState!.validate()) return;
    final parcel = ParcelMeasurement(length: number(length.text)!, width: number(width.text)!, height: number(height.text)!, divisor: number(divisor.text)!, actualWeight: actual.text.trim().isEmpty ? null : number(actual.text), reference: reference.text);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(parcel: parcel)));
  }
  String? positive(String? value) { final v = number(value ?? ''); return v == null || v <= 0 ? 'Enter a valid number' : null; }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.cameraAssisted ? 'Confirm measurements' : 'Manual measurement')),
    body: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      if (widget.cameraAssisted) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFEAF7F4), borderRadius: BorderRadius.circular(14)), child: const Text('Camera-assisted scan captured. Enter or correct the detected parcel dimensions before calculating.')),
      const SizedBox(height: 18),
      const Text('Parcel dimensions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF133C55))), const SizedBox(height: 14),
      Row(children: [Expanded(child: _field(length, 'Length', 'cm', positive)), const SizedBox(width: 10), Expanded(child: _field(width, 'Width', 'cm', positive)), const SizedBox(width: 10), Expanded(child: _field(height, 'Height', 'cm', positive))]),
      const SizedBox(height: 18),
      _field(actual, 'Actual weight (optional)', 'kg', (v) => v == null || v.trim().isEmpty ? null : positive(v)), const SizedBox(height: 12),
      _field(divisor, 'Volumetric divisor', '', positive), const SizedBox(height: 12),
      TextFormField(controller: reference, decoration: const InputDecoration(labelText: 'Shipment reference (optional)', prefixIcon: Icon(Icons.tag))),
      const SizedBox(height: 26),
      FilledButton(onPressed: calculate, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)), child: const Text('Calculate weight')),
    ])),
  );
  Widget _field(TextEditingController c, String label, String suffix, String? Function(String?) validator) => TextFormField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))], validator: validator, decoration: InputDecoration(labelText: label, suffixText: suffix));
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.parcel});
  final ParcelMeasurement parcel;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Package result')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFF133C55), borderRadius: BorderRadius.circular(24)), child: Column(children: [
        const Text('CHARGEABLE WEIGHT', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), const SizedBox(height: 8),
        Text('${parcel.chargeableWeight.toStringAsFixed(2)} kg', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
      ])), const SizedBox(height: 20),
      _resultRow('Dimensions', '${parcel.length.toStringAsFixed(1)} × ${parcel.width.toStringAsFixed(1)} × ${parcel.height.toStringAsFixed(1)} cm'),
      _resultRow('Volumetric weight', '${parcel.volumetricWeight.toStringAsFixed(2)} kg'),
      _resultRow('Actual weight', parcel.actualWeight == null ? 'Not provided' : '${parcel.actualWeight!.toStringAsFixed(2)} kg'),
      _resultRow('Divisor', parcel.divisor.toStringAsFixed(0)),
      const SizedBox(height: 22),
      FilledButton.icon(onPressed: () async { final bytes = await ReceiptService.build(parcel); await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'VoluScan receipt'); }, icon: const Icon(Icons.picture_as_pdf), label: const Text('Create PDF receipt'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56))),
      const SizedBox(height: 10),
      OutlinedButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)), child: const Text('Scan another package')),
    ]),
  );
  Widget _resultRow(String label, String value) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Color(0xFF60747F))), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF133C55))))]));
}
