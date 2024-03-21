import 'package:dart_migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class GetLatestSchemaIdCommand extends SqlCommand {
  const GetLatestSchemaIdCommand(this._schemaTableName);
  final String _schemaTableName;

  @override
  Object? get parameters => null;

  @override
  Sql get sql => Sql(
        'SELECT id FROM $_schemaTableName ORDER BY id DESC LIMIT 1',
      );
}
