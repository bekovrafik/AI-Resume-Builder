import 'package:isar_community/isar.dart';

part 'user_model.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid; // Firebase UID

  late String email;

  String? name;

  bool isPremium = false;
}
