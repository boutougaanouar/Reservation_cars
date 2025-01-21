import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class ReservationPage extends StatelessWidget {
  final Map voiture;
  const ReservationPage({Key? key, required this.voiture}) : super(key: key);

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
          'Réserver ${voiture['nom']}',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(voiture['image_url']),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
              child: ReservationForm(voiture: voiture),
            ),
          ],
        ),
      ),
    );
  }
}

class ReservationForm extends StatefulWidget {
  final Map voiture;
  const ReservationForm({Key? key, required this.voiture}) : super(key: key);

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> envoyerReservation() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://localhost/projectflutter/api.php');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": _nomController.text,
          "prenom": _prenomController.text,
          "numero": _numeroController.text,
          "email": _emailController.text,
          "voiture_id": widget.voiture['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'], style: const TextStyle(color: Colors.green))),
          );
          _formKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'], style: const TextStyle(color: Colors.red))),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la communication avec le serveur.")),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Informations personnelles',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nomController,
            decoration: _inputDecoration('Nom', Icons.person),
            validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prenomController,
            decoration: _inputDecoration('Prénom', Icons.person_outline),
            validator: (value) => value!.isEmpty ? 'Veuillez entrer un prénom' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _numeroController,
            decoration: _inputDecoration('Téléphone', Icons.phone),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Veuillez entrer un numéro' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration('Email', Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? 'Veuillez entrer un email' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: envoyerReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Confirmer la réservation',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Prix: ${widget.voiture['prix_par_jour']}DH/jour',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
