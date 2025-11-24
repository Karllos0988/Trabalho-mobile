import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/movie_repository.dart';
import 'viewmodels/movie_view_model.dart';
import 'screens/movie_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final repository = await createMovieRepository();

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final MovieRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MovieViewModel>(
          create: (_) => MovieViewModel(repository)..loadMovies(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gerenciador de Filmes',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.redAccent,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),
        home: const MovieListScreen(),
      ),
    );
  }
}
