import 'package:migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class CreateUpdatedAtProcedureCommand extends SqlCommand {
  const CreateUpdatedAtProcedureCommand();

  @override
  Object? get parameters => null;

  @override
  Sql get sql => Sql(r'''
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';
''');
}
