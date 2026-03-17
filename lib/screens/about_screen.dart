// ============================================================
// Screen: About App
// Shows app info, team credits, and version details
// ============================================================

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About PasabayBCD',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // App logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A56DB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.local_shipping, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'PasabayBCD',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SME Logistics Hub for Bacolod City',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 32),

            // About section
            _buildInfoCard(
              title: 'About the App',
              content:
                  'PasabayBCD connects small and medium enterprises (SMEs) in Bacolod City '
                  'with available truck drivers for affordable cargo delivery. Instead of '
                  'hiring a full truck, merchants can share space on trucks already heading '
                  'in their direction — saving money and reducing empty trips.',
            ),
            const SizedBox(height: 16),

            // Team section
            _buildInfoCard(
              title: 'Development Team',
              child: Column(
                children: [
                  _buildTeamMember('Project Lead', 'BSIT 3-B Student'),
                  const Divider(height: 20),
                  _buildTeamMember('UI/UX Design', 'BSIT 3-B Student'),
                  const Divider(height: 20),
                  _buildTeamMember('Backend Developer', 'BSIT 3-B Student'),
                  const Divider(height: 20),
                  _buildTeamMember('Mobile Developer', 'BSIT 3-B Student'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tech stack section
            _buildInfoCard(
              title: 'Built With',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTechChip('Flutter'),
                  _buildTechChip('Dart'),
                  _buildTechChip('PHP'),
                  _buildTechChip('MySQL'),
                  _buildTechChip('OpenStreetMap'),
                  _buildTechChip('OSRM'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Academic info
            _buildInfoCard(
              title: 'Academic Project',
              content:
                  'This application was developed as a capstone/thesis project for '
                  'BSIT 3-B. It demonstrates the use of mobile development, REST APIs, '
                  'real-time map tracking, and digital wallet features in solving '
                  'local logistics challenges.',
            ),
            const SizedBox(height: 32),

            // Footer
            Text(
              '2026 PasabayBCD. All rights reserved.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 4),
            Text(
              'BSIT 3-B · Bacolod City',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Reusable card with a title and either text content or a custom child widget
  Widget _buildInfoCard({required String title, String? content, Widget? child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  // Single team member row
  Widget _buildTeamMember(String role, String section) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFEBF2FF),
          child: Icon(Icons.person_outline, size: 20, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              section,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  // Small technology badge chip
  Widget _buildTechChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A56DB),
        ),
      ),
    );
  }
}
