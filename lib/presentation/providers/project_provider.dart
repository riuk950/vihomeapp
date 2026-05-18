import 'package:flutter/material.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/project/get_projects_usecase.dart';

class ProjectProvider extends ChangeNotifier {
  final GetProjectsUseCase getProjectsUseCase;

  ProjectProvider({required this.getProjectsUseCase});

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedFilter; // null = Todos

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedFilter => _selectedFilter;

  List<Project> get filteredProjects {
    if (_selectedFilter == null) return _projects;
    final normalizedFilter = _normalize(_selectedFilter!);
    return _projects
        .where((p) => _normalize(p.estado) == normalizedFilter)
        .toList();
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await getProjectsUseCase.call();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFilter(String? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
