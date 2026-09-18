import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  // ---------------------------------------------------------------------
  // CONVERSION MODEL
  // Each unit stores a factor relative to one base unit for its category.
  //   valueInBase = value * factor[fromUnit]
  //   result      = valueInBase / factor[toUnit]
  // Temperature has an offset, not just a scale, so it pivots through
  // Celsius using its own formulas instead of the factor map.
  // ---------------------------------------------------------------------

  static const Map<String, Map<String, double>> _factors = {
    "Speed": {
      "Meter/sec": 1.0,
      "Kilometer/hr": 0.277778,
      "Mile/hr": 0.44704,
      "Knot": 0.514444,
    },
    "Volume": {
      "Milliliter": 0.001,
      "Liter": 1.0,
      "Cup": 0.24,
      "Fluid Ounce": 0.0295735,
      "Gallon": 3.78541,
    },
  };

  static double _toCelsius(String unit, double value) {
    switch (unit) {
      case "Celsius":
        return value;
      case "Fahrenheit":
        return (value - 32) * 5 / 9;
      case "Kelvin":
        return value - 273.15;
    }
    return value;
  }

  static double _fromCelsius(String unit, double celsius) {
    switch (unit) {
      case "Celsius":
        return celsius;
      case "Fahrenheit":
        return celsius * 9 / 5 + 32;
      case "Kelvin":
        return celsius + 273.15;
    }
    return celsius;
  }

  static const List<String> _categories = ["Temperature", "Speed", "Volume"];

  static const Map<String, String> _categoryIcons = {
    "Temperature": "🌡️",
    "Speed": "🚀",
    "Volume": "🧪",
  };

  static const List<String> _temperatureUnits = [
    "Celsius",
    "Fahrenheit",
    "Kelvin",
  ];

  String category = "Temperature";
  String fromUnit = "Celsius";
  String toUnit = "Fahrenheit";
  double result = 0;

  // Palette matching the dark, gradient reference design
  static const Color bgTop = Color(0xFF160B2E);
  static const Color bgBottom = Color(0xFF120A24);
  static const Color panel = Color(0xFF1E1338);
  static const Color panelBorder = Color(0xFF34264F);
  static const Color labelMuted = Color(0xFF9C8FB8);
  static const Color fieldText = Colors.white;
  static const Color accentStart = Color(0xFFFF7A45);
  static const Color accentEnd = Color(0xFFFF3D7F);

  List<String> getUnits() {
    if (category == "Temperature") return _temperatureUnits;
    return _factors[category]!.keys.toList();
  }

  void convert() {
    final double value = double.tryParse(controller.text) ?? 0;

    if (category == "Temperature") {
      final double celsius = _toCelsius(fromUnit, value);
      result = _fromCelsius(toUnit, celsius);
    } else {
      final Map<String, double> units = _factors[category]!;
      final double valueInBase = value * units[fromUnit]!;
      result = valueInBase / units[toUnit]!;
    }

    setState(() {});
  }

  void reset() {
    setState(() {
      controller.clear();
      category = "Temperature";
      fromUnit = "Celsius";
      toUnit = "Fahrenheit";
      result = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: title + reset icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Unit Converter",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: reset,
                      icon: const Icon(Icons.refresh, color: accentStart),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Gradient swap icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accentStart, accentEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Main input card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: panelBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      _fieldLabel("Category"),
                      const SizedBox(height: 6),
                      _darkDropdown<String>(
                        value: category,
                        items: _categories.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              "${_categoryIcons[c]}  $c",
                              style: const TextStyle(
                                fontSize: 18,
                                color: fieldText,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            category = value!;
                            final units = getUnits();
                            fromUnit = units[0];
                            toUnit = units.length > 1 ? units[1] : units[0];
                            result = 0;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      // Enter value
                      _fieldLabel("Enter Value"),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: panelBorder),
                        ),
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: fieldText,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: "e.g. 90",
                            hintStyle: TextStyle(
                              color: labelMuted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // From / swap / To
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("From"),
                                const SizedBox(height: 6),
                                _darkDropdown<String>(
                                  value: fromUnit,
                                  items: getUnits().map((u) {
                                    return DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        u,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: fieldText,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => fromUnit = value!);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  final temp = fromUnit;
                                  fromUnit = toUnit;
                                  toUnit = temp;
                                });
                              },
                              icon: const Icon(
                                Icons.swap_horiz_rounded,
                                color: accentStart,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel("To"),
                                const SizedBox(height: 6),
                                _darkDropdown<String>(
                                  value: toUnit,
                                  items: getUnits().map((u) {
                                    return DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        u,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: fieldText,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => toUnit = value!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Convert button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [accentEnd, accentStart],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: convert,
                              child: const Center(
                                child: Text(
                                  "Convert",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Result card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [accentStart, accentEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${_categoryIcons[category]}  Result",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result.toStringAsFixed(4),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toUnit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: labelMuted),
    );
  }

  Widget _darkDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: panelBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: panel,
          iconEnabledColor: labelMuted,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
