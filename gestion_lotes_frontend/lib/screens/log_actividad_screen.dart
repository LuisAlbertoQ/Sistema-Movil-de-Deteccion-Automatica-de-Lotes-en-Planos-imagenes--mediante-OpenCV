import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/login_decorative_background.dart';
import 'package:gestion_lotes_frontend/core/utils/time_utils.dart';
import 'package:gestion_lotes_frontend/models/log_actividad_model.dart';
import 'package:intl/intl.dart';
import '../services/log_actividad_service.dart';
import '../components/log_actividad_item.dart';

class LogActividadScreen extends StatefulWidget {
  final String token;

  const LogActividadScreen({Key? key, required this.token}) : super(key: key);

  @override
  _LogActividadScreenState createState() => _LogActividadScreenState();
}

class _LogActividadScreenState extends State<LogActividadScreen>
    with TickerProviderStateMixin {
  List<LogActividad> logs = [];
  List<LogActividad> filteredLogs = [];
  bool isLoading = true;
  String searchQuery = '';
  String currentSort = 'none';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    fetchLogs();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _sortLogs(String sortType) {
    setState(() {
      currentSort = sortType;
      switch (sortType) {
        case 'recent':
          filteredLogs.sort((a, b) =>
              TimeUtils.parseFromApi(b.fecha).compareTo(TimeUtils.parseFromApi(a.fecha)));
          break;
        case 'oldest':
          filteredLogs.sort((a, b) =>
              TimeUtils.parseFromApi(a.fecha).compareTo(TimeUtils.parseFromApi(b.fecha)));
          break;
        default:
          filteredLogs = List.from(logs.where((log) {
            final usuarioId = log.usuario.toString().toLowerCase();
            final accion = log.accion.toLowerCase();
            return usuarioId.contains(searchQuery) ||
                accion.contains(searchQuery);
          }));
      }
    });
  }

  String formatearFecha(String fechaISO) {
    try {
      final DateTime fecha = DateTime.parse(fechaISO);
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  Future<void> fetchLogs() async {
    try {
      final fetchedLogs = await LogActividadService.fetchLogs(widget.token);
      setState(() {
        logs = fetchedLogs;
        filteredLogs = logs;
        isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text('Error de conexión: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _filterLogs(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredLogs = logs.where((log) {
        final usuarioId = log.usuario.toString().toLowerCase();
        final accion = log.accion.toLowerCase();
        return usuarioId.contains(searchQuery) ||
            accion.contains(searchQuery);
      }).toList();
      if (currentSort != 'none') {
        _sortLogs(currentSort);
      }
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        cursorColor: Colors.blue.shade600,
        decoration: InputDecoration(
          labelText: 'Buscar por Usuario o Acción',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          hintText: 'Ingresa tu búsqueda...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              color: Colors.blue.shade600,
              size: 22,
            ),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: currentSort != 'none'
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: Icon(
                Icons.tune,
                color: currentSort != 'none' ? Colors.blue.shade600 : Colors.grey.shade500,
                size: 22,
              ),
              onSelected: _sortLogs,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'recent',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.arrow_upward, size: 16, color: Colors.blue.shade600),
                      ),
                      const SizedBox(width: 12),
                      const Text('Más reciente'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'oldest',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.arrow_downward, size: 16, color: Colors.blue.shade600),
                      ),
                      const SizedBox(width: 12),
                      const Text('Más antiguo'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'none',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.clear_all, size: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      const Text('Sin filtro'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: _filterLogs,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total de Actividades',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${filteredLogs.length}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (currentSort != 'none')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentSort == 'recent' ? 'Recientes' : 'Antiguos',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              searchQuery.isEmpty ? Icons.history_outlined : Icons.search_off,
              size: 64,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty
                ? 'No hay actividades registradas'
                : 'No hay logs que coincidan\ncon la búsqueda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Las actividades aparecerán aquí cuando se realicen'
                : 'Intenta con otros términos de búsqueda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Historial de Acciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.blue.shade600),
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue.shade600),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                fetchLogs();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          DecorativeBackgroundLogin(),
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                if (!isLoading && filteredLogs.isNotEmpty) _buildStatsCard(),
                Expanded(
                  child: isLoading
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando historial...',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                      : filteredLogs.isEmpty
                      ? _buildEmptyState()
                      : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 100 + (index * 50)),
                          curve: Curves.easeOutBack,
                          child: LogActividadItem(
                            log: filteredLogs[index],

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
    );
  }
}