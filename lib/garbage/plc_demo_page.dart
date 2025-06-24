// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:plc_demo/plc_service.dart';
// import 'package:plc_demo/service/plc_consumer.dart';

// class PLCDemoPage extends StatefulWidget {
//   const PLCDemoPage({Key? key}) : super(key: key);
//   @override
//   _PLCDemoPageState createState() => _PLCDemoPageState();
// }

// class _PLCDemoPageState extends State<PLCDemoPage> {
//   final plcService = PLCService();
//   bool isConnected = false;
//   Timer? _readTimer;
//   bool _shouldKeepReading = false;

//   static const String boolAddress = "DB1.DBX0.0";
//   static const String intAddress  = "DB1.DBW2";
//   static const String dintAddress = "DB1.DBD4";
//   static const String realAddress = "DB1.DBD8";

//   // final TextEditingController intController   = TextEditingController();
//   // final TextEditingController dintController  = TextEditingController();
//   // final TextEditingController realController  = TextEditingController();

//   // final FocusNode intFocus  = FocusNode();
//   // final FocusNode dintFocus = FocusNode();
//   // final FocusNode realFocus = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _stopContinuousReading();
//     intController.dispose();
//     dintController.dispose();
//     realController.dispose();
//     intFocus.dispose();
//     dintFocus.dispose();
//     realFocus.dispose();
//     if (isConnected) plcService.disconnect();
//     super.dispose();
//   }

// // Future<void> connectToPLC() async {
// //   final success = await plcService.connect("192.168.0.1", 0, 1);
// //   setState(() => isConnected = success);
// //   if (success) {
// //     _startContinuousReading();
// //     showSuccess('Connected');
// //   } else {
// //     showError('Connection failed');
// //   }
// // }

//   // Future<void> disconnectFromPLC() async {
//   //   _stopContinuousReading();
//   //   plcService.disconnect();
//   //   setState(() => isConnected = false);
//   //   showSuccess('Disconnected');
//   // }

//   // void _startContinuousReading() {
//   //   _shouldKeepReading = true;
//   //   _readTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
//   //     if (!_shouldKeepReading || !isConnected) return t.cancel();
//   //     readAllValues();
//   //   });
//   // }

//   // void _stopContinuousReading() {
//   //   _shouldKeepReading = false;
//   //   _readTimer?.cancel();
//   // }

//   // Future<void> readAllValues() async {
//   //   if (!isConnected) return;
//   //   try {
//   //     final i  = plcService.read(TagType.int, intAddress)   as int;
//   //     final di = plcService.read(TagType.dint, dintAddress) as int;
//   //     final r  = plcService.read(TagType.real, realAddress) as double;
//   //     setState(() {
//   //       if (!intFocus.hasFocus)   intController.text  = i.toString();
//   //       if (!dintFocus.hasFocus)  dintController.text = di.toString();
//   //       if (!realFocus.hasFocus)  realController.text = r.toStringAsFixed(2);
//   //     });
//   //   } catch (e) {
//   //     showError('Read error: \$e');
//   //   }
//   // }

//   // ───────── WRITE METHODS ─────────
//   // void writeIntValue() {
//   //   try {
//   //     final val = int.parse(intController.text);
//   //     plcService.write(TagType.int, intAddress, val);
//   //     showSuccess('Wrote INT \$val');
//   //   } catch (e) {
//   //     showError('Write error: \$e');
//   //   }
//   // }

//   // void writeDintValue() {
//   //   try {
//   //     final val = int.parse(dintController.text);
//   //     plcService.write(TagType.dint, dintAddress, val);
//   //     showSuccess('Wrote DINT \$val');
//   //   } catch (e) {
//   //     showError('Write error: \$e');
//   //   }
//   // }

//   // void writeRealValue() {
//   //   try {
//   //     final val = double.parse(realController.text);
//   //     plcService.write(TagType.real, realAddress, val);
//   //     showSuccess('Wrote REAL \$val');
//   //   } catch (e) {
//   //     showError('Write error: \$e');
//   //   }
//   // }

//   // Future<void> toggleBoolValue() async {
//   //   if (!isConnected) return showError('Not connected');
//   //   try {
//   //     final current = plcService.read(TagType.bool, boolAddress) as bool;
//   //     final next = !current;
//   //     plcService.write(TagType.bool, boolAddress, next);
//   //     showSuccess('Toggled BOOL to \$next');
//   //   } catch (e) {
//   //     showError('Toggle error: \$e');
//   //   }
//   // }

//   // void showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
//   //   SnackBar(content: Text(msg), backgroundColor: Colors.red),
//   // );

//   // void showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
//   //   SnackBar(content: Text(msg), backgroundColor: Colors.green),
//   // );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PLC Demo'),
//         backgroundColor: isConnected ? Colors.green : Colors.red,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ElevatedButton(
//               onPressed:
//               isConnected ? disconnectFromPLC : connectToPLC,
//               child: Text(isConnected ? 'Disconnect' : 'Connect'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: intController,
//               focusNode: intFocus,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'INT Value'),
//               onSubmitted: (_) => writeIntValue(),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: dintController,
//               focusNode: dintFocus,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'DINT Value'),
//               onSubmitted: (_) => writeDintValue(),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: realController,
//               focusNode: realFocus,
//               keyboardType:
//               const TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(labelText: 'REAL Value'),
//               onSubmitted: (_) => writeRealValue(),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: toggleBoolValue,
//               child: const Text('Toggle BOOL'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
