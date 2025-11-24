import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/movie_view_model.dart';
import '../widgets/movie_card.dart';
import 'movie_form_screen.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  void _showGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Grupo'),
        content: const Text('Integrantes do grupo:\n• John Victor de Sousa Medeiros\n• Carlos Rafael dos Santos Sales\n• Sérgio Bezerra Viana  '),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _openActions(BuildContext context, String movieId) async {
    final viewModel = context.read<MovieViewModel>();
    final movie = viewModel.getById(movieId);
    if (movie == null) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Exibir dados'),
                onTap: () => Navigator.of(context).pop('details'),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Alterar'),
                onTap: () => Navigator.of(context).pop('edit'),
              ),
            ],
          ),
        );
      },
    );

    if (selected == 'details') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movieId: movieId),
        ),
      );
    } else if (selected == 'edit') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MovieFormScreen(
            existingMovie: movie,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieViewModel>();
    final movies = viewModel.movies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => _showGroupDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar por título ou gênero...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: viewModel.setSearchQuery,
            ),
          ),
          Expanded(
            child: movies.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum filme cadastrado ainda.\nToque em + para adicionar.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return Dismissible(
                        key: ValueKey(movie.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Excluir filme'),
                                  content: Text(
                                      'Deseja realmente excluir "${movie.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Excluir',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (_) {
                          viewModel.deleteMovie(movie.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Filme "${movie.title}" deletado.'),
                            ),
                          );
                        },
                        child: MovieCard(
                          movie: movie,
                          onTap: () => _openActions(context, movie.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MovieFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo filme'),
      ),
    );
  }
}
