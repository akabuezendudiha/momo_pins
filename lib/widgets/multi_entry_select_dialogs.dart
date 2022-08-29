import 'package:flutter/material.dart';
import 'package:momo_pins/dto/sim_card.dart';

import '../dto/vend_type.dart';

Future<SimCardData?> showSelectSimDialog(BuildContext context) async {
  // Get SIM data
  List<SimCardData> sims = <SimCardData>[
    SimCardData(0, 'SIM 01'),
    SimCardData(1, 'SIM 02'),
  ];
  var simCards = sims.map((sim) => SimpleDialogOption(
          onPressed: () => Navigator.pop(
                context,
                sim,
              ),
          child: Text(
            sim.displayName,
            style: const TextStyle(
              fontSize: 18,
            ),
          )))
      .toList();

  return await showDialog<SimCardData>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Select SIM Card'),
        children: simCards,
      );
    },
  );
}

Future<VendType?> showSelectVendTypeDialog(BuildContext context) async {
  List<SimpleDialogOption> dialogOptions = vendTypeTemplateList
      .map((vendType) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, vendType),
            child: Row(
              children: [
                const Icon(Icons.arrow_right),
                const SizedBox(width: 8.0),
                Text(
                  vendType.text,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ))
      .toList();

  return await showDialog<VendType>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Select Vend PIN Type'),
        children: dialogOptions,
      );
    },
  );
}

Future<int?> showSelectVendDisplayDialog(BuildContext context) async {
  List<SimpleDialogOption> dialogOptions = [
    {'text': '1 Second', 'duration': 1},
    {'text': '3 Seconds', 'duration': 3},
    {'text': '5 Seconds', 'duration': 5},
    {'text': '10 Seconds', 'duration': 10},
  ]
      .map((vendDelay) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, vendDelay['duration']),
            child: Text('${vendDelay['text']}'),
          ))
      .toList();

  return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Vend Delay Interval'),
          children: dialogOptions,
        );
      });
}

Future<int?> showSelectVendRetryDialog(BuildContext context) async {
  List<SimpleDialogOption> dialogOptions = [1, 3, 5]
      .map((retries) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, retries),
            child: Text('$retries times'),
          ))
      .toList();

  return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Vend Retry Count'),
          children: dialogOptions,
        );
      });
}
