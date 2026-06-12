import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/delivery.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import 'delivery_detail_screen.dart';

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    try {
      final delivery = await widget.controller.createDelivery(
        pickupAddress: _pickupController.text.trim(),
        dropoffAddress: _dropoffController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AppShell(
            child: DeliveryDetailScreen(
              controller: widget.controller,
              deliveryId: delivery.id,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = widget.controller.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nova entrega'),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _pickupController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Endereço de retirada',
                        hintText: 'Rua, número, bairro',
                      ),
                      validator: _addressValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dropoffController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Endereço de entrega',
                        hintText: 'Rua, número, bairro',
                      ),
                      validator: _addressValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descrição do item',
                        hintText: 'Ex.: envelope com documentos',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Descreva o item brevemente.';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.destructive,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const Spacer(),
                    ElevatedButton(
                      onPressed: widget.controller.loading ? null : _submit,
                      child: widget.controller.loading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Criando entrega...'),
                              ],
                            )
                          : const Text('Criar entrega'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String? _addressValidator(String? value) {
  if (value == null || value.trim().length < 5) {
    return 'Informe um endereço completo.';
  }
  return null;
}
