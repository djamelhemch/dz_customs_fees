import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) => MaterialApp(
          title: 'Algerian Customs fees Calculator',
          home: const CustomsCalculator(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('fr', ''), // French
            Locale('ar', ''), // Arabic
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
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

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Algerian Customs fees Calculator',
      'enterGoodsValue': 'Enter Goods Value',
      'calculate': 'Calculate',
      "currency": "Currency",
      'customsDuty': 'Customs Duty',
      'vat': 'VAT',
      'totalFees': 'Total Fees',
      'error': 'Please enter a valid number',
      "failedToLoadExchangeRate": "Failed to load exchange rate",
      "moreInfo": "For more info about customs fees, click here",
      "RateTo" : "Rate to DZD",
      "CurrentRate" : "Current Exchange Rates To Algerian Dinar :",
      "Selectcurrency": "Select currency"
    },
    'fr': {
      'title': 'Calculateur de frais Douanes DZ',
      'enterGoodsValue': 'Entrez la Valeur des Marchandises',
      'calculate': 'Calculer',
      "currency": "Devise",
      'customsDuty': 'Droits de Douane',
      'vat': 'T.V.A',
      'totalFees': 'Frais Totals',
      'error': 'Veuillez entrer un nombre valide',
      "failedToLoadExchangeRate": "Échec du chargement du taux de change",
      "moreInfo": "Pour plus d'informations sur les frais de douane, cliquez ici",
      "RateTo" : "Taux en DZD",
      "CurrentRate" : "Taux de change actuels en dinar algérien :",
      "Selectcurrency": "Sélectionnez la devise"
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
      "failedToLoadExchangeRate": "فشل تحميل سعر الصرف",
      "moreInfo": "لمزيد من المعلومات حول الرسوم الجمركية، انقر هنا",
      "RateTo" : "السعر د.ج ",
      "CurrentRate" : "أسعار الصرف الحالية إلى الدينار الجزائري :",
      "Selectcurrency": "اختر العملة"
      // Add more locales as needed
    }
  };

  String translate(String key) => _localizedValues[_locale]![key]!;
}

class CustomsCalculator extends StatefulWidget {
  const CustomsCalculator({super.key});

  @override
  _CustomsCalculatorState createState() => _CustomsCalculatorState();
}

class _CustomsCalculatorState extends State<CustomsCalculator> {
  final TextEditingController _goodsValueController = TextEditingController();
  double _customsDuty = 0.0, _vat = 0.0, _totalFees = 0.0;
  final String _currency = 'USD';
  String? _errorText;
  String? _exchangeRateError;
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

  Future<void> _launchCustomsWebsite() async {
    // Convert the URL string to a Uri object
    final Uri url = Uri.parse('https://www.douane.gov.dz/spip.php?article215');

    try {
      // Attempt to launch the URL
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // If false is returned, handle it as a failure to launch the URL
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      // Catch and print any exceptions that occur during the launch
      debugPrint('Error launching URL: $e');
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
  Map<String, double> _exchangeRates = {}; // Holds the exchange rates
  String _selectedCurrency = 'USD';  // Default currency
// Fetches exchange rates for USD, EUR, and GBP and updates the state
  Future<void> fetchAllExchangeRates() async {
    List<String> currencies = ['USD', 'EUR', 'GBP']; // List of currencies to fetch
    Map<String, double> newRates = {};

    try {
      for (String currency in currencies) {
        double rate = await fetchExchangeRate(currency); // Use your existing method
        newRates[currency] = rate;
      }
      setState(() {
        _exchangeRates = newRates;
        _exchangeRateError = null;  // Clear any previous errors if successful
      });
    } catch (e) {

      setState(() {
        _exchangeRates.clear();  // Clear any existing rates
        _exchangeRateError = 'Failed to load exchange rates'; // Set an appropriate error message
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllExchangeRates(); // Fetch exchange rates when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    var localizations = Provider.of<LocaleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('title'),

            style:  TextStyle(
                color: AppColors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',

            )
        ),
        backgroundColor: AppColors.darkBlue,
        centerTitle: true,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),

                  child: Text(
                    "${localizations.translate('Selectcurrency')}: ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 150,  // Maximum width for the dropdown
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCurrency,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCurrency = newValue!;
                      });
                    },
                    items: ['USD', 'EUR', 'GBP'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: <Widget>[
                            Image.asset('lib/assets/images/$value.png', width: 24, height: 24),
                            const SizedBox(width: 10),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading) ElevatedButton(
              onPressed: calculateCustomsFees,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepBlue),
              child: Text(localizations.translate('calculate'),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorText == null) ...[
              Text(
                localizations.locale == 'ar' ?
                '${localizations.translate('customsDuty')}: ${_customsDuty.toStringAsFixed(2)} دج' :
                '${localizations.translate('customsDuty')}: ${_customsDuty.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              Text(
                localizations.locale == 'ar' ?
                '${localizations.translate('vat')}: ${_vat.toStringAsFixed(2)} دج' :
                '${localizations.translate('vat')}: ${_vat.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              Text(
                localizations.locale == 'ar' ?
                '${localizations.translate('totalFees')}: ${_totalFees.toStringAsFixed(2)} دج' :
                '${localizations.translate('totalFees')}: ${_totalFees.toStringAsFixed(2)} DZD',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (_exchangeRates.isNotEmpty) ...[
                    Text(
                      localizations.translate('CurrentRate'),
                      style: const TextStyle(
                        fontSize: 16, // Increasing the font size
                        fontWeight: FontWeight.bold, // Making the text bold
                        color: Colors.blue, // Changing the text color to blue

                        decoration: TextDecoration.underline, // Underlining the text
                        decorationColor: Colors.blue, // Color of the underline
                        decorationStyle: TextDecorationStyle.solid, // Style of the underline
                      ),
                    )
                    ,
                    DataTable(
                      columns: <DataColumn>[
                        DataColumn(label: Text(localizations.translate('currency'))),
                        DataColumn(label: Text(localizations.translate('RateTo'))),
                      ],
                      rows: _exchangeRates.entries.map((entry) => DataRow(
                        cells: [
                          DataCell(Row(children: [
                            Image.asset('lib/assets/images/${entry.key}.png', width: 20),
                            Text("  1 ${entry.key}"),
                          ])),
                          DataCell(Row(children: [
                            Image.asset('lib/assets/images/DZD.png', width: 20),
                            Text(
                                '${entry.value.toStringAsFixed(2)} DZD',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold
                              ),

                            ),
                          ])),
                        ],
                      )).toList(),
                    ),
                  ] else if (_exchangeRateError != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _exchangeRateError!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )
                  ],
                ],
              )
            ],
            Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Aligns children to the center of the main axis
                  children: <Widget>[
                    DropdownButton<String>(
                      value: localizations.locale,
                      onChanged: (String? newValue) {
                        Provider.of<LocaleProvider>(context, listen: false).setLocale(newValue!);
                      },
                      items: ['en', 'fr', 'ar'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()), // Optional: Adjust the font size
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20), // Provides spacing between the dropdown and the link
                    GestureDetector(
                      onTap: _launchCustomsWebsite,
                      child: Text(
                        localizations.translate('moreInfo'),
                        style: const TextStyle(
                          fontSize: 14, // Smaller font size
                          color: Colors.blue, // Color to mimic a hyperlink
                          decoration: TextDecoration.underline, // Underline to mimic a hyperlink
                        ),
                      ),
                    )
                  ],
                )
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        width: double.infinity,
        color: Colors.blueGrey[50],  // Optional: for better visibility
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        alignment: Alignment.center,
        child: Text(
          'Copyright © 2024 Djamel Hemch',  // Update the year and your name accordingly
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }



}