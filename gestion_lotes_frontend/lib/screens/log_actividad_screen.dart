import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/login_decorative_background.dart';
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

class _LogActividadScreenState extends State<LogActividadScreen> {
  List<LogActividad> logs = [];
  List<LogActividad> filteredLogs = [];
  bool isLoading = true;
  String searchQuery = '';
  String currentSort = 'none';

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  void _sortLogs(String sortType) {
    setState(() {
      currentSort = sortType;
      switch (sortType) {
        case 'recent':
          filteredLogs.sort((a, b) => b.fecha.compareTo(a.fecha));
          break;
        case 'oldest':
          filteredLogs.sort((a, b) => a.fecha.compareTo(b.fecha));
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Historial de Acciones',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.blue.shade600),
      ),
      body: Stack(
        children: [
          DecorativeBackgroundLogin(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Buscar por Usuario o Acción',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.blue,),
                      suffixIcon: PopupMenuButton<String>(
                        color: Colors.blue.shade50,
                        icon: Icon(
                          Icons.filter_list,
                          color: currentSort != 'none' ? Colors.blue : Colors.grey,
                        ),
                        onSelected: _sortLogs,
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'recent',
                            child: Row(
                              children: [
                                Icon(Icons.arrow_upward, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Más reciente'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'oldest',
                            child: Row(
                              children: [
                                Icon(Icons.arrow_downward, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Más antiguo'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'none',
                            child: Row(
                              children: [
                                Icon(Icons.clear_all, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Sin filtro'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _filterLogs,
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredLogs.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay logs que coincidan\ncon la búsqueda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      return LogActividadItem(
                        log: filteredLogs[index],
                        formatearFecha: formatearFecha,
                      );
                    },
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