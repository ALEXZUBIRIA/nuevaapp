import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase inicializado correctamente');
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App Flutter',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/fondo.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'VER-FILM 🎬',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido al catálogo de películas',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Navegar a la pantalla de películas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PeliculasScreen()),
      );
    } catch (e) {
      print('❌ Error al iniciar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text('Entrar')),
          ],
        ),
      ),
    );
  }
}



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Registro exitoso. Ahora puedes iniciar sesión.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error al registrar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text('Registrarse')),
          ],
        ),
      ),
    );
  }
}



class PeliculasScreen extends StatefulWidget {
  const PeliculasScreen({super.key});

  @override
  State<PeliculasScreen> createState() => _PeliculasScreenState();
}

class _PeliculasScreenState extends State<PeliculasScreen> {
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
  return Scaffold(
    appBar: AppBar(
      title: const Text('Películas'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Agregar pelicula',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminScreen()),
            );
          },
        ),
      ],
    ),
    body: peliculas.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              final peli = peliculas[index];
              return ListTile(
                leading: peli['image'] != null
                    ? Image.network(peli['image'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.movie),
                title: Text(peli['title'] ?? 'Sin título'),
                subtitle: Text('Director: ${peli['director'] ?? 'Desconocido'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetallePeliculaScreen(pelicula: peli),
                    ),
                  );
                },
              );
            },
          ),
  );
}

}
class DetallePeliculaScreen extends StatelessWidget {
  final Map pelicula;

  const DetallePeliculaScreen({super.key, required this.pelicula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pelicula['title'] ?? 'Sin título')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pelicula['image'] != null)
              Center( 
                child: Image.network(pelicula['image'], height: 300),
              ),
            const SizedBox(height: 20),
            Text('Título: ${pelicula['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Año: ${pelicula['release_date']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Director: ${pelicula['director']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Género: ${pelicula['producer']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Text('Sinopsis:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(pelicula['description'] ?? 'Sin sinopsis', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _anio = TextEditingController();
  final TextEditingController _director = TextEditingController();
  final TextEditingController _genero = TextEditingController();
  final TextEditingController _sinopsis = TextEditingController();
  final TextEditingController _imagenUrl = TextEditingController();

  Future<void> _agregarPelicula() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('peliculas').add({
        'titulo': _titulo.text,
        'anio': _anio.text,
        'director': _director.text,
        'genero': _genero.text,
        'sinopsis': _sinopsis.text,
        'imagen': _imagenUrl.text,
      });
      _limpiarFormulario();
    }
  }

  Future<void> _eliminarPelicula(String id) async {
    await FirebaseFirestore.instance.collection('peliculas').doc(id).delete();
  }

  void _limpiarFormulario() {
    _titulo.clear();
    _anio.clear();
    _director.clear();
    _genero.clear();
    _sinopsis.clear();
    _imagenUrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar/eliminar Películas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _titulo, decoration: const InputDecoration(labelText: 'Título'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                  TextFormField(controller: _anio, decoration: const InputDecoration(labelText: 'Año'), keyboardType: TextInputType.number),
                  TextFormField(controller: _director, decoration: const InputDecoration(labelText: 'Director')),
                  TextFormField(controller: _genero, decoration: const InputDecoration(labelText: 'Género')),
                  TextFormField(controller: _sinopsis, decoration: const InputDecoration(labelText: 'Sinopsis')),
                  TextFormField(controller: _imagenUrl, decoration: const InputDecoration(labelText: 'URL Imagen')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _agregarPelicula,
                    child: const Text('Agregar Película'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Películas existentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Lista de películas
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('peliculas').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final peli = docs[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(peli['imagen'], width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(peli['titulo']),
                        subtitle: Text('${peli['director']} - ${peli['anio']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarPelicula(peli.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
