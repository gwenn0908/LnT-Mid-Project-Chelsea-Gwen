import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(StepEntryAdapter());
  Hive.registerAdapter(WaterEntryAdapter());
  await Hive.openBox<StepEntry>('stepsBox').catchError((error) {
    print('Error membuka box: $error');
  });
  await Hive.openBox<WaterEntry>('waterBox').catchError((error) {
    print('Error membuka box: $error');
  });

  runApp(FitnessTrackerApp());
}

@HiveType(typeId: 0)
class StepEntry {
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final int steps;
  StepEntry({required this.date, required this.steps});
}

@HiveType(typeId: 1)
class WaterEntry {
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final double liters;
  WaterEntry({required this.date, required this.liters});
}

class FitnessTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fitness Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StepsScreen()),
                );
              },
              child: Text('Track Steps'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WaterScreen()),
                );
              },
              child: Text('Track Water Intake'),
            ),
          ],
        ),
      ),
    );
  }
}

class StepsScreen extends StatefulWidget {
  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final _stepsBox = Hive.box<StepEntry>('stepsBox');
  final TextEditingController _stepsController = TextEditingController();

  void _addSteps() {
    try {
      final steps = int.parse(_stepsController.text);
      if (steps > 0) {
        final entry = StepEntry(date: DateTime.now(), steps: steps);
        if (!_stepsBox.containsKey(entry.date.toString())) {
          _stepsBox.put(entry.date.toString(), entry);
          setState(() {});
        } else {
          print('Data sudah ada');
        }
      } else {
        print('Masukkan nilai yang valid');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Steps Tracker')),
      body: Column(
        children: [
          TextField(
            controller: _stepsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter Steps'),
          ),
          ElevatedButton(onPressed: _addSteps, child: Text('Add Steps')),
          Expanded(
            child: ListView.builder(
              itemCount: _stepsBox.length,
              itemBuilder: (context, index) {
                final entry = _stepsBox.getAt(index) as StepEntry;
                return ListTile(
                  title: Text('Steps: ${entry.steps}'),
                  subtitle: Text('Date: ${entry.date.toLocal()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WaterScreen extends StatefulWidget {
  @override
  _WaterScreenState createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final _waterBox = Hive.box<WaterEntry>('waterBox');
  final TextEditingController _waterController = TextEditingController();

  void _addWater() {
    try {
      final liters = double.parse(_waterController.text);
      if (liters > 0) {
        final entry = WaterEntry(date: DateTime.now(), liters: liters);
        if (!_waterBox.containsKey(entry.date.toString())) {
          _waterBox.put(entry.date.toString(), entry);
          setState(() {});
        } else {
          print('Data sudah ada');
        }
      } else {
        print('Masukkan nilai yang valid');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Water Intake Tracker')),
      body: Column(
        children: [
          TextField(
            controller: _waterController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter Water Intake (L)'),
          ),
          ElevatedButton(onPressed: _addWater, child: Text('Add Water Intake')),
          Expanded(
            child: ListView.builder(
              itemCount: _waterBox.length,
              itemBuilder: (context, index) {
                final entry = _waterBox.getAt(index) as WaterEntry;
                return ListTile(
                  title: Text('Water: ${entry.liters} L'),
                  subtitle: Text('Date: ${entry.date.toLocal()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}