import 'package:equatable/equatable.dart';

class InvalidEntry extends Equatable {
  final String id;
  final String collection;
  final Map<String, dynamic> rawData;
  final List<String> issues;
  final Map<String, dynamic>? fixedData;

  const InvalidEntry({
    required this.id,
    required this.collection,
    required this.rawData,
    required this.issues,
    this.fixedData,
  });

  @override
  List<Object?> get props => [id, collection, rawData, issues, fixedData];
}
