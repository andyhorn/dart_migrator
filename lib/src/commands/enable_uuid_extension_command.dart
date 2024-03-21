import 'package:migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class EnableUuidExtensionCommand extends SqlCommand {
  const EnableUuidExtensionCommand();

  @override
  Object? get parameters => null;

  @override
  Sql get sql => Sql('''
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
''');
}
