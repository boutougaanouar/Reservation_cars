import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({Key? key}) : super(key: key);

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  // Fonction pour récupérer les réservations
  Future<void> fetchReservations() async {
    final url = Uri.parse('http://localhost/projectflutter/api.php?reservations=true');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decode JSON response
        if (data['success'] == true) {
          setState(() {
            _reservations = data['reservations'];  // Accès à la liste des réservations
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Erreur inconnue');
        }
      } else {
        throw Exception('Erreur de connexion au serveur');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mes Réservations',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune réservation',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    final date = DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(reservation['date_reservation']));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: Image.network(
                              reservation['voiture_image'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey[400]),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      reservation['voiture_nom'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        date,
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(Icons.person,
                                    '${reservation['nom']} ${reservation['prenom']}'),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                    Icons.phone, reservation['numero']),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                    Icons.email, reservation['email']),
                                const SizedBox(height: 16),
                                Text(
                                  'Prix: ${reservation['voiture_prix']}DH/jour',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
