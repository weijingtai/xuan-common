import 'package:equatable/equatable.dart';

/// Represents an AI Persona (virtual character) independent of the database implementation.
class AiPersona extends Equatable {
  final String uuid;
  final String name;
  final String? description;

  const AiPersona({
    required this.uuid,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [uuid, name, description];
}
