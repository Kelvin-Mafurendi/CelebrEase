import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 10,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: const Color(0xFFECD5C4),
        type: MaterialType.card,
        surfaceTintColor: Colors.black,
        shadowColor: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/img/emb.jpg'),
                    radius: 75,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Kevido's",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '"All your event needs and more!"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Location: ', 'Port Elizabeth, EC'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Email: ', 'kevido@example.com'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Mobile: ', '+27 (61) 123-4567'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}