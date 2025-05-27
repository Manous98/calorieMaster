import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Calculateur Calorie',
        onColorChange: (Color newColor) {},
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onColorChange,
  });

  final String title;
  final Function(Color) onColorChange;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _weightController = TextEditingController();
  double? _weight;

  String? _activityLevel;
  bool _isMale = true;
  Color _appBarColor = Colors.blue;
  double _sliderValue = 50;
  DateTime? _selectedDate;
  int? _calculatedAge;
  double? _calculatedCalories;

  void _showCaloriesPopup(BuildContext context, double calories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Résultat')), // Centrage du titre
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ajuste la taille de l’AlertDialog
            children: [
              const Text(
                'Votre besoin journalier est de :',
                style: TextStyle(fontWeight: FontWeight.bold), // Texte en gras
              ),
              Text(
                '${calories.toStringAsFixed(0)} calories',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              // Centrage du bouton
              child: TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _calculateCalories() {
    // Vérification des champs requis
    if (_calculatedAge == null ||
        _weight == null ||
        _sliderValue == 0 ||
        _activityLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // 1. Calcul du BMR
    double bmr;
    if (_isMale) {
      bmr =
          66.5 +
          (13.75 * _weight!) +
          (5.003 * _sliderValue) -
          (6.75 * _calculatedAge!);
    } else {
      bmr =
          655 +
          (9.563 * _weight!) +
          (1.850 * _sliderValue) -
          (4.676 * _calculatedAge!);
    }

    // 2. Appliquer le facteur selon activité
    double activityFactor;
    switch (_activityLevel) {
      case 'Faible':
        activityFactor = 1.2;
        break;
      case 'Modéré':
        activityFactor = 1.55;
        break;
      case 'Forte':
        activityFactor = 1.725;
        break;
      default:
        activityFactor = 1.2; // Valeur par défaut
    }

    // 3. Calcul final
    setState(() {
      _calculatedCalories = bmr * activityFactor;
    });
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _calculatedAge = _calculateAge(picked);
      });
    }
  }

  void _toggleGender(bool isMale) {
    setState(() {
      _isMale = isMale;
      _appBarColor = _isMale ? Colors.blue : Colors.pink;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _appBarColor,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Remplissez tous les champs pour obtenir votre besoin journalier en calorie",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Homme", style: const TextStyle(color: Colors.blue)),
                      const SizedBox(width: 60),
                      Switch(
                        value: _isMale,
                        onChanged: (bool newValue) {
                          _toggleGender(newValue);
                        },
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.pink,
                      ),
                      const SizedBox(width: 60),
                      Text("Femme", style: const TextStyle(color: Colors.pink)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            backgroundColor: _appBarColor,
                          ),
                          onPressed: _pickDate,
                          child: Text(
                            _calculatedAge == null
                                ? "Choisir une date de naissance"
                                : "Votre âge est de $_calculatedAge ans",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Votre taille est de : ${_sliderValue.toStringAsFixed(0)} cm",
                            style: TextStyle(fontSize: 16, color: _appBarColor),
                          ),
                          Slider(
                            value: _sliderValue,
                            min: 0,
                            max: 300,
                            divisions: 100,
                            label: _sliderValue.toStringAsFixed(0),
                            activeColor: _appBarColor,
                            inactiveColor: _appBarColor,
                            onChanged: (double newValue) {
                              setState(() {
                                _sliderValue = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quel est votre poids (en kg) ?",
                          style: TextStyle(fontSize: 16),
                        ),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Entrez votre poids",
                            border: OutlineInputBorder(),
                            suffixText: "kg",
                          ),
                          onChanged: (value) {
                            setState(() {
                              _weight = double.tryParse(value);
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Quelle est votre activité sportive?",
                          style: TextStyle(fontSize: 16, color: _appBarColor),
                        ),
                        ListTile(
                          title: Text(
                            "Faible",
                            style: TextStyle(color: _appBarColor),
                          ),
                          leading: Radio<String>(
                            value: 'Faible',
                            groupValue: _activityLevel,
                            onChanged: (String? value) {
                              setState(() {
                                _activityLevel = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Modéré",
                            style: TextStyle(color: _appBarColor),
                          ),
                          leading: Radio<String>(
                            value: 'Modéré',
                            groupValue: _activityLevel,
                            onChanged: (String? value) {
                              setState(() {
                                _activityLevel = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Forte",
                            style: TextStyle(color: _appBarColor),
                          ),
                          leading: Radio<String>(
                            value: 'Forte',
                            groupValue: _activityLevel,
                            onChanged: (String? value) {
                              setState(() {
                                _activityLevel = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  _calculateCalories();
                  if (_calculatedCalories != null) {
                    _showCaloriesPopup(context, _calculatedCalories!);
                  } else {
                    // Facultatif : si aucune valeur, afficher un autre message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Veuillez d'abord remplir tous les champs",
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _appBarColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  "Calculer",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
