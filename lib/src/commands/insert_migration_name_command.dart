import 'package:migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class InsertMigrationNameCommand extends SqlCommand {
  const InsertMigrationNameCommand(this.fileName);
  final String fileName;

  @override
  Object? get parameters => {
        'name': fileName,
      };

  @override
  Sql get sql => Sql.named('INSERT INTO __schema (name) VALUES (@name)');
}
