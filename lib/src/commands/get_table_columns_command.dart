import 'package:dart_migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class GetTableColumnsCommand extends SqlCommand {
  const GetTableColumnsCommand(this.tableName);
  final String tableName;

  @override
  Object? get parameters => {
        'tableName': TypedValue(Type.text, tableName),
      };

  @override
  Sql get sql => Sql.named('''
SELECT column_name 
  FROM information_schema.columns 
    WHERE table_name = @tableName;
''');
}
