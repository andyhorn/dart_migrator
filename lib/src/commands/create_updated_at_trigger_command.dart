import 'package:dart_migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class CreateUpdatedAtTriggerCommand extends SqlCommand {
  const CreateUpdatedAtTriggerCommand(this.tableName);

  final String tableName;

  @override
  Object? get parameters => {
        'tableName': tableName,
        'triggerName': '${tableName}_updated_at_trigger',
      };

  @override
  Sql get sql => Sql('''
CREATE OR REPLACE TRIGGER @triggerName
    BEFORE UPDATE
    ON
        @tableName
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at();
''');
}
