import 'package:dart_migrator/src/commands/commands.dart';
import 'package:postgres/postgres.dart';

final class GetPublicTablesCommand extends SqlCommand {
  const GetPublicTablesCommand({this.omit});

  final List<String>? omit;

  @override
  Object? get parameters {
    if (omit != null && omit!.isNotEmpty) {
      return {
        'tableNames': TypedValue(
          Type.text,
          omit!.join(','),
        ),
      };
    }

    return null;
  }

  @override
  Sql get sql {
    const query = '''
SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'public'
''';

    if (omit != null && omit!.isNotEmpty) {
      return Sql.named('$query AND table_name NOT IN (@tableNames);');
    }

    return Sql.named('$query;');
  }
}
