import 'package:migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class GetPublicTablesCommand extends SqlCommand {
  const GetPublicTablesCommand(this.schemaTableName);

  final String schemaTableName;

  @override
  Object? get parameters => {
        'schemaName': TypedValue(Type.text, 'public'),
        'schemaTableName': TypedValue(Type.text, schemaTableName),
      };

  @override
  Sql get sql => Sql.named('''
SELECT table_name 
  FROM information_schema.tables 
    WHERE table_schema = @schemaName 
    AND table_name != @schemaTableName;
''');
}
