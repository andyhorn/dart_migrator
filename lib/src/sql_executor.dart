import 'package:dart_migrator/src/commands/sql_command.dart';
import 'package:postgres/postgres.dart';

sealed class SqlExecutor {
  const SqlExecutor._({
    required this.connection,
    required this.session,
  });

  factory SqlExecutor.fromConnection(Connection connection) {
    return ConnectionExecutor._(connection);
  }

  factory SqlExecutor.fromSession(TxSession session) {
    return SessionExecutor._(session);
  }

  final Connection? connection;
  final TxSession? session;

  Future<Result> execute(SqlCommand command) async {
    if (connection != null) {
      return connection!.execute(command.sql, parameters: command.parameters);
    } else if (session != null) {
      return session!.execute(command.sql, parameters: command.parameters);
    } else {
      throw Exception('No connection or session available');
    }
  }
}

final class ConnectionExecutor extends SqlExecutor {
  const ConnectionExecutor._(Connection connection)
      : super._(connection: connection, session: null);
}

final class SessionExecutor extends SqlExecutor {
  const SessionExecutor._(TxSession session)
      : super._(connection: null, session: session);
}
