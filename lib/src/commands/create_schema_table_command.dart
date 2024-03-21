import 'package:migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class CreateSchemaTableCommand extends SqlCommand {
  const CreateSchemaTableCommand();

  @override
  Sql get sql => Sql('''
CREATE TABLE __schema (
  id SERIAL PRIMARY KEY, 
  name TEXT NOT NULL, 
  completed_at TIMESTAMP NOT NULL DEFAULT NOW()
);''');

  @override
  Object? get parameters => null;
}
