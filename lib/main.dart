import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List peliculas = [];

  Future<void> obtenerPeliculas() async {
    final respuesta = await http.get(Uri.parse('https://ghibliapi.vercel.app/films'));

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);
      setState(() {
        peliculas = datos;
      });
    } else {
      setState(() {
        peliculas = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerPeliculas();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Flutter',
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo
            Image.asset(
              'assets/fondo.jpg',
              fit: BoxFit.cover,
            ),
            // Contenido
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Mi App Flutter',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bienvenido a la aplicación.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: peliculas.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: peliculas.length,
                              itemBuilder: (context, index) {
                                final peli = peliculas[index];
                                return Card(
                                  color: Colors.white.withOpacity(0.8),
                                  child: ListTile(
                                    title: Text(peli['title']),
                                    subtitle: Text(
                                        'Director: ${peli['director']} - Año: ${peli['release_date']}'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
