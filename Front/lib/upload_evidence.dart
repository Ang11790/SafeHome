import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

enum EvidenceStepType {
  photo,
  image,
  file,
  note,
}

enum EvidenceStepStatus {
  pending,
  uploaded,
  skipped,
}

class UploadEvidenceScreen extends StatefulWidget {
  const UploadEvidenceScreen({Key? key}) : super(key: key);

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  final List<EvidenceStepType> _steps = const <EvidenceStepType>[
    EvidenceStepType.photo,
    EvidenceStepType.image,
    EvidenceStepType.file,
    EvidenceStepType.note,
  ];

  late final Map<EvidenceStepType, EvidenceStepStatus> _stepStatus;
  String? _photoName;
  String? _imageName;
  String? _fileName;
  final TextEditingController _noteController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _stepStatus = <EvidenceStepType, EvidenceStepStatus>{
      for (final step in _steps) step: EvidenceStepStatus.pending,
    };
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _stepTitle(EvidenceStepType step) {
    switch (step) {
      case EvidenceStepType.photo:
        return 'Foto';
      case EvidenceStepType.image:
        return 'Imagen';
      case EvidenceStepType.file:
        return 'Archivo';
      case EvidenceStepType.note:
        return 'Nota';
    }
  }

  IconData _stepIcon(EvidenceStepType step) {
    switch (step) {
      case EvidenceStepType.photo:
        return Icons.photo_camera;
      case EvidenceStepType.image:
        return Icons.image;
      case EvidenceStepType.file:
        return Icons.attach_file;
      case EvidenceStepType.note:
        return Icons.edit_note;
    }
  }

  String _statusLabel(EvidenceStepStatus status) {
    switch (status) {
      case EvidenceStepStatus.pending:
        return 'Pendiente';
      case EvidenceStepStatus.uploaded:
        return 'Cargada';
      case EvidenceStepStatus.skipped:
        return 'Omitida';
    }
  }

  Color _statusColor(EvidenceStepStatus status) {
    switch (status) {
      case EvidenceStepStatus.pending:
        return Colors.orange;
      case EvidenceStepStatus.uploaded:
        return Colors.green;
      case EvidenceStepStatus.skipped:
        return Colors.blueGrey;
    }
  }

  Future<void> _pickImage(EvidenceStepType step) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final String name = result.files.single.name;
    setState(() {
      if (step == EvidenceStepType.photo) {
        _photoName = name;
      } else {
        _imageName = name;
      }
      _stepStatus[step] = EvidenceStepStatus.uploaded;
    });
  }

  Future<void> _pickGenericFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _fileName = result.files.single.name;
      _stepStatus[EvidenceStepType.file] = EvidenceStepStatus.uploaded;
    });
  }

  void _markSkipped(EvidenceStepType step) {
    setState(() {
      if (step == EvidenceStepType.note) {
        _noteController.clear();
      }
      _stepStatus[step] = EvidenceStepStatus.skipped;
    });
    _goNext();
  }

  void _goNext() {
    if (_currentIndex >= _steps.length - 1) return;
    setState(() {
      _currentIndex += 1;
    });
  }

  void _goBack() {
    if (_currentIndex == 0) return;
    setState(() {
      _currentIndex -= 1;
    });
  }

  Future<void> _saveFromNotes() async {
    final String note = _noteController.text.trim();
    if (note.isNotEmpty) {
      _stepStatus[EvidenceStepType.note] = EvidenceStepStatus.uploaded;
    } else if (_stepStatus[EvidenceStepType.note] == EvidenceStepStatus.pending) {
      _stepStatus[EvidenceStepType.note] = EvidenceStepStatus.skipped;
    }

    final int uploadedCount = _stepStatus.values
        .where((status) => status == EvidenceStepStatus.uploaded)
        .length;

    if (uploadedCount == 0) {
      final bool? exitWithoutSaving = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No hay evidencias'),
          content: const Text(
            'No subiste ninguna evidencia. ¿Deseas salir sin guardar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Quedarme'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salir'),
            ),
          ],
        ),
      );

      if (exitWithoutSaving == true && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    final bool? saveEvidence = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar evidencia'),
        content: Text(
          'Se detectaron $uploadedCount evidencia(s). ¿Deseas guardar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (saveEvidence == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia guardada correctamente.')),
      );
      Navigator.pop(context);
    }
  }

  int _uploadedCount() {
    return _stepStatus.values.where((status) => status == EvidenceStepStatus.uploaded).length;
  }

  Widget _buildEvidenceSummaryCard() {
    final int uploadedCount = _uploadedCount();
    final bool hasEvidence = uploadedCount > 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasEvidence ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasEvidence ? Colors.green.withValues(alpha: 0.4) : Colors.orange.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(hasEvidence ? Icons.verified : Icons.info_outline),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasEvidence
                  ? 'Has registrado $uploadedCount evidencia(s) hasta ahora.'
                  : 'Aun no has registrado evidencias.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(EvidenceStepType step) {
    final EvidenceStepStatus status = _stepStatus[step] ?? EvidenceStepStatus.pending;
    final bool isNote = step == EvidenceStepType.note;
    final bool isFirst = _currentIndex == 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_stepIcon(step), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_currentIndex + 1}. ${_stepTitle(step)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(_statusLabel(status)),
                  backgroundColor: _statusColor(status).withValues(alpha: 0.15),
                  side: BorderSide(color: _statusColor(status)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isNote) ...[
              Text(
                step == EvidenceStepType.photo
                    ? (_photoName ?? 'Aun no has seleccionado una foto.')
                    : step == EvidenceStepType.image
                        ? (_imageName ?? 'Aun no has seleccionado una imagen.')
                        : (_fileName ?? 'Aun no has seleccionado un archivo.'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (step == EvidenceStepType.file) {
                          _pickGenericFile();
                          return;
                        }
                        _pickImage(step);
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        step == EvidenceStepType.file ? 'Seleccionar archivo' : 'Seleccionar imagen',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ] else ...[
              const Text('Escribe una nota como evidencia (opcional):'),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe lo sucedido, fecha, lugar, etc.',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _stepStatus[EvidenceStepType.note] =
                        value.trim().isNotEmpty ? EvidenceStepStatus.uploaded : EvidenceStepStatus.pending;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],
            const Divider(height: 24),
            Row(
              children: [
                if (!isFirst)
                  OutlinedButton.icon(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                if (!isFirst) const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _markSkipped(step),
                  child: const Text('Skip'),
                ),
                const Spacer(),
                if (!isNote)
                  ElevatedButton.icon(
                    onPressed: _goNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _saveFromNotes,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar evidencia'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EvidenceStepType currentStep = _steps[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Subir evidencias')),
      body: Column(
        children: [
          _buildEvidenceSummaryCard(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _steps.length,
            ),
          ),
          Expanded(child: _buildStepCard(currentStep)),
        ],
      ),
    );
  }
}
