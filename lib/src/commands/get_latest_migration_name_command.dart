import 'package:dart_migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class GetLatestMigrationNameCommand extends SqlCommand {
  const GetLatestMigrationNameCommand(this._schemaTableName);
  final String _schemaTableName;

  @override
  Object? get parameters => null;

  @override
  Sql get sql => Sql(
        'SELECT name FROM $_schemaTableName ORDER BY id DESC LIMIT 1',
      );
}
