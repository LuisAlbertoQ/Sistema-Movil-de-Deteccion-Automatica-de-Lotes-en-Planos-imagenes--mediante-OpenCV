import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
    const String baseUrl = "http://192.168.1.46:8000/log-actividad/";
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          logs = (jsonDecode(response.body) as List)
              .map((log) => LogActividad.fromJson(log))
              .toList();
          filteredLogs = logs;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener logs de actividad'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Widget _buildLogItem(LogActividad log) {
    return Card(
      color: Colors.lightBlue.shade50,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historial',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Usuario: ${log.usuario}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.details,
                  'Acción',
                  log.accion,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Fecha',
                  formatearFecha(log.fecha)
                  ,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue), // Changed to blue
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),
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
                          color: Colors.blue, // Changed to blue
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
                      return _buildLogItem(filteredLogs[index]);
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

// Modelo para los datos del log
class LogActividad {
  final String usuario;
  final String accion;
  final String fecha;

  LogActividad({
    required this.usuario,
    required this.accion,
    required this.fecha
  });

  factory LogActividad.fromJson(Map<String, dynamic> json) {
    return LogActividad(
      usuario: json['id_usuario'].toString(),
      accion: json['accion'],
      fecha: json['fecha'],
    );
  }
}