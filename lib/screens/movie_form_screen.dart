import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../models/movie.dart';
import '../viewmodels/movie_view_model.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? existingMovie;

  const MovieFormScreen({super.key, this.existingMovie});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();

  String? _ageRating;
  double _score = 0;

  @override
  void initState() {
    super.initState();
    final movie = widget.existingMovie;
    if (movie != null) {
      _imageUrlController.text = movie.imageUrl;
      _titleController.text = movie.title;
      _genreController.text = movie.genre;
      _durationController.text = movie.durationMinutes.toString();
      _descriptionController.text = movie.description;
      _yearController.text = movie.year.toString();
      _ageRating = movie.ageRating;
      _score = movie.score;
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ageRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a faixa etária.')),
      );
      return;
    }

    final viewModel = context.read<MovieViewModel>();

    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final year = int.tryParse(_yearController.text.trim()) ?? 0;

    if (_score < 0 || _score > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A pontuação deve ser entre 0 e 5.')),
      );
      return;
    }

    if (widget.existingMovie == null) {
      final newMovie = Movie(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: _imageUrlController.text.trim(),
        title: _titleController.text.trim(),
        genre: _genreController.text.trim(),
        ageRating: _ageRating!,
        durationMinutes: duration,
        score: _score,
        description: _descriptionController.text.trim(),
        year: year,
      );
      await viewModel.addMovie(newMovie);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme cadastrado com sucesso!')),
      );
    } else {
      final movie = widget.existingMovie!;
      movie.imageUrl = _imageUrlController.text.trim();
      movie.title = _titleController.text.trim();
      movie.genre = _genreController.text.trim();
      movie.ageRating = _ageRating!;
      movie.durationMinutes = duration;
      movie.score = _score;
      movie.description = _descriptionController.text.trim();
      movie.year = year;
      await viewModel.updateMovie(movie);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme alterado com sucesso!')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMovie != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Alterar filme' : 'Cadastrar filme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dados do filme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o título.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL da imagem',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a URL da imagem.';
                      }
                      if (!value.startsWith('http')) {
                        return 'Informe uma URL válida.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(
                      labelText: 'Gênero',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o gênero.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Faixa etária',
                            border: OutlineInputBorder(),
                          ),
                          value: _ageRating,
                          items: const [
                            'Livre',
                            '10',
                            '12',
                            '14',
                            '16',
                            '18',
                          ].map((age) {
                            return DropdownMenuItem(
                              value: age,
                              child: Text(age),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _ageRating = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duração (min)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a duração.';
                            }
                            final d = int.tryParse(value);
                            if (d == null || d <= 0) {
                              return 'Duração inválida.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o ano.';
                      }
                      final y = int.tryParse(value);
                      if (y == null || y < 1900 || y > DateTime.now().year + 1) {
                        return 'Ano inválido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pontuação (0 a 5)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  SmoothStarRating(
                    allowHalfRating: true,
                    starCount: 5,
                    rating: _score,
                    size: 32,
                    onRatingChanged: (value) {
                      setState(() {
                        _score = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a descrição.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(isEditing ? 'Salvar alterações' : 'Cadastrar'),
                      onPressed: _submit,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
