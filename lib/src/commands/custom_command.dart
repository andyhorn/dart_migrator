import 'package:dart_migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class CustomCommand extends SqlCommand {
  const CustomCommand(this._sql);
  final String _sql;

  @override
  Object? get parameters => null;

  @override
  Sql get sql => Sql(_sql);
}
