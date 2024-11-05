import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maroro/pages/vendor_calender.dart';

class VendorProjectManagement extends StatefulWidget {
  const VendorProjectManagement({super.key});

  @override
  State<VendorProjectManagement> createState() =>
      _VendorProjectManagementState();
}

class _VendorProjectManagementState extends State<VendorProjectManagement> {
  int _selectedIndex = 0;
  late Widget page = _dashBoard();
  Widget _changePage(int index) {
    switch (index) {
      case 0:
        {
          return _dashBoard();
        }

      case 1:
        {
          return Center(child: Text('Events',textScaler: TextScaler.linear(5),));
        }
      case 2:
        {
          return SizedBox(
            height: 900, // Adjust this height based on your needs
            child: Center(child: Text('Calendar',textScaler: TextScaler.linear(4))),
          );
        }

      case 3:
        {
          return Text('Tasks',textScaler: TextScaler.linear(5));
        }
      case 4:
        {
          return Text('Team',textScaler: TextScaler.linear(5));
        }
      case 5:
        {
          return Text('Analytics',textScaler: TextScaler.linear(5));
        }
      case 6:
        {
          return Text('Notifications',textScaler: TextScaler.linear(5));
        }

      default:
        return Text('data',textScaler: TextScaler.linear(5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Left Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                page = _changePage(index);
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event),
                label: Text('Events'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text('Calender'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.task_outlined),
                selectedIcon: Icon(Icons.task),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Team'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
            ],
          ),
          page
        ],
      ),
    );
  }
}

Widget _dashBoard() {
  // Sample data - replace with your actual data
  final List<Map<String, dynamic>> upcomingEvents = [
    {
      'title': 'Johnson Wedding',
      'date': DateTime(2024, 11, 15),
      'status': 'Confirmed',
      'price': 2500.00,
      'location': 'Grand Plaza Hotel',
      'tasks': 8,
      'completedTasks': 3,
    },
    {
      'title': 'Tech Corp Conference',
      'date': DateTime(2024, 11, 20),
      'status': 'Pending',
      'price': 5000.00,
      'location': 'Convention Center',
      'tasks': 12,
      'completedTasks': 5,
    },
  ];

  Widget buildStatCard(
      String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 220, // Fixed width for each stat card
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventDetail(IconData icon, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.lateef(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            //overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  return

      // Main Content
      Expanded(
    child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SizedBox(height: 50),
          Row(
            children: [
              const Text(
                'Project Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 32),

          // Stats Cards
          SizedBox(
            height: 100, // Fixed height for stats cards
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                buildStatCard(
                  'Active Events',
                  '12',
                  Icons.event,
                  Colors.blue,
                ),
                const SizedBox(width: 10),
                buildStatCard(
                  'Pending Tasks',
                  '28',
                  Icons.task,
                  Colors.orange,
                ),
                const SizedBox(width: 10),
                buildStatCard(
                  'This Month',
                  '\$15,750',
                  Icons.attach_money,
                  Colors.green,
                ),
                const SizedBox(width: 10),
                buildStatCard(
                  'Team Members',
                  '8',
                  Icons.people,
                  Colors.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Upcoming Events
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                final event = upcomingEvents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(event['date']),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(event['status']),
                              backgroundColor: event['status'] == 'Confirmed'
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              labelStyle: TextStyle(
                                color: event['status'] == 'Confirmed'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: buildEventDetail(
                                Icons.location_on_outlined,
                                event['location'],
                              ),
                            ),
                            Expanded(
                              child: buildEventDetail(
                                Icons.attach_money,
                                '\$${event['price']}',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tasks Progress (${event['completedTasks']}/${event['tasks']})',
                                    style: GoogleFonts.lateef(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: event['completedTasks'] /
                                        event['tasks'],
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue[400]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
            ),
          ),
        ],
      ),
    ),
  );
}
