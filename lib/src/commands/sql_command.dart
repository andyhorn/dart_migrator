import 'package:postgres/postgres.dart';

abstract class SqlCommand {
  const SqlCommand();

  Sql get sql;
  Object? get parameters;
}
