import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) => MaterialApp(
          title: 'DZ Customs Calculator',
          home: CustomsCalculator(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
        ),
      ),
    );
  }
}

class LocaleProvider with ChangeNotifier {
  String _locale = 'en';
  String get locale => _locale;

  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
  }

  Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Algerian Customs Calculator',
      'enterGoodsValue': 'Enter Goods Value',
      'calculate': 'Calculate',
      "currency": "Currency",
      'customsDuty': 'Customs Duty',
      'vat': 'VAT',
      'totalFees': 'Total Fees',
      'error': 'Please enter a valid number',
      "failedToLoadExchangeRate": "Failed to load exchange rate"
    },
    'fr': {
      'title': 'Calculateur de Douanes DZ',
      'enterGoodsValue': 'Entrez la Valeur des Marchandises',
      'calculate': 'Calculer',
      "currency": "Devise",
      'customsDuty': 'Droits de Douane',
      'vat': 'T.V.A',
      'totalFees': 'Frais Totals',
      'error': 'Veuillez entrer un nombre valide',
      "failedToLoadExchangeRate": "Échec du chargement du taux de change"
    },
    'ar': {
      "title": "حاسبة الجمارك الجزائرية",
      "enterGoodsValue": "أدخل قيمة البضائع",
      "calculate": "احسب",
      "currency": "العملة",
      "customsDuty": "الرسوم الجمركية",
      "vat": "ضريبة القيمة المضافة",
      "totalFees": "الرسوم الكلية",
      "error": "حدث خطأ",
      "failedToLoadExchangeRate": "فشل تحميل سعر الصرف"
      // Add more locales as needed
    }
  };

  String translate(String key) => _localizedValues[_locale]![key]!;
}

class CustomsCalculator extends StatefulWidget {
  @override
  _CustomsCalculatorState createState() => _CustomsCalculatorState();
}

class _CustomsCalculatorState extends State<CustomsCalculator> {
  final TextEditingController _goodsValueController = TextEditingController();
  double _customsDuty = 0.0, _vat = 0.0, _totalFees = 0.0;
  String _currency = 'USD';
  String? _errorText;
  bool _isLoading = false;

  Future<void> calculateCustomsFees() async {
    String input = _goodsValueController.text;
    if (input.isEmpty || double.tryParse(input) == null) {
      setState(() {
        _errorText = Provider.of<LocaleProvider>(context, listen: false).translate('error');
      });
      return;
    }
    double value = double.parse(input);
    setState(() => _isLoading = true);

    try {
      double exchangeRate = await fetchExchangeRate(_currency);
      double goodsValueDZD = value * exchangeRate;
      setState(() {
        _customsDuty = goodsValueDZD * 0.30;
        _vat = (goodsValueDZD + _customsDuty) * 0.19;
        _totalFees = _customsDuty + _vat;
        _errorText = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Failed to fetch exchange rate';
        _isLoading = false;
      });
    }
  }

  Future<double> fetchExchangeRate(String currency) async {
    var url = Uri.parse('https://v6.exchangerate-api.com/v6/80787f5bde4917f516075748/latest/$currency');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['conversion_rates']['DZD'];
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = Provider.of<LocaleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('title')),
        backgroundColor: AppColors.deepBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _goodsValueController,
              decoration: InputDecoration(
                labelText: localizations.translate('enterGoodsValue'),
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _currency,
              onChanged: (String? newValue) {
                setState(() => _currency = newValue!);
              },
              items: <String>['USD', 'EUR', 'GBP'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: <Widget>[
                        Image.asset('lib/assets/images/$value.png', width: 24, height: 24), // Placeholder icon, replace with your own
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading) ElevatedButton(
              onPressed: calculateCustomsFees,
              child: Text(localizations.translate('calculate'),
                style: const TextStyle(color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(primary: AppColors.purple),
            ),
            const SizedBox(height: 20),
            if (_errorText == null) ...[
              Text(
                '${localizations.translate('customsDuty')}: ${_customsDuty.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 20, // Specific larger font size for these texts
                  fontWeight: FontWeight.bold, // Making the text bold to emphasize
                  color: Colors.black, // Specifying color, adjust if you have a theme color
                ),
              ),

              Text(
                '${localizations.translate('vat')}: ${_vat.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 20, // Consistent font size for similar texts
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              Text(
                '${localizations.translate('totalFees')}: ${_totalFees.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

            ],
          Padding(
          padding: const EdgeInsets.only(top: 375),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: localizations.locale,
                  onChanged: (String? newValue) {
                    Provider.of<LocaleProvider>(context, listen: false).setLocale(newValue!);
                  },
                  items: ['en', 'fr', 'ar'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () => _launchCustomsWebsite(),
                  style: ElevatedButton.styleFrom(primary: AppColors.darkBlue),
                  child: const Text('For info about customs fees, click here'),

                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _launchCustomsWebsite() async {
    const url = 'https://www.douane.gov.dz/spip.php?article215&lang=fr#collapse4';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}