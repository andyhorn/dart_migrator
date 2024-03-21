import 'package:migrator/src/commands/sql_command.dart';
import 'package:postgres/postgres.dart';

final class CheckSchemaTableExistsCommand extends SqlCommand {
  const CheckSchemaTableExistsCommand(this.tableName);

  final String tableName;

  @override
  Sql get sql => Sql.named('''
SELECT EXISTS (
  SELECT 1 FROM information_schema.tables 
    WHERE table_name = @tableName
  ) 
  AS exists;
''');

  @override
  Object? get parameters => {
        'tableName': TypedValue(Type.text, tableName),
      };
}
