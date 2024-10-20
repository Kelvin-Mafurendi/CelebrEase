import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroro/Provider/state_management.dart';
//import 'package:maroro/pages/vendor_calender.dart';
import 'package:provider/provider.dart';

class BookingForm extends StatefulWidget {
  final String package_id;

  const BookingForm({
    Key? key,
    required this.package_id,
  }) : super(key: key);

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDate;
  String? _selectedService;
  Map<String, dynamic> _serviceData = {};
  List<TimeSlot> _availableTimeSlots = [];
  List<TimeSlot> _selectedTimeSlots = [];
  bool _isLoading = false;
  String? _vendorId;
  String? _serviceType;
  DateTime? selectedDate;
  Timer? _debounce;

  // Constants for booking duration limits
  static const int MIN_BOOKING_HOURS = 1;
  static const int MAX_BOOKING_HOURS = 8;

  // Define your serviceFields here, each key representing a service and its custom fields
  final Map<String, List<Map<String, dynamic>>> serviceFields = {
    'Accomodation': [
      {'name': 'checkInDate', 'label': 'Check-in Date', 'type': 'date'},
      {'name': 'checkOutDate', 'label': 'Check-out Date', 'type': 'date'},
      {'name': 'guestCount', 'label': 'Number of Guests', 'type': 'number'},
      {
        'name': 'numberOfRooms',
        'label': 'Number of Rooms Required',
        'type': 'number'
      },
      {
        'name': 'roomType',
        'label': 'Room Type',
        'type': 'select',
        'options': ['Single', 'Double', 'Suite', 'Villa']
      },
      {
        'name': 'roomPreferences',
        'label': 'Room Preferences',
        'type': 'multiselect',
        'options': [
          'Non-smoking',
          'Near Elevator',
          'High Floor',
          'Low Floor',
          'Quiet Room',
          'Ocean View',
          'Garden View',
          'Pool Access'
        ]
      },
      {
        'name': 'addOns',
        'label': 'Add-ons',
        'type': 'multiselect',
        'options': [
          'Breakfast',
          'Airport Shuttle',
          'Late Check-out',
          'Spa Access',
          'Room Service',
          'Extra Bed',
          'Welcome Package',
          'VIP Treatment'
        ]
      },
      {
        'name': 'specialRequests',
        'label': 'Special Requests',
        'type': 'multiline'
      },
    ],
    'Bakery': [
      {
        'name': 'bakedGoodsType',
        'label': 'Type of Baked Goods',
        'type': 'select',
        'options': ['Cake', 'Cupcakes', 'Cookies', 'Bread', 'Pastries']
      },
      {'name': 'guestCount', 'label': 'Number of Servings', 'type': 'number'},
      {'name': 'flavor', 'label': 'Flavor Preferences', 'type': 'text'},
      {
        'name': 'occasion',
        'label': 'Occasion',
        'type': 'select',
        'options': [
          'Birthday',
          'Wedding',
          'Anniversary',
          'Baby Shower',
          'Corporate Event',
          'Holiday',
          'Other'
        ]
      },
      {'name': 'design', 'label': 'Design Preferences', 'type': 'multiline'},
      {
        'name': 'dietary',
        'label': 'Dietary Restrictions',
        'type': 'multiselect',
        'options': [
          'Gluten-free',
          'Vegan',
          'Nut-free',
          'Sugar-free',
          'Dairy-free',
          'Egg-free',
          'Kosher',
          'Halal'
        ]
      },
      {
        'name': 'delivery',
        'label': 'Delivery Method',
        'type': 'select',
        'options': ['Delivery', 'Pick-up']
      },
      {
        'name': 'deliveryTime',
        'label': 'Preferred Delivery/Pickup Time',
        'type': 'text'
      },
    ],
    'Clothing': [
      {
        'name': 'clothingType',
        'label': 'Type of Clothing',
        'type': 'select',
        'options': [
          'Wedding Gown',
          'Tuxedo',
          'Bridesmaid Dress',
          'Formal Wear',
          'Casual Wear'
        ]
      },
      {'name': 'size', 'label': 'Size/Measurements', 'type': 'multiline'},
      {'name': 'style', 'label': 'Style Preferences', 'type': 'text'},
      {
        'name': 'materialPreferences',
        'label': 'Material Preferences',
        'type': 'multiselect',
        'options': [
          'Silk',
          'Cotton',
          'Linen',
          'Velvet',
          'Satin',
          'Chiffon',
          'Lace',
          'Polyester'
        ]
      },
      {
        'name': 'fittings',
        'label': 'Fittings Required',
        'type': 'select',
        'options': ['Yes', 'No']
      },
      {
        'name': 'delivery',
        'label': 'Delivery Method',
        'type': 'select',
        'options': ['Home Delivery', 'Store Pickup']
      },
      {
        'name': 'returnDate',
        'label': 'Return Date (if rental)',
        'type': 'date'
      },
    ],
    'Flowers': [
      {
        'name': 'flowerType',
        'label': 'Type of Flowers',
        'type': 'multiselect',
        'options': [
          'Bouquets',
          'Centerpieces',
          'Floral Arches',
          'Corsages',
          'Boutonnieres',
          'Flower Crown',
          'Table Arrangements',
          'Loose Flowers'
        ]
      },
      {'name': 'colors', 'label': 'Color Preferences', 'type': 'text'},
      {
        'name': 'arrangements',
        'label': 'Number of Arrangements',
        'type': 'number'
      },
      {
        'name': 'eventType',
        'label': 'Event Type',
        'type': 'select',
        'options': [
          'Wedding',
          'Funeral',
          'Corporate',
          'Birthday',
          'Anniversary',
          'Graduation',
          'Other'
        ]
      },
      {
        'name': 'delivery',
        'label': 'Delivery Required',
        'type': 'select',
        'options': ['Yes', 'No']
      },
      {
        'name': 'setup',
        'label': 'Setup Required',
        'type': 'select',
        'options': ['Yes', 'No']
      },
      {
        'name': 'specificFlowers',
        'label': 'Specific Flowers Requested',
        'type': 'multiline'
      },
    ],
    'Food & Catering': [
      {'name': 'guestCount', 'label': 'Number of Guests', 'type': 'number'},
      {
        'name': 'cuisineType',
        'label': 'Cuisine Preferences',
        'type': 'multiselect',
        'options': [
          'Italian',
          'Asian',
          'Mediterranean',
          'American',
          'Indian',
          'International',
          'African',
          'Middle Eastern',
          'Mexican',
          'French'
        ]
      },
      {
        'name': 'cuisineDetails',
        'label': 'Additional Cuisine Details',
        'type': 'multiline'
      },
      {
        'name': 'serviceStyle',
        'label': 'Service Style',
        'type': 'select',
        'options': [
          'Buffet',
          'Plated',
          'Family Style',
          'Food Stations',
          'Cocktail Style',
          'Drop-off Catering'
        ]
      },
      {
        'name': 'dietary',
        'label': 'Dietary Restrictions',
        'type': 'multiselect',
        'options': [
          'Vegetarian',
          'Vegan',
          'Halal',
          'Kosher',
          'Gluten-free',
          'Dairy-free',
          'Nut-free',
          'Shellfish-free'
        ]
      },
      {
        'name': 'staffing',
        'label': 'Wait Staff Required',
        'type': 'select',
        'options': ['Yes', 'No']
      },
      {
        'name': 'drinks',
        'label': 'Drinks Package',
        'type': 'select',
        'options': ['Non-alcoholic Only', 'Beer & Wine', 'Full Bar', 'None']
      },
    ],
    'Jewelry': [
      {
        'name': 'jewelryType',
        'label': 'Type of Jewelry',
        'type': 'select',
        'options': ['Rings', 'Necklaces', 'Bracelets', 'Earrings', 'Full Set']
      },
      {
        'name': 'material',
        'label': 'Material Preferences',
        'type': 'multiselect',
        'options': [
          'Gold',
          'Silver',
          'Platinum',
          'Diamond',
          'Pearl',
          'Rose Gold',
          'White Gold',
          'Titanium'
        ]
      },
      {
        'name': 'gemstonePreferences',
        'label': 'Gemstone Preferences',
        'type': 'multiselect',
        'options': [
          'Diamond',
          'Ruby',
          'Emerald',
          'Sapphire',
          'Pearl',
          'Opal',
          'Amethyst',
          'Topaz'
        ]
      },
      {
        'name': 'customization',
        'label': 'Customization Details',
        'type': 'multiline'
      },
      {'name': 'sizing', 'label': 'Sizing Requirements', 'type': 'text'},
      {
        'name': 'returnDate',
        'label': 'Return Date (if rental)',
        'type': 'date'
      },
    ],
    'Photography': [
      {
        'name': 'eventType',
        'label': 'Type of Event',
        'type': 'select',
        'options': [
          'Wedding',
          'Corporate',
          'Family',
          'Portrait',
          'Product',
          'Birthday Party',
          'Corporate Event',
          'Anniversary Celebration',
          'Engagement Party',
          'Baby Shower',
          'Graduation Ceremony',
          'Religious Event',
          'Concert',
          'Festival',
          'Family Reunion',
          'Holiday Party',
          'Charity Event',
          'Workshop',
          'Exhibition',
          'Sporting Event',
          'School Event',
          'Retirement Party',
          'Private Party',
          'Other'
        ]
      },
      
      {
        'name': 'photographers',
        'label': 'Number of Photographers',
        'type': 'number'
      },
      {'name': 'location', 'label': 'Shooting Location', 'type': 'text'},
      {
        'name': 'editingPreferences',
        'label': 'Editing Preferences',
        'type': 'multiselect',
        'options': [
          'Basic Retouching',
          'Advanced Retouching',
          'Color Correction',
          'Black & White Edits',
          'Special Effects',
          'HDR Processing',
          'Background Editing'
        ]
      },
      {
        'name': 'specialRequests',
        'label': 'Special Requests',
        'type': 'multiline'
      },
      {
        'name': 'extras',
        'label': 'Additional Services',
        'type': 'multiselect',
        'options': [
          'Drone Photography',
          'Prints',
          'Photo Album',
          'Digital Files',
          'Same-day Edit',
          'Engagement Shoot',
          'Photo Booth',
          'Live Streaming'
        ]
      },
    ],
    'Videography': [
      {
        'name': 'eventType',
        'label': 'Type of Event',
        'type': 'select',
        'options': [
          'Wedding',
          'Music Video',
          'Documentary',
          'Commercial',
          'Birthday Party',
          'Corporate Event',
          'Anniversary Celebration',
          'Engagement Party',
          'Baby Shower',
          'Graduation Ceremony',
          'Religious Event',
          'Concert',
          'Festival',
          'Family Reunion',
          'Holiday Party',
          'Charity Event',
          'Workshop',
          'Exhibition',
          'Photo/Video Shoot',
          'Sporting Event',
          'School Event',
          'Retirement Party',
          'Private Party',
          'Other'
        ]
      },
      
      {
        'name': 'videographers',
        'label': 'Number of Videographers',
        'type': 'number'
      },
      {'name': 'location', 'label': 'Filming Location', 'type': 'text'},
      {'name': 'script', 'label': 'Script/Storyboard', 'type': 'multiline'},
      {
        'name': 'specialEffects',
        'label': 'Special Effects Required',
        'type': 'multiselect',
        'options': [
          'Drone Footage',
          'Slow Motion',
          'Time-lapse',
          'Animation',
          'Color Grading',
          'Special Transitions',
          'Green Screen'
        ]
      },
      {
        'name': 'deliveryFormat',
        'label': 'Delivery Format',
        'type': 'multiselect',
        'options': [
          'Digital Download',
          'USB Drive',
          'DVD/Blu-ray',
          'Raw Footage',
          'Social Media Optimized',
          'Cinema Format'
        ]
      },
    ],
    'Venues': [
      {
        'name': 'eventType',
        'label': 'Type of Event',
        'type': 'select',
        'options': [
          'Wedding',
          'Birthday Party',
          'Corporate Event',
          'Anniversary Celebration',
          'Engagement Party',
          'Baby Shower',
          'Graduation Ceremony',
          'Religious Event',
          'Concert',
          'Festival',
          'Family Reunion',
          'Holiday Party',
          'Charity Event',
          'Workshop',
          'Exhibition',
          'Photo/Video Shoot',
          'Sporting Event',
          'School Event',
          'Retirement Party',
          'Funeral',
          'Private Party',
          'Other',
        ]
      },
      {
        'name': 'venueCapacity',
        'label': 'Venue Capacity (number of guests)',
        'type': 'number'
      },
      
      {
        'name': 'venueType',
        'label': 'Venue Type',
        'type': 'select',
        'options': ['Indoor', 'Outdoor', 'Both']
      },
      {
        'name': 'amenities',
        'label': 'Required Amenities',
        'type': 'multiselect',
        'options': [
          'Parking',
          'Air Conditioning',
          'Kitchen',
          'Stage',
          'Sound System',
          'Lighting',
          'Furniture',
          'Restrooms',
          'Wheelchair Access',
          'WI-FI'
        ]
      },
      {
        'name': 'setupTime',
        'label': 'Setup Time Required',
        'type': 'select',
        'options': [
          '1 hour before',
          '2 hours before',
          '3 hours before',
          '4+ hours before'
        ]
      }
    ],
    'Music': [
      {
        'name': 'musicType',
        'label': 'Type of Music Service',
        'type': 'select',
        'options': ['Live Band', 'DJ', 'Solo Performer', 'Orchestra', 'Choir']
      },
      
      {
        'name': 'numberOfPerformers',
        'label': 'Number of Performers',
        'type': 'number'
      },
      {
        'name': 'musicGenre',
        'label': 'Music Genre Preferences',
        'type': 'multiselect',
        'options': [
          'Pop',
          'Rock',
          'Jazz',
          'Classical',
          'R&B',
          'Hip-Hop',
          'Traditional'
        ]
      },
      {
        'name': 'equipment',
        'label': 'Equipment Required',
        'type': 'multiselect',
        'options': [
          'Sound System',
          'Microphones',
          'Speakers',
          'Lighting',
          'Instruments',
          'Stage'
        ]
      }
    ],
    'Choreography': [
      {
        'name': 'performerCount',
        'label': 'Number of Performers',
        'type': 'number'
      },
      
      {
        'name': 'danceStyle',
        'label': 'Dance Style',
        'type': 'multiselect',
        'options': [
          'Contemporary',
          'Traditional',
          'Ballet',
          'Hip-Hop',
          'Ballroom',
          'Cultural'
        ]
      },
      {
        'name': 'costumeRequirements',
        'label': 'Costume Requirements',
        'type': 'multiline'
      }
    ],
    'MC': [
      
      {
        'name': 'eventType',
        'label': 'Type of Event',
        'type': 'select',
        'options': [
          'Wedding',
          'Corporate Event',
          'Award Ceremony',
          'Conference',
          'Gala',
          'Festival',
          'Other'
        ]
      },
      {
        'name': 'languagePreference',
        'label': 'Language Preference',
        'type': 'multiselect',
        'options': ['English', 'Afrikaans', 'Zulu', 'Xhosa', 'Other']
      },
      {
        'name': 'specialRequirements',
        'label': 'Special Requirements',
        'type': 'multiline'
      }
    ],
    'Beauty': [
      {
        'name': 'serviceType',
        'label': 'Type of Beauty Service',
        'type': 'multiselect',
        'options': ['Makeup', 'Hair', 'Nails', 'Skincare', 'Full Package']
      },
      {
        'name': 'guestCount',
        'label': 'Number of Clients',
        'type': 'number'
      },
      {
        'name': 'style',
        'label': 'Style Preference',
        'type': 'select',
        'options': [
          'Natural',
          'Glamour',
          'Bridal',
          'Editorial',
          'Special Effects',
          'Cultural'
        ]
      },
      
      {
        'name': 'location',
        'label': 'Service Location',
        'type': 'select',
        'options': ['At Venue', 'At Salon', 'At Home']
      }
    ],
    
    'Decor': [
      {
        'name': 'venueSize',
        'label': 'Venue Size (square meters)',
        'type': 'number'
      },
      {'name': 'theme', 'label': 'Theme', 'type': 'text'},
      {'name': 'guestCount', 'label': 'Number of Guests', 'type': 'number'},
      {
        'name': 'decorItems',
        'label': 'Decor Items Required',
        'type': 'multiselect',
        'options': [
          'Flowers',
          'Lighting',
          'Furniture',
          'Backdrops',
          'Table Settings',
          'Draping',
          'Centerpieces'
        ]
      },
      {'name': 'colorScheme', 'label': 'Color Scheme', 'type': 'text'}
    ],
    'Event Planning': [
      {
        'name': 'eventType',
        'label': 'Type of Event',
        'type': 'select',
        'options': [
          'Wedding',
          'Corporate Event',
          'Birthday',
          'Anniversary',
          'Product Launch',
          'Conference',
          'Other'
        ]
      },
      {'name': 'guestCount', 'label': 'Number of Guests', 'type': 'number'},
      
      {
        'name': 'planningServices',
        'label': 'Planning Services Required',
        'type': 'multiselect',
        'options': [
          'Full Planning',
          'Day-of Coordination',
          'Vendor Management',
          'Budget Management',
          'Timeline Planning'
        ]
      },
      {
        'name': 'budget',
        'label': 'Budget Range',
        'type': 'select',
        'options': [
          'Under R10,000',
          'R10,000 - R25,000',
          'R25,000 - R50,000',
          'R50,000+'
        ]
      }
    ],
    'Gifts': [
      {
        'name': 'giftType',
        'label': 'Type of Gift',
        'type': 'select',
        'options': ['Customized', 'Standard', 'Corporate', 'Wedding Favors']
      },
      {'name': 'quantity', 'label': 'Number of Items', 'type': 'number'},
      {
        'name': 'deliveryOption',
        'label': 'Delivery Option',
        'type': 'select',
        'options': ['Pick-up', 'Standard Delivery', 'Express Delivery']
      },
      {
        'name': 'giftPreferences',
        'label': 'Gift Preferences',
        'type': 'multiline'
      },
      {
        'name': 'packaging',
        'label': 'Packaging Requirements',
        'type': 'select',
        'options': ['Standard', 'Premium', 'Luxury', 'Eco-Friendly']
      }
    ],
    'Hair Dressing': [
      {'name': 'guestCount', 'label': 'Number of Clients', 'type': 'number'},
      {
        'name': 'style',
        'label': 'Hairstyle Type',
        'type': 'select',
        'options': [
          'Braids',
          'Weaves',
          'Natural Styling',
          'Cuts',
          'Color',
          'Bridal',
          'Formal'
        ]
      },
      
      {
        'name': 'location',
        'label': 'Service Location',
        'type': 'select',
        'options': ['At Salon', 'At Home', 'At Venue']
      },
      {
        'name': 'additionalServices',
        'label': 'Additional Services',
        'type': 'multiselect',
        'options': [
          'Hair Treatment',
          'Scalp Treatment',
          'Hair Extensions',
          'Hair Products'
        ]
      }
    ],
    'Event Security': [
      {
        'name': 'eventType',
        'label': 'Type of Event',
        'type': 'select',
        'options': [
          'Wedding',
          'Birthday Party',
          'Private Party',
          'Corporate Event',
          'Anniversary Celebration',
          'Engagement Party',
          'Baby Shower',
          'Graduation Ceremony',
          'Religious Event',
          'Concert',
          'Festival',
          'Family Reunion',
          'Holiday Party',
          'Charity Event',
          'Workshop',
          'Exhibition',
          'Photo/Video Shoot',
          'Sporting Event',
          'School Event',
          'Retirement Party',
          'Funeral',
          'Other'
        ]
      },
      {'name': 'guestCount', 'label': 'Number of Guests', 'type': 'number'},
      {
        'name': 'securityPersonnel',
        'label': 'Number of Security Personnel Required',
        'type': 'number'
      },
      {
        'name': 'securityType',
        'label': 'Type of Security',
        'type': 'select',
        'options': [
          'Armed Security',
          'Unarmed Security',
          'Bodyguards',
          'Crowd Control',
          'Entrance and Exit Control',
          'Surveillance Monitoring'
        ]
      },
      {
        'name': 'budget',
        'label': 'Budget Range',
        'type': 'select',
        'options': [
          'Under ZAR 5,000',
          'ZAR 5,000-ZAR 10,000',
          'ZAR 10,000-ZAR 20,000',
          'ZAR 20,000+'
        ]
      },
      {
        'name': 'preferences',
        'label': 'Special Instructions or Requirements',
        'type': 'multiline'
      }
    ],
    'Transport': [
      {
        'name': 'vehicleType',
        'label': 'Type of Vehicle',
        'type': 'select',
        'options': ['Sedan', 'SUV', 'Van', 'Bus', 'Limousine', 'Luxury Car']
      },
      {
        'name': 'numberOfVehicles',
        'label': 'Number of Vehicles Required',
        'type': 'number'
      },
      {
        'name': 'estimatedDistance',
        'label': 'Estimated Distance (km)',
        'type': 'number'
      },
      
      {
        'name': 'passengerCount',
        'label': 'Number of Passengers',
        'type': 'number'
      },
      {
        'name': 'specialRequirements',
        'label': 'Special Requirements',
        'type': 'multiselect',
        'options': [
          'Child Seats',
          'Wheelchair Access',
          'Luggage Space',
          'Professional Driver',
          'GPS Navigation'
        ]
      }
    ],
  };

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController numberOfGuestsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    //getServiceCategories();
    addressController.text = 'Vendor Location';
    _initializeVendorId(); //and load initial data
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    nameController.dispose();
    addressController.dispose();
    notesController.dispose();
    eventTypeController.dispose();
    numberOfGuestsController.dispose();
    super.dispose();
  }

  Future<void> _initializeVendorId() async {
    try {
      final packageDoc = await FirebaseFirestore.instance
          .collection('Packages')
          .doc(widget.package_id)
          .get();

      if (packageDoc.exists && mounted) {
        setState(() {
          _vendorId = packageDoc.data()?['userId'];
          _serviceType = packageDoc.data()?['serviceType'];
          _selectedService = _serviceType;
        });
      }
    } catch (e) {
      print('Error initializing vendor ID: $e');
    }
  }

  /*Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTimeSlots();
    }
  }*/

  Future<void> _loadAvailableTimeSlots(DateTime date) async {
    if (_vendorId == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final doc = await FirebaseFirestore.instance
        .collection('vendor_availability')
        .doc(_vendorId)
        .collection('dates')
        .doc(dateStr)
        .get();

    List<TimeSlot> slots;
    if (doc.exists) {
      slots = (doc.data()?['slots'] as List?)
              ?.map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
              .where((slot) => slot.status == SlotStatus.available)
              .toList() ??
          await _generateDefaultTimeSlots();
    } else {
      slots = await _generateDefaultTimeSlots();
    }

    setState(() {
      _availableTimeSlots = slots;
      _selectedTimeSlots.clear(); // Reset selections when date changes
    });
  }

  Future<List<TimeSlot>> _generateDefaultTimeSlots() async {
    List<TimeSlot> slots = [];
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);

    try {
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('Vendors')
          .doc(_vendorId)
          .get();

      if (vendorSnapshot.exists) {
        String? startTimeString = vendorSnapshot['startTime'];
        String? endTimeString = vendorSnapshot['endTime'];

        if (startTimeString != null && endTimeString != null) {
          List<String> startParts = startTimeString.split(':');
          List<String> endParts = endTimeString.split(':');

          startTime = TimeOfDay(
            hour: int.parse(startParts[0]),
            minute: int.parse(startParts[1]),
          );

          endTime = TimeOfDay(
            hour: int.parse(endParts[0]),
            minute: int.parse(endParts[1]),
          );
        }
      }
    } catch (e) {
      print('Error fetching vendor times: $e');
    }

    for (int hour = startTime.hour; hour < endTime.hour; hour++) {
      slots.add(
        TimeSlot(
          start: TimeOfDay(hour: hour, minute: 0),
          end: TimeOfDay(hour: hour + 1, minute: 0),
          status: SlotStatus.available,
        ),
      );
    }
    return slots;
  }

  bool _canSelectSlot(TimeSlot slot, int index) {
    if (_selectedTimeSlots.isEmpty) return true;

    final slotTime = slot.start.hour * 60 + slot.start.minute;

    for (var selectedSlot in _selectedTimeSlots) {
      final selectedTime =
          selectedSlot.start.hour * 60 + selectedSlot.start.minute;
      final timeDiff = (slotTime - selectedTime).abs();

      if (timeDiff == 60) return true;
    }

    return false;
  }

  String _getSelectedTimeRange() {
    if (_selectedTimeSlots.isEmpty) return '';

    final firstSlot = _selectedTimeSlots.first;
    final lastSlot = _selectedTimeSlots.last;

    return '${firstSlot.start.format(context)} - ${lastSlot.end.format(context)}';
  }

  bool _validateBookingDuration() {
    if (_selectedTimeSlots.isEmpty) return false;

    int totalHours = _selectedTimeSlots.length;
    if (totalHours < MIN_BOOKING_HOURS || totalHours > MAX_BOOKING_HOURS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Booking duration must be between $MIN_BOOKING_HOURS and $MAX_BOOKING_HOURS hours'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // UI Building Methods
  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
              : '',
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (pickedDate != null && pickedDate != selectedDate) {
            setState(() {
              selectedDate = pickedDate;
            });
            await _loadAvailableTimeSlots(pickedDate);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget buildTimeSlotPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Time Slots (Select multiple slots for longer bookings)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Minimum booking: $MIN_BOOKING_HOURS hour(s), Maximum: $MAX_BOOKING_HOURS hours',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              itemCount: _availableTimeSlots.length,
              itemBuilder: (context, index) {
                final slot = _availableTimeSlots[index];
                final isSelected = _selectedTimeSlots.contains(slot);
                final timeString =
                    '${_formatTimeOfDay(slot.start)} - ${_formatTimeOfDay(slot.end)}';
                final canSelect = _canSelectSlot(slot, index);

                return CheckboxListTile(
                  title: Text(timeString),
                  value: isSelected,
                  enabled: slot.status == SlotStatus.available && canSelect,
                  subtitle: !canSelect && !isSelected
                      ? Text('Must select consecutive slots',
                          style:
                              TextStyle(color: Colors.red[300], fontSize: 12))
                      : null,
                  onChanged: (bool? value) {
                    if (value != null && canSelect) {
                      setState(() {
                        if (value) {
                          _selectedTimeSlots.add(slot);
                        } else {
                          _selectedTimeSlots.remove(slot);
                        }
                        _selectedTimeSlots.sort((a, b) =>
                            (a.start.hour * 60 + a.start.minute)
                                .compareTo(b.start.hour * 60 + b.start.minute));
                      });
                    }
                  },
                );
              },
            ),
          ),
          if (_selectedTimeSlots.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Selected Time Range: ${_getFormattedTimeRange()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Updated helper method for 24-hour format
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

// If you need to parse this format back to TimeOfDay, you can add this helper
  TimeOfDay parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

// For displaying the selected time range
  String _getFormattedTimeRange() {
    if (_selectedTimeSlots.isEmpty) return '';
    final startTime = _selectedTimeSlots.first.start;
    final endTime = _selectedTimeSlots.last.end;
    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  Widget buildNotesField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: notesController,
        decoration: const InputDecoration(
          labelText: 'Additional Notes',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Form"),
      ),
      body: _selectedService == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    buildDatePicker(),
                    if (selectedDate != null) buildTimeSlotPicker(),
                    if (_selectedService != null) ..._buildCustomFields(),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit Booking'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Function to build dynamic custom fields based on the selected service
  List<Widget> _buildCustomFields() {
    if (_selectedService == null ||
        !serviceFields.containsKey(_selectedService)) {
      return [];
    }

    return serviceFields[_selectedService]?.map((field) {
          // Create a controller if it doesn't exist
          if (!_controllers.containsKey(field['name'])) {
            _controllers[field['name']] = TextEditingController(
                text: _serviceData[field['name']]?.toString() ?? '');
          }

          switch (field['type']) {
            case 'date':
              return _buildDateField(field);
            case 'number':
              return _buildNumberField(field);
            case 'text':
              return _buildTextField(field);
            case 'multiline':
              return _buildMultilineTextField(field);
            case 'select':
              return _buildDropdownField(field);
            case 'multiselect':
              return _buildMultiselectField(field);
            default:
              return SizedBox.shrink();
          }
        }).toList() ??
        [];
  }

// Add this map to your state class
  final Map<String, TextEditingController> _controllers = {};

  Widget _buildTextField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field['name']],
        //textDirection: TextDirection.ltr, // Explicitly set text direction
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field['name']],
        //textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = int.tryParse(value) ?? 0;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMultilineTextField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field['name']],
        //textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        //textDirection: ,
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        controller: TextEditingController(
          text: _serviceData[field['name']] ?? '',
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (pickedDate != null) {
            setState(() {
              // Save the formatted date as a string
              _serviceData[field['name']] =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: field['label'],
          border: OutlineInputBorder(),
        ),
        items: (field['options'] as List)
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _serviceData[field['name']] = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a ${field['label']}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMultiselectField(Map field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field['label']),
          ...(field['options'] as List).map((option) {
            return CheckboxListTile(
              title: Text(option.toString()),
              value: _serviceData[field['name']]?.contains(option) ?? false,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _serviceData[field['name']] ??= [];
                    (_serviceData[field['name']] as List).add(option);
                  } else {
                    (_serviceData[field['name']] as List).remove(option);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  // Submit form logic
  Future _submitForm() async {
    if (_formKey.currentState!.validate() && _validateBookingDuration()) {
      try {
        final firstSlot = _selectedTimeSlots.first;
        final lastSlot = _selectedTimeSlots.last;

        // Basic booking data [1]
        Map<String, dynamic> data = {
          'package id': widget.package_id,
          'name': nameController.text,
          'event date': selectedDate,
          'start': _formatTimeOfDay(firstSlot.start),
          'end': _formatTimeOfDay(lastSlot.end),
          'selected_slots':
              _selectedTimeSlots.map((slot) => slot.toMap()).toList(),
          'address': addressController.text,
          'event': eventTypeController.text,
          'guests': numberOfGuestsController.text,
        };

        // Add extra notes if provided [2]
        if (notesController.text.isNotEmpty) {
          data['extra notes'] = notesController.text;
        }

        // Add data from _serviceData to the booking data
        data.addAll(_serviceData);

        // Update form data using state management [2]
        bool success = await Provider.of<ChangeManager>(context, listen: false)
            .updateForm(data);

        // Show result dialog [2, 3]
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(success ? "Success" : "Error"),
              content: Text(success
                  ? "Booking added to cart"
                  : "Failed to add booking to cart"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (success) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Show error dialog [3]
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text("An error occurred: ${e.toString()}"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

class TimeSlot {
  final TimeOfDay start;
  final TimeOfDay end;
  final SlotStatus status;

  TimeSlot({
    required this.start,
    required this.end,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
      'status': status.toString(),
    };
  }

  static TimeSlot fromMap(Map<String, dynamic> map) {
    final startParts = map['start'].split(':');
    final endParts = map['end'].split(':');
    return TimeSlot(
      start: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      end: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      status: SlotStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
    );
  }

  TimeSlot copyWith({
    TimeOfDay? start,
    TimeOfDay? end,
    SlotStatus? status,
  }) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
      status: status ?? this.status,
    );
  }
}

enum SlotStatus { available, unavailable, booked }
