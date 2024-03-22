import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_migrator/src/commands/commands.dart';
import 'package:dart_migrator/src/sql_executor.dart';
import 'package:postgres/postgres.dart';

class MigrationRunner {
  final Connection _connection;
  const MigrationRunner(this._connection);

  static const _schemaTableName = '__schema';

  Future<void> run() async {
    final schemaTableExists = await _getSchemaTableExists();

    if (!schemaTableExists) {
      final initialized = await _init();

      if (!initialized) {
        print('Failed to initialize database');
        exit(2);
      }
    }

    final migrationFiles = _getMigrationFiles();

    if (migrationFiles.isEmpty) {
      print('No migrations found');
      return;
    }

    final latestMigrationName = await _getLatestMigrationName();
    final upToDate =
        _getMigrationName(migrationFiles.last) == latestMigrationName;

    if (upToDate) {
      print('Database up-to-date');
      return;
    }

    final migrationsToRun = _getMigrationsToRun(
      latestMigrationName: latestMigrationName,
      migrationFiles: migrationFiles,
    );

    print('Found ${migrationsToRun.length} migration(s) to run');

    await _connection.runTx((session) async {
      for (final migration in migrationsToRun) {
        print('Running migration ${_getMigrationName(migration)}');
        await _runMigration(migration, session);
      }

      await _verifyUpdatedAtTimestamps(session);
    });

    print('Migration(s) complete');
    exit(0);
  }

  Future<bool> _init() async {
    return await _connection.runTx((session) async {
      final executor = SqlExecutor.fromSession(session);
      final commands = [
        const CheckSchemaTableExistsCommand(_schemaTableName),
        const CreateSchemaTableCommand(),
        const CreateUpdatedAtProcedureCommand(),
        const EnableUuidExtensionCommand(),
      ];

      for (final command in commands) {
        await executor.execute(command);
      }

      return true;
    });
  }

  Future<bool> _getSchemaTableExists() async {
    final executor = SqlExecutor.fromConnection(_connection);
    final result = await executor.execute(
      const CheckSchemaTableExistsCommand(_schemaTableName),
    );

    return _getExistsResult(result);
  }

  List<File> _getMigrationFiles() {
    final migrationsDir = Directory('${Directory.current.path}/migrations');
    final migrationFiles = <File>[];

    final migrations = migrationsDir.listSync().whereType<Directory>();
    for (final migration in migrations) {
      final files = migration.listSync().whereType<File>();
      final up = files.firstWhereOrNull(
        (file) => file.path.endsWith('up.sql'),
      );

      if (up != null) {
        migrationFiles.add(up);
      }
    }

    return migrationFiles;
  }

  Future<String?> _getLatestMigrationName() async {
    final result = await SqlExecutor.fromConnection(_connection).execute(
      const GetLatestMigrationNameCommand(_schemaTableName),
    );

    return result.isEmpty
        ? null
        : result.first.toColumnMap()['name'] as String?;
  }

  List<File> _getMigrationsToRun({
    required String? latestMigrationName,
    required List<File> migrationFiles,
  }) {
    final lastMigrationIndex = migrationFiles.indexWhere(
      (file) => _getMigrationName(file) == latestMigrationName,
    );

    return lastMigrationIndex == -1
        ? migrationFiles
        : migrationFiles.sublist(lastMigrationIndex + 1);
  }

  Future<void> _runMigration(File file, TxSession session) async {
    final contents = await file.readAsLines();
    final statements = _getMigrationStatements(contents);
    final executor = SqlExecutor.fromSession(session);

    for (final statement in statements) {
      await executor.execute(CustomCommand(statement));
    }

    await executor.execute(
      InsertMigrationNameCommand(_getMigrationName(file)),
    );
  }

  Future<void> _verifyUpdatedAtTimestamps(TxSession session) async {
    final executor = SqlExecutor.fromSession(session);
    final tables = await executor.execute(
      const GetPublicTablesCommand(_schemaTableName),
    );

    for (final table in tables) {
      final tableName = _getTableName(table);
      final columns = await executor.execute(GetTableColumnsCommand(tableName));
      final hasUpdatedAt = _containsUpdatedAt(columns);

      if (hasUpdatedAt) {
        await SqlExecutor.fromSession(session).execute(
          CreateUpdatedAtTriggerCommand(tableName),
        );
      }
    }
  }

  static bool _getExistsResult(Result result) {
    return result.isNotEmpty && result.first.toColumnMap()['exists'] as bool;
  }

  static List<String> _getMigrationStatements(List<String> contents) {
    return contents
        .where((line) => !line.startsWith('--'))
        .join('\n')
        .split(';')
        .where((statement) => statement.trim().isNotEmpty)
        .map((statement) => '$statement;')
        .toList();
  }

  static String _getMigrationName(File file) {
    return file.parent.path.split('/').last;
  }

  static String _getTableName(ResultRow tableRow) {
    return tableRow.toColumnMap()['table_name'] as String;
  }

  static bool _containsUpdatedAt(Result columns) {
    return columns.any((column) => column.firstOrNull == 'updated_at');
  }
}
