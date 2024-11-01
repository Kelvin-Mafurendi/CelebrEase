// Define your serviceFields here, each key representing a service and its custom fields
Map<String, List<Map<String, dynamic>>> serviceFields = {
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
    {'name': 'returnDate', 'label': 'Return Date (if rental)', 'type': 'date'},
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
      'type': 'select',
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
      'label': 'Customization Options',
      'type': 'select'
    },
    {'name': 'sizing', 'label': 'Sizing Requirements', 'type': 'text'},
    {'name': 'returnDate', 'label': 'Return Date (if rental)', 'type': 'date'},
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
    {'name': 'guestCount', 'label': 'Number of Clients', 'type': 'number'},
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


// Updated rate units map with service-specific units
Map<String, List<String>> rateUnits = {
  'Accomodation': ['per night', 'per week', 'per month'],
  'Bakery': ['per item', 'per dozen', 'per order'],
  'Clothing': ['per item', 'per rental', 'per set'],
  'Flowers': ['per arrangement', 'per bouquet', 'per event'],
  'Food & Catering': ['per person', 'per event', 'per hour'],
  'Jewelry': ['per piece', 'per set', 'per custom order'],
  'Photography': ['per hour', 'per event', 'per package'],
  'Videography': ['per hour', 'per event', 'per package'],
  'Venues': ['per hour', 'per day', 'per event'],
  'Transport': ['per trip', 'per hour', 'per day'],
  'Music': ['per hour', 'per event', 'per performance'],
  'Choreography': ['per session', 'per event', 'per performance'],
  'MC': ['per hour', 'per event'],
  'Beauty': ['per person', 'per session', 'per event'],
  'Decor': ['per event', 'per item', 'per package'],
  'Event Planning': ['per event', 'per hour', 'per package'],
  'Event Security': ['per event', 'per hour', 'per package'],
  'Gifts': ['per item', 'per package', 'per order'],
  'Hair Dressing': ['per service', 'per hour', 'per person'],
  'Other': ['per service', 'per hour', 'per event'],
};

// Updated field labels map with comprehensive labels
Map<String, String> vendorFieldLabels = {
  'packageName': 'Package Name',
  'rate': 'Rate',
  'description': 'Description',
  'roomType': 'Room Type',
  'amenities': 'Amenities',
  'capacity': 'Capacity',
  'itemTypes': 'Item Types',
  'customOrders': 'Custom Orders',
  'quantityOptions': 'Quantity Options',
  'clothingType': 'Type of Clothing',
  'sizes': 'Available Sizes',
  'customDesign': 'Custom Design Options',
  'materials': 'Materials Used',
  'flowerTypes': 'Types of Flowers',
  'bouquetStyles': 'Bouquet Styles',
  'delivery': 'Delivery Options',
  'cuisineType': 'Cuisine Type',
  'menuItems': 'Menu Items',
  'dietaryOptions': 'Dietary Options',
  'servingCapacity': 'Number of People Served',
  'jewelryType': 'Type of Jewelry',
  'customization': 'Customization Options',
  'shootType': 'Type of Photography',
  'duration': 'Duration',
  'deliverables': 'Deliverables',
  'equipment': 'Equipment Included',
  'editingOptions': 'Editing Options',
  'addOns': 'Additional Services',
  'venueType': 'Venue Type',
  'range': 'Service Range',
  'musicType': 'Type of Music',
  'danceStyle': 'Dance Style',
  'rehearsalDuration': 'Rehearsal Duration',
  'numberOfDancers': 'Number of Dancers',
  'eventTypes': 'Event Types',
  'languages': 'Languages',
  'experience': 'Years of Experience',
  'makeupTypes': 'Types of Makeup',
  'products': 'Products Used',
  'trialSessions': 'Trial Sessions',
  'decorStyle': 'Decoration Style',
  'colorSchemes': 'Color Schemes',
  'decorTypes': 'Types of Decorations',
  'setupTime': 'Setup Time',
  'planningServices': 'Planning Services',
  'teamSize': 'Team Size',
  'giftTypes': 'Types of Gifts',
  'hairServices': 'Hair Services',
  'serviceType': 'Type of Service',
};

// Updated field hints map with comprehensive hints
Map<String, String> vendorFieldHints = {
  'packageName': 'Enter a unique name for your package',
  'rate': 'Enter the price',
  'description': 'Provide a detailed description of your package',
  'roomType': 'E.g., Single, Double, Suite',
  'amenities': 'Add all available amenities',
  'capacity': 'Maximum number of people',
  'itemTypes': 'Types of items available',
  'customOrders': 'Describe custom order options',
  'quantityOptions': 'Specify minimum and maximum order quantities',
  'clothingType': 'E.g., Formal, Casual, Traditional',
  'sizes': 'Available sizes,',
  'customDesign': 'Describe custom design options',
  'materials': 'List materials used, ',
  'flowerTypes': 'Types of flowers available',
  'bouquetStyles': 'Available arrangement styles',
  'delivery': 'Describe delivery options and areas',
  'cuisineType': 'Type of cuisine offered',
  'menuItems': 'List main menu items',
  'dietaryOptions': 'Available dietary accommodation options',
  'servingCapacity': 'Maximum number of people you can serve',
  'jewelryType': 'Types of jewelry pieces offered',
  'customization': 'Available customization options',
  'shootType': 'Types of photography services offered',
  'duration': 'Length of service or event',
  'deliverables': "What's included in the final delivery",
  'equipment': 'List of equipment provided',
  'editingOptions': 'Available editing and post-production services',
  'addOns': 'Additional services available',
  'venueType': 'Type of venue and setting',
  'range': 'Service area or distance covered',
  'musicType': 'Styles of music offered',
  'danceStyle': 'Types of dance styles taught',
  'rehearsalDuration': 'Length of rehearsal sessions',
  'numberOfDancers': 'Number of dancers included',
  'eventTypes': 'Types of events covered',
  'languages': 'Languages spoken',
  'experience': 'Years of experience in the field',
  'makeupTypes': 'Types of makeup services offered',
  'products': 'Products and brands used',
  'trialSessions': 'Trial session availability and details',
  'decorStyle': 'Decoration styles available',
  'colorSchemes': 'Available color schemes',
  'decorTypes': 'Types of decorations offered',
  'setupTime': 'Time required for setup',
  'planningServices': 'Planning services included',
  'teamSize': 'Number of team members',
  'giftTypes': 'Types of gifts available',
  'hairServices': 'Hair services offered',
  'serviceType': 'Specify the type of service offered',
};
Map<String, List<Map<String, dynamic>>> vendorServiceFields = {
  'Accomodation': [
    {
      'fieldName': 'roomType',
      'label': 'Room Type',
      'type': 'select',
      'hint': 'E.g., Single, Double, Suite'
    },
    {
      'fieldName': 'amenities',
      'label': 'Amenities',
      'type': 'multiselect',
      'hint': 'List all available amenities,'
    },
    {
      'fieldName': 'capacity',
      'label': 'Capacity',
      'type': 'number',
      'hint': 'Maximum number of people'
    },
    {
      'fieldName': 'availability',
      'label': 'Availability',
      'type': 'date',
      'hint': 'Specify available dates or periods'
    },
    {
      'fieldName': 'roomPreferences',
      'label': 'Room Preferences',
      'type': 'multiselect',
      'hint': 'Specify room preferences, e.g., Non-smoking, High Floor'
    },
    {
      'fieldName': 'addOns',
      'label': 'Add-ons',
      'type': 'multiselect',
      'hint': 'Specify additional services, e.g., Breakfast, Airport Shuttle'
    },
  ],
  'Bakery': [
    {
      'fieldName': 'itemTypes',
      'label': 'Item Types',
      'type': 'multiselect', 
      'hint': 'Types of items available,'
    },
    {
      'fieldName': 'customOrders',
      'label': 'Custom Orders',
      'type': 'select', 
      'hint': 'Describe custom order options'
    },
    {
      'fieldName': 'quantityOptions',
      'label': 'Quantity Options',
      'type': 'select',
      'hint': 'Specify possible order quantities'
    },
    {
      'fieldName': 'bakedGoodsType',
      'label': 'Type of Baked Goods',
      'type': 'select',
      'hint': 'E.g., Cakes, Cookies, Breads'
    },
    {
      'fieldName': 'occasion',
      'label': 'Occasion',
      'type': 'select',
      'hint': 'E.g., Birthday, Wedding, Anniversary'
    },
    {
      'fieldName': 'dietary',
      'label': 'Dietary Restrictions',
      'type': 'multiselect',
      'hint': 'Specify dietary restrictions, e.g., Gluten-free, Vegan'
    },
    {
      'fieldName': 'delivery',
      'label': 'Delivery Method',
      'type': 'select',
      'hint': 'Specify delivery method, e.g., Delivery, Pick-up'
    },
  ],
  'Clothing': [
    {
      'fieldName': 'clothingType',
      'label': 'Type of Clothing',
      'type': 'select',
      'hint': 'E.g., Formal, Casual, Traditional'
    },
    {
      'fieldName': 'sizes',
      'label': 'Available Sizes',
      'type': 'multiselect',
      'hint': 'Available sizes'
    },
    {
      'fieldName': 'customDesign',
      'label': 'Custom Design Options',
      'type': 'select',
      'hint': 'Describe custom design options'
    },
    {
      'fieldName': 'materials',
      'label': 'Materials Used',
      'type': 'multiselect',
      'hint': 'List materials used,'
    },
    {
      'fieldName': 'fittings',
      'label': 'Fittings Required',
      'type': 'select',
      'hint': 'Specify whether fittings are required (Yes/No)'
    },
    {
      'fieldName': 'delivery',
      'label': 'Delivery Method',
      'type': 'select',
      'hint': 'Specify the delivery method, e.g., Home Delivery, Store Pickup'
    },
    {
      'fieldName': 'materialPreferences',
      'label': 'Material Preferences',
      'type': 'multiselect',
      'hint': 'Specify preferred materials, e.g., Silk, Cotton, Linen'
    },
  ],
  'Flowers': [
    {
      'fieldName': 'flowerTypes',
      'label': 'Types of Flowers',
      'type': 'multiselect',
      'hint': 'Types of flowers available'
    },
    {
      'fieldName': 'bouquetStyles',
      'label': 'Bouquet Styles',
      'type': 'select',
      'hint': 'Available arrangement styles'
    },
    {
      'fieldName': 'delivery',
      'label': 'Delivery Options',
      'type': 'select',
      'hint': 'Describe delivery options and areas'
    },
    {
      'fieldName': 'eventType',
      'label': 'Event Type',
      'type': 'select',
      'hint': 'Specify the event type, e.g., Wedding, Funeral, Birthday'
    },
    {
      'fieldName': 'flowerType',
      'label': 'Type of Flowers',
      'type': 'multiselect',
      'hint': 'Specify types of flowers, e.g., Bouquets, Centerpieces'
    },
    {
      'fieldName': 'delivery',
      'label': 'Delivery Required',
      'type': 'select',
      'hint': 'Specify whether delivery is required (Yes/No)'
    },
    {
      'fieldName': 'setup',
      'label': 'Setup Required',
      'type': 'select',
      'hint': 'Specify whether setup is required (Yes/No)'
    },
  ],
  'Food & Catering': [
    {
      'fieldName': 'cuisineType',
      'label': 'Cuisine Type',
      'type': 'multiselect',
      'hint': 'Type of cuisine offered'
    },
    {
      'fieldName': 'menuItems',
      'label': 'Menu Items',
      'type': 'select',
      'hint': 'List main menu items'
    },
    {
      'fieldName': 'dietaryOptions',
      'label': 'Dietary Options',
      'type': 'multiselect',
      'hint': 'Available dietary accommodation options'
    },
    {
      'fieldName': 'servingCapacity',
      'label': 'Number of People Served',
      'type': 'number',
      'hint': 'Maximum number of people you can serve'
    },
    {
      'fieldName': 'serviceStyle',
      'label': 'Service Style',
      'type': 'select',
      'hint': 'Specify the service style, e.g., Buffet, Plated, Family Style'
    },
    {
      'fieldName': 'dietary',
      'label': 'Dietary Restrictions',
      'type': 'multiselect',
      'hint': 'Specify any dietary restrictions, e.g., Vegetarian, Vegan, Gluten-free'
    },
    {
      'fieldName': 'staffing',
      'label': 'Wait Staff Required',
      'type': 'select',
      'hint': 'Specify whether wait staff is required (Yes/No)'
    },
    {
      'fieldName': 'drinks',
      'label': 'Drinks Package',
      'type': 'select',
      'hint': 'Specify the drinks package, e.g., Non-alcoholic, Beer & Wine, Full Bar'
    },
  ],
  'Jewelry': [
    {
      'fieldName': 'jewelryType',
      'label': 'Type of Jewelry',
      'type': 'select',
      'hint': 'Types of jewelry pieces offered'
    },
    {
      'fieldName': 'materials',
      'label': 'Materials Used',
      'type': 'multiselect',
      'hint': 'List materials used,'
    },
    {
      'fieldName': 'customization',
      'label': 'Customization Options',
      'type': 'select',
      'hint': 'Available customization options'
    },
    {
      'fieldName': 'material',
      'label': 'Material Preferences',
      'type': 'multiselect',
      'hint': 'Specify preferred materials, e.g., Gold, Silver, Platinum'
    },
    {
      'fieldName': 'gemstonePreferences',
      'label': 'Gemstone Preferences',
      'type': 'multiselect',
      'hint': 'Specify gemstone preferences, e.g., Diamond, Ruby, Emerald'
    },
  ],
  'Photography': [
    {
      'fieldName': 'shootType',
      'label': 'Type of Photography',
      'type': 'select',
      'hint': 'Types of photography services offered'
    },
    {
      'fieldName': 'duration',
      'label': 'Duration',
      'type': 'number',
      'hint': 'Length of service or event'
    },
    {
      'fieldName': 'deliverables',
      'label': 'Deliverables',
      'type': 'select',
      'hint': "What's included in the final delivery"
    },
    {
      'fieldName': 'equipment',
      'label': 'Equipment Included',
      'type': 'multiselect',
      'hint': 'List of equipment provided'
    },
    {
      'fieldName': 'eventType',
      'label': 'Type of Event',
      'type': 'select',
      'hint': 'Specify event type, e.g., Wedding, Corporate, Family'
    },
    {
      'fieldName': 'editingPreferences',
      'label': 'Editing Preferences',
      'type': 'multiselect',
      'hint': 'Specify editing preferences, e.g., Basic Retouching, Color Correction'
    },
    {
      'fieldName': 'extras',
      'label': 'Additional Services',
      'type': 'multiselect',
      'hint': 'Specify additional services, e.g., Drone Photography, Prints'
    },
  ],
  'Videography': [
    {
      'fieldName': 'duration',
      'label': 'Duration',
      'type': 'number',
      'hint': 'Length of service or event'
    },
    {
      'fieldName': 'editingOptions',
      'label': 'Editing Options',
      'type': 'multiselect',
      'hint': 'Available editing and post-production services'
    },
    {
      'fieldName': 'addOns',
      'label': 'Additional Services',
      'type': 'multiselect',
      'hint': 'Additional services available'
    },
    {
      'fieldName': 'eventType',
      'label': 'Type of Event',
      'type': 'select',
      'hint': 'Specify event type, e.g., Wedding, Music Video, Documentary'
    },
    {
      'fieldName': 'specialEffects',
      'label': 'Special Effects Required',
      'type': 'multiselect',
      'hint': 'Specify special effects, e.g., Drone Footage, Slow Motion'
    },
    {
      'fieldName': 'deliveryFormat',
      'label': 'Delivery Format',
      'type': 'multiselect',
      'hint': 'Specify delivery format, e.g., Digital Download, USB Drive'
    },
  ],
  'Venues': [
    {
      'fieldName': 'venueType',
      'label': 'Venue Type',
      'type': 'select',
      'hint': 'Type of venue and setting'
    },
    {
      'fieldName': 'capacity',
      'label': 'Capacity',
      'type': 'number',
      'hint': 'Maximum number of people'
    },
    {
      'fieldName': 'amenities',
      'label': 'Amenities',
      'type': 'multiselect',
      'hint': 'List all available amenities,'
    },
    {
      'fieldName': 'availability',
      'label': 'Availability',
      'type': 'date',
      'hint': 'Specify available dates or periods'
    },
    {
      'fieldName': 'eventType',
      'label': 'Type of Event',
      'type': 'select',
      'hint': 'Specify event type, e.g., Wedding, Corporate Event, Birthday Party'
    },
    {
      'fieldName': 'venueType',
      'label': 'Venue Type',
      'type': 'select',
      'hint': 'Specify venue type, e.g., Indoor, Outdoor, Both'
    },
    {
      'fieldName': 'amenities',
      'label': 'Required Amenities',
      'type': 'multiselect',
      'hint': 'Specify amenities, e.g., Parking, Air Conditioning, Kitchen'
    },
    {
      'fieldName': 'setupTime',
      'label': 'Setup Time Required',
      'type': 'select',
      'hint': 'Specify setup time, e.g., 1 hour before, 2 hours before'
    },
  ],
  'Transport': [
    {
      'fieldName': 'vehicleType',
      'label': 'Type of Vehicle',
      'type': 'select',
      'hint': 'E.g., Sedan, Van, Bus'
    },
    {
      'fieldName': 'range',
      'label': 'Service Range',
      'type': 'text',
      'hint': 'Service area or distance covered'
    },
    {
      'fieldName': 'capacity',
      'label': 'Capacity',
      'type': 'number',
      'hint': 'Maximum number of passengers'
    },
    {
      'fieldName': 'addOns',
      'label': 'Additional Services',
      'type': 'multiselect',
      'hint': 'Additional services available'
    },
    {
      'fieldName': 'specialRequirements',
      'label': 'Special Requirements',
      'type': 'multiselect',
      'hint': 'Specify special requirements, e.g., Child Seats, Wheelchair Access'
    },
  ],
  'Music': [
    {
      'fieldName': 'musicType',
      'label': 'Type of Music',
      'type': 'select',
      'hint': 'Styles of music offered'
    },
    {
      'fieldName': 'duration',
      'label': 'Duration',
      'type': 'number',
      'hint': 'Length of performance'
    },
    {
      'fieldName': 'equipment',
      'label': 'Equipment Included',
      'type': 'multiselect',
      'hint': 'List of equipment provided'
    },
    {
      'fieldName': 'musicType',
      'label': 'Type of Music Service',
      'type': 'select',
      'hint': 'Specify music service, e.g., Live Band, DJ, Solo Performer'
    },
    {
      'fieldName': 'musicGenre',
      'label': 'Music Genre Preferences',
      'type': 'multiselect',
      'hint': 'Specify music genre preferences, e.g., Pop, Rock, Jazz'
    },
    {
      'fieldName': 'equipment',
      'label': 'Equipment Required',
      'type': 'multiselect',
      'hint': 'Specify equipment required, e.g., Sound System, Microphones'
    },
  ],
  'Choreography': [
    {
      'fieldName': 'danceStyle',
      'label': 'Dance Style',
      'type': 'multiselect',
      'hint': 'Types of dance styles taught'
    },
    {
      'fieldName': 'rehearsalDuration',
      'label': 'Rehearsal Duration',
      'type': 'number',
      'hint': 'Length of rehearsal sessions'
    },
    {
      'fieldName': 'numberOfDancers',
      'label': 'Number of Dancers',
      'type': 'number',
      'hint': 'Number of dancers included'
    },
    {
      'fieldName': 'danceStyle',
      'label': 'Dance Style',
      'type': 'multiselect',
      'hint': 'Specify dance style, e.g., Contemporary, Traditional, Ballet'
    },
  ],
  'MC': [
    {
      'fieldName': 'eventTypes',
      'label': 'Event Types',
      'type': 'select',
      'hint': 'Types of events covered'
    },
    {
      'fieldName': 'duration',
      'label': 'Duration',
      'type': 'number',
      'hint': 'Length of service'
    },
    {
      'fieldName': 'languages',
      'label': 'Languages',
      'type': 'multiselect',
      'hint': 'Languages spoken,'
    },
    {
      'fieldName': 'experience',
      'label': 'Years of Experience',
      'type': 'number',
      'hint': 'Years of experience in the field'
    },
    {
      'fieldName': 'eventType',
      'label': 'Type of Event',
      'type': 'select',
      'hint': 'Specify event type, e.g., Wedding, Corporate Event, Award Ceremony'
    },
    {
      'fieldName': 'languagePreference',
      'label': 'Language Preference',
      'type': 'multiselect',
      'hint': 'Specify language preferences, e.g., English, Afrikaans, Zulu'
    },
  ],
  'Beauty': [
    {
      'fieldName': 'makeupTypes',
      'label': 'Types of Makeup',
      'type': 'multiselect',
      'hint': 'Types of makeup services offered'
    },
    {
      'fieldName': 'products',
      'label': 'Products Used',
      'type': 'text',
      'hint': 'Products and brands used'
    },
    {
      'fieldName': 'trialSessions',
      'label': 'Trial Sessions',
      'type': 'text',
      'hint': 'Trial session availability and details'
    },
    {
      'fieldName': 'serviceType',
      'label': 'Type of Beauty Service',
      'type': 'multiselect',
      'hint': 'Specify beauty services, e.g., Makeup, Hair, Nails'
    },
    {
      'fieldName': 'style',
      'label': 'Style Preference',
      'type': 'select',
      'hint': 'Specify style preferences, e.g., Natural, Glamour, Bridal'
    },
    {
      'fieldName': 'location',
      'label': 'Service Location',
      'type': 'select',
      'hint': 'Specify service location, e.g., At Venue, At Salon, At Home'
    },
  ],
  'Decor': [
    {
      'fieldName': 'decorStyle',
      'label': 'Decoration Style',
      'type': 'select',
      'hint': 'Decoration styles available'
    },
    {
      'fieldName': 'colorSchemes',
      'label': 'Color Schemes',
      'type': 'select',
      'hint': 'Available color schemes'
    },
    {
      'fieldName': 'decorTypes',
      'label': 'Types of Decorations',
      'type': 'multiselect',
      'hint': 'Types of decorations offered'
    },
    {
      'fieldName': 'setupTime',
      'label': 'Setup Time',
      'type': 'number',
      'hint': 'Time required for setup'
    },
    {
      'fieldName': 'decorItems',
      'label': 'Decor Items Required',
      'type': 'multiselect',
      'hint': 'Specify decor items required, e.g., Flowers, Lighting, Furniture'
    },
  ],
  'Event Planning': [
    {
      'fieldName': 'eventTypes',
      'label': 'Event Types',
      'type': 'select',
      'hint': 'Types of events covered e.g., Wedding, Corporate Event, Birthday'
    },
    
    {
      'fieldName': 'teamSize',
      'label': 'Team Size',
      'type': 'number',
      'hint': 'Number of team members'
    },
   
    {
      'fieldName': 'planningServices',
      'label': 'Planning Services Required',
      'type': 'multiselect',
      'hint': 'Specify planning services required, e.g., Full Planning, Vendor Management'
    },
    {
      'fieldName': 'budget',
      'label': 'Budget Range',
      'type': 'select',
      'hint': 'Specify budget range, e.g., Under R10,000, R10,000-R25,000'
    },
  ],
  'Event Security': [
    {
      'fieldName': 'eventTypes',
      'label': 'Event Types',
      'type': 'select',
      'hint': 'Types of events covered'
    },
    {
      'fieldName': 'planningServices',
      'label': 'Planning Services',
      'type': 'multiselect',
      'hint': 'Planning services included'
    },
    {
      'fieldName': 'teamSize',
      'label': 'Team Size',
      'type': 'number',
      'hint': 'Number of team members'
    },
  
    {
      'fieldName': 'securityType',
      'label': 'Type of Security',
      'type': 'select',
      'hint': 'Specify security type, e.g., Armed Security, Unarmed Security, Bodyguards'
    },
    {
      'fieldName': 'budget',
      'label': 'Budget Range',
      'type': 'select',
      'hint': 'Specify budget range, e.g., Under ZAR 5,000, ZAR 5,000-ZAR 10,000'
    },
  ],
  'Gifts': [
    {
      'fieldName': 'giftTypes',
      'label': 'Types of Gifts',
      'type': 'select',
      'hint': 'Types of gifts available'
    },
    {
      'fieldName': 'customization',
      'label': 'Customization Options',
      'type': 'select',
      'hint': 'Available customization options'
    },
    {
      'fieldName': 'delivery',
      'label': 'Delivery Options',
      'type': 'select',
      'hint': 'Describe delivery options and areas'
    },
    {
      'fieldName': 'giftType',
      'label': 'Type of Gift',
      'type': 'select',
      'hint': 'Specify gift type, e.g., Customized, Standard, Corporate'
    },
    {
      'fieldName': 'deliveryOption',
      'label': 'Delivery Option',
      'type': 'select',
      'hint': 'Specify delivery option, e.g., Pick-up, Standard Delivery'
    },
    {
      'fieldName': 'packaging',
      'label': 'Packaging Requirements',
      'type': 'select',
      'hint': 'Specify packaging requirements, e.g., Standard, Premium, Luxury'
    },
  ],
  'Hair Dressing': [
    {
      'fieldName': 'hairServices',
      'label': 'Hair Services',
      'type': 'multiselect',
      'hint': 'Hair services offered'
    },
    {
      'fieldName': 'duration',
      'label': 'Duration',
      'type': 'number',
      'hint': 'Length of service'
    },
    {
      'fieldName': 'products',
      'label': 'Products Used',
      'type': 'text',
      'hint': 'Products and brands used'
    },
    {
      'fieldName': 'style',
      'label': 'Hairstyle Type',
      'type': 'select',
      'hint': 'Specify hairstyle type, e.g., Braids, Weaves, Natural Styling'
    },
    {
      'fieldName': 'location',
      'label': 'Service Location',
      'type': 'select',
      'hint': 'Specify service location, e.g., At Salon, At Home, At Venue'
    },
    {
      'fieldName': 'additionalServices',
      'label': 'Additional Services',
      'type': 'multiselect',
      'hint': 'Specify additional services, e.g., Hair Treatment, Hair Extensions'
    },
  ],
  'Other': [
    {
      'fieldName': 'serviceType',
      'label': 'Type of Service',
      'type': 'text',
      'hint': 'Specify the type of service offered'
    },
    {
      'fieldName': 'customization',
      'label': 'Customization Options',
      'type': 'select',
      'hint': 'Available customization options'
    },
    {
      'fieldName': 'availability',
      'label': 'Availability',
      'type': 'date',
      'hint': 'Specify available dates or periods'
    },
  ],
};
