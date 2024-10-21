import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Currencis extends StatefulWidget {
  const Currencis({super.key});

  @override
  State<Currencis> createState() => _CurrencisState();
  
}


class _CurrencisState extends State<Currencis> {
  Future<void> _loadUserCurrency() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Vendors')
            .doc(userId)
            .get();

        if (doc.exists) {
          String location = doc.data()?['location'] ?? '';
          final currency =
              _getCurrencyForCountry(_extractCountryCode(location));
          String selectedCurrency;
          setState(() => selectedCurrency = currency);
        }
      }
    } catch (e) {
      print('Error loading user currency: $e');
    }
  }

  String _extractCountryCode(String location) {
  // Match any two-letter country flag emoji and capture the letters
  final pattern = RegExp(r'(?:[\u{1F1E6}-\u{1F1FF}]{2})');
  final match = pattern.firstMatch(location);
  
  if (match != null) {
    // Extract the two letters from the flag emoji and convert to country code
    final flagEmoji = match.group(0)!;
    final countryCode = String.fromCharCodes(
      flagEmoji.runes.map((rune) => rune - 0x1F1E6 + 0x41)
    );
    return countryCode;
  }
  
  return 'GB'; // Default fallback
}

  String _getCurrencyForCountry(String countryCode) {
  final currencyMap = {
    'AF': 'AFN', // Afghanistan - Afghan Afghani
    'AL': 'ALL', // Albania - Albanian Lek
    'DZ': 'DZD', // Algeria - Algerian Dinar
    'AD': 'EUR', // Andorra - Euro
    'AO': 'AOA', // Angola - Angolan Kwanza
    'AG': 'XCD', // Antigua and Barbuda - East Caribbean Dollar
    'AR': 'ARS', // Argentina - Argentine Peso
    'AM': 'AMD', // Armenia - Armenian Dram
    'AU': 'AUD', // Australia - Australian Dollar
    'AT': 'EUR', // Austria - Euro
    'AZ': 'AZN', // Azerbaijan - Azerbaijani Manat
    'BS': 'BSD', // Bahamas - Bahamian Dollar
    'BH': 'BHD', // Bahrain - Bahraini Dinar
    'BD': 'BDT', // Bangladesh - Bangladeshi Taka
    'BB': 'BBD', // Barbados - Barbadian Dollar
    'BY': 'BYN', // Belarus - Belarusian Ruble
    'BE': 'EUR', // Belgium - Euro
    'BZ': 'BZD', // Belize - Belize Dollar
    'BJ': 'XOF', // Benin - West African CFA Franc
    'BT': 'BTN', // Bhutan - Bhutanese Ngultrum
    'BO': 'BOB', // Bolivia - Bolivian Boliviano
    'BA': 'BAM', // Bosnia and Herzegovina - Bosnia-Herzegovina Convertible Mark
    'BW': 'BWP', // Botswana - Botswanan Pula
    'BR': 'BRL', // Brazil - Brazilian Real
    'BN': 'BND', // Brunei - Brunei Dollar
    'BG': 'BGN', // Bulgaria - Bulgarian Lev
    'BF': 'XOF', // Burkina Faso - West African CFA Franc
    'BI': 'BIF', // Burundi - Burundian Franc
    'KH': 'KHR', // Cambodia - Cambodian Riel
    'CM': 'XAF', // Cameroon - Central African CFA Franc
    'CA': 'CAD', // Canada - Canadian Dollar
    'CV': 'CVE', // Cape Verde - Cape Verdean Escudo
    'CF': 'XAF', // Central African Republic - Central African CFA Franc
    'TD': 'XAF', // Chad - Central African CFA Franc
    'CL': 'CLP', // Chile - Chilean Peso
    'CN': 'CNY', // China - Chinese Yuan
    'CO': 'COP', // Colombia - Colombian Peso
    'KM': 'KMF', // Comoros - Comorian Franc
    'CG': 'XAF', // Congo Republic - Central African CFA Franc
    'CD': 'CDF', // DR Congo - Congolese Franc
    'CR': 'CRC', // Costa Rica - Costa Rican Colón
    'CI': 'XOF', // Côte d'Ivoire - West African CFA Franc
    'HR': 'HRK', // Croatia - Croatian Kuna
    'CU': 'CUP', // Cuba - Cuban Peso
    'CY': 'EUR', // Cyprus - Euro
    'CZ': 'CZK', // Czech Republic - Czech Koruna
    'DK': 'DKK', // Denmark - Danish Krone
    'DJ': 'DJF', // Djibouti - Djiboutian Franc
    'DM': 'XCD', // Dominica - East Caribbean Dollar
    'DO': 'DOP', // Dominican Republic - Dominican Peso
    'EC': 'USD', // Ecuador - US Dollar
    'EG': 'EGP', // Egypt - Egyptian Pound
    'SV': 'USD', // El Salvador - US Dollar
    'GQ': 'XAF', // Equatorial Guinea - Central African CFA Franc
    'ER': 'ERN', // Eritrea - Eritrean Nakfa
    'EE': 'EUR', // Estonia - Euro
    'ET': 'ETB', // Ethiopia - Ethiopian Birr
    'FJ': 'FJD', // Fiji - Fijian Dollar
    'FI': 'EUR', // Finland - Euro
    'FR': 'EUR', // France - Euro
    'GA': 'XAF', // Gabon - Central African CFA Franc
    'GM': 'GMD', // Gambia - Gambian Dalasi
    'GE': 'GEL', // Georgia - Georgian Lari
    'DE': 'EUR', // Germany - Euro
    'GH': 'GHS', // Ghana - Ghanaian Cedi
    'GR': 'EUR', // Greece - Euro
    'GD': 'XCD', // Grenada - East Caribbean Dollar
    'GT': 'GTQ', // Guatemala - Guatemalan Quetzal
    'GN': 'GNF', // Guinea - Guinean Franc
    'GW': 'XOF', // Guinea-Bissau - West African CFA Franc
    'GY': 'GYD', // Guyana - Guyanese Dollar
    'HT': 'HTG', // Haiti - Haitian Gourde
    'HN': 'HNL', // Honduras - Honduran Lempira
    'HK': 'HKD', // Hong Kong - Hong Kong Dollar
    'HU': 'HUF', // Hungary - Hungarian Forint
    'IS': 'ISK', // Iceland - Icelandic Króna
    'IN': 'INR', // India - Indian Rupee
    'ID': 'IDR', // Indonesia - Indonesian Rupiah
    'IR': 'IRR', // Iran - Iranian Rial
    'IQ': 'IQD', // Iraq - Iraqi Dinar
    'IE': 'EUR', // Ireland - Euro
    'IL': 'ILS', // Israel - Israeli New Shekel
    'IT': 'EUR', // Italy - Euro
    'JM': 'JMD', // Jamaica - Jamaican Dollar
    'JP': 'JPY', // Japan - Japanese Yen
    'JO': 'JOD', // Jordan - Jordanian Dinar
    'KZ': 'KZT', // Kazakhstan - Kazakhstani Tenge
    'KE': 'KES', // Kenya - Kenyan Shilling
    'KI': 'AUD', // Kiribati - Australian Dollar
    'KP': 'KPW', // North Korea - North Korean Won
    'KR': 'KRW', // South Korea - South Korean Won
    'KW': 'KWD', // Kuwait - Kuwaiti Dinar
    'KG': 'KGS', // Kyrgyzstan - Kyrgystani Som
    'LA': 'LAK', // Laos - Lao Kip
    'LV': 'EUR', // Latvia - Euro
    'LB': 'LBP', // Lebanon - Lebanese Pound
    'LS': 'LSL', // Lesotho - Lesotho Loti
    'LR': 'LRD', // Liberia - Liberian Dollar
    'LY': 'LYD', // Libya - Libyan Dinar
    'LI': 'CHF', // Liechtenstein - Swiss Franc
    'LT': 'EUR', // Lithuania - Euro
    'LU': 'EUR', // Luxembourg - Euro
    'MO': 'MOP', // Macau - Macanese Pataca
    'MG': 'MGA', // Madagascar - Malagasy Ariary
    'MW': 'MWK', // Malawi - Malawian Kwacha
    'MY': 'MYR', // Malaysia - Malaysian Ringgit
    'MV': 'MVR', // Maldives - Maldivian Rufiyaa
    'ML': 'XOF', // Mali - West African CFA Franc
    'MT': 'EUR', // Malta - Euro
    'MH': 'USD', // Marshall Islands - US Dollar
    'MR': 'MRU', // Mauritania - Mauritanian Ouguiya
    'MU': 'MUR', // Mauritius - Mauritian Rupee
    'MX': 'MXN', // Mexico - Mexican Peso
    'FM': 'USD', // Micronesia - US Dollar
    'MD': 'MDL', // Moldova - Moldovan Leu
    'MC': 'EUR', // Monaco - Euro
    'MN': 'MNT', // Mongolia - Mongolian Tögrög
    'ME': 'EUR', // Montenegro - Euro
    'MA': 'MAD', // Morocco - Moroccan Dirham
    'MZ': 'MZN', // Mozambique - Mozambican Metical
    'MM': 'MMK', // Myanmar - Myanmar Kyat
    'NA': 'NAD', // Namibia - Namibian Dollar
    'NR': 'AUD', // Nauru - Australian Dollar
    'NP': 'NPR', // Nepal - Nepalese Rupee
    'NL': 'EUR', // Netherlands - Euro
    'NZ': 'NZD', // New Zealand - New Zealand Dollar
    'NI': 'NIO', // Nicaragua - Nicaraguan Córdoba
    'NE': 'XOF', // Niger - West African CFA Franc
    'NG': 'NGN', // Nigeria - Nigerian Naira
    'NO': 'NOK', // Norway - Norwegian Krone
    'OM': 'OMR', // Oman - Omani Rial
    'PK': 'PKR', // Pakistan - Pakistani Rupee
    'PW': 'USD', // Palau - US Dollar
    'PA': 'PAB', // Panama - Panamanian Balboa
    'PG': 'PGK', // Papua New Guinea - Papua New Guinean Kina
    'PY': 'PYG', // Paraguay - Paraguayan Guaraní
    'PE': 'PEN', // Peru - Peruvian Sol
    'PH': 'PHP', // Philippines - Philippine Peso
    'PL': 'PLN', // Poland - Polish Złoty
    'PT': 'EUR', // Portugal - Euro
    'QA': 'QAR', // Qatar - Qatari Riyal
    'RO': 'RON', // Romania - Romanian Leu
    'RU': 'RUB', // Russia - Russian Ruble
    'RW': 'RWF', // Rwanda - Rwandan Franc
    'KN': 'XCD', // Saint Kitts and Nevis - East Caribbean Dollar
    'LC': 'XCD', // Saint Lucia - East Caribbean Dollar
    'VC': 'XCD', // Saint Vincent and the Grenadines - East Caribbean Dollar
    'WS': 'WST', // Samoa - Samoan Tālā
    'SM': 'EUR', // San Marino - Euro
    'ST': 'STN', // São Tomé and Príncipe - São Tomé and Príncipe Dobra
    'SA': 'SAR', // Saudi Arabia - Saudi Riyal
    'SN': 'XOF', // Senegal - West African CFA Franc
    'RS': 'RSD', // Serbia - Serbian Dinar
    'SC': 'SCR', // Seychelles - Seychellois Rupee
    'SL': 'SLL', // Sierra Leone - Sierra Leonean Leone
    'SG': 'SGD', // Singapore - Singapore Dollar
    'SK': 'EUR', // Slovakia - Euro
    'SI': 'EUR', // Slovenia - Euro
    'SB': 'SBD', // Solomon Islands - Solomon Islands Dollar
    'SO': 'SOS', // Somalia - Somali Shilling
    'ZA': 'ZAR', // South Africa - South African Rand
    'SS': 'SSP', // South Sudan - South Sudanese Pound
    'ES': 'EUR', // Spain - Euro
    'LK': 'LKR', // Sri Lanka - Sri Lankan Rupee
    'SD': 'SDG', // Sudan - Sudanese Pound
    'SR': 'SRD', // Suriname - Surinamese Dollar
    'SZ': 'SZL', // Eswatini - Swazi Lilangeni
    'SE': 'SEK', // Sweden - Swedish Krona
    'CH': 'CHF', // Switzerland - Swiss Franc
    'SY': 'SYP', // Syria - Syrian Pound
    'TW': 'TWD', // Taiwan - New Taiwan Dollar
    'TJ': 'TJS', // Tajikistan - Tajikistani Somoni
    'TZ': 'TZS', // Tanzania - Tanzanian Shilling
    'TH': 'THB', // Thailand - Thai Baht
    'TL': 'USD', // East Timor - US Dollar
    'TG': 'XOF', // Togo - West African CFA Franc
    'TO': 'TOP', // Tonga - Tongan Paʻanga
    'TT': 'TTD', // Trinidad and Tobago - Trinidad and Tobago Dollar
    'TN': 'TND', // Tunisia - Tunisian Dinar
    'TR': 'TRY', // Turkey - Turkish Lira
    'TM': 'TMT', // Turkmenistan - Turkmenistan Manat
    'TV': 'AUD', // Tuvalu - Australian Dollar
    'UG': 'UGX', // Uganda - Ugandan Shilling
    'UA': 'UAH', // Ukraine - Ukrainian Hryvnia
    'AE': 'AED', // United Arab Emirates - UAE Dirham
    'GB': 'GBP', // United Kingdom - British Pound
    'US': 'USD', // United States - US Dollar
    'UY': 'UYU', // Uruguay - Uruguayan Peso
    'UZ': 'UZS', // Uzbekistan - Uzbekistani Som
    'VU': 'VUV', // Vanuatu - Vanuatu Vatu
    'VA': 'EUR', // Vatican City - Euro
    'VE': 'VES', // Venezuela - Venezuelan Bolívar
    'VN': 'VND', // Vietnam - Vietnamese Đồng
    'YE': 'YER', // Yemen - Yemeni Rial
    'ZM': 'ZMW', // Zambia - Zambian Kwacha
    'ZW': 'ZWL', // Zimbabwe - Zimbabwean Dollar
    
    // Special territories and dependencies
    'EU': 'EUR', // European Union - Euro
    'AX': 'EUR', // Åland Islands - Euro
    'AS': 'USD', // American Samoa - US Dollar
    'AW': 'AWG', // Aruba - Aruban Florin
    'BM': 'BMD', // Bermuda - Bermudian Dollar
    'BV': 'NOK', // Bouvet Island - Norwegian Krone
    'IO': 'USD', // British Indian Ocean Territory - US Dollar
    'KY': 'KYD', // Cayman Islands - Cayman Islands Dollar
    'CX': 'AUD', // Christmas Island - Australian Dollar
    'CC': 'AUD', // Cocos Islands - Australian Dollar
    'CK': 'NZD', // Cook Islands - New Zealand Dollar
    'CW': 'ANG', // Curaçao - Netherlands Antillean Guilder
    'FK': 'FKP', // Falk
  };
    return currencyMap[countryCode] ?? 'USD';
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
