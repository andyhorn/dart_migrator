import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:dart_migrator/src/migration_runner.dart';
import 'package:postgres/postgres.dart';
import 'package:yaml/yaml.dart';

enum ConnectionStringSource {
  url,
  env,
}

class VersionCommand extends Command {
  @override
  String get description => 'Print the tool version';

  @override
  String get name => 'version';

  @override
  Future<void> run() async {
    final file = File('../pubspec.yaml');
    final contents = await file.readAsString();
    final yaml = loadYaml(contents);
    final version = yaml['version'];

    print('migrator version: $version');
  }
}

class CreateCommand extends Command {
  CreateCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The name of the migration',
      valueHelp: 'name',
      mandatory: true,
    );
  }

  @override
  final String description = 'Create a new migration';

  @override
  final String name = 'create';

  @override
  Future<void> run() async {
    if (argResults?.wasParsed('name') != true) {
      throw UsageException('You must provide a name for the migration', usage);
    }

    final name = argResults?['name'] as String;
    final now = DateTime.now().millisecondsSinceEpoch;
    final dirName = '${now}_$name';
    final dir = Directory('migrations/$dirName');

    await dir.create(recursive: true);

    final file = File('${dir.path}/up.sql');
    await file.writeAsString('-- Add your UP migration here');

    final downFile = File('${dir.path}/down.sql');
    await downFile.writeAsString('-- Add your DOWN migration here');

    print('Migrations created at ${dir.path}/up.sql and ${dir.path}/down.sql');
  }
}

class MigrateCommand extends Command {
  MigrateCommand() {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Print verbose output',
      defaultsTo: false,
      negatable: false,
    );

    argParser.addOption(
      'url',
      help: 'Use a connection string URL',
      valueHelp: 'url',
    );

    argParser.addFlag(
      'env',
      help: 'Use a .env file with a DATABASE_URL key',
      negatable: false,
    );
  }

  @override
  String get description => 'Run all pending migrations';

  @override
  String get name => 'migrate';

  @override
  Future<void> run() async {
    final source = _getConnectionStringSource();
    final connectionString = await _getConnectionString(source);
    final endpoint = _parseEndpoint(connectionString);

    final connection = await Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );

    final migrator = MigrationRunner(connection);
    await migrator.run();
  }

  ConnectionStringSource _getConnectionStringSource() {
    final useUrl = argResults!.arguments.contains('--url');
    final useEnv = argResults!.arguments.contains('--env');

    if (useUrl && useEnv) {
      throw UsageException('You cannot use both --url and --env', usage);
    }

    if (!useUrl && !useEnv) {
      throw UsageException('You must provide either --url or --env', usage);
    }

    return useUrl ? ConnectionStringSource.url : ConnectionStringSource.env;
  }

  Future<String> _getConnectionString(ConnectionStringSource source) async {
    return switch (source) {
      ConnectionStringSource.url => _getConnectionStringUrl(),
      ConnectionStringSource.env => _getConnectionStringEnv(),
    };
  }

  String _getConnectionStringUrl() {
    final connectionString = argResults!['url'] as String?;

    if (connectionString == null) {
      throw StateError('No URL provided');
    }

    return connectionString;
  }

  String _getConnectionStringEnv() {
    final file = File('.env');

    if (!file.existsSync()) {
      throw StateError('No .env file found');
    }

    final contents = file.readAsStringSync();
    final lines = contents.split('\n');
    final connectionString = lines.firstWhereOrNull(
      (line) => line.startsWith('DATABASE_URL='),
    );

    if (connectionString == null) {
      throw StateError('No DATABASE_URL found in .env');
    }

    return connectionString.substring('DATABASE_URL='.length);
  }

  Endpoint _parseEndpoint(String connectionString) {
    final verbose = argResults!['verbose'] as bool;

    final uri = Uri.parse(connectionString);
    final database = uri.pathSegments.first;
    final host = uri.host;
    final password = uri.userInfo.split(':').last;
    final port = uri.port;
    final username = uri.userInfo.split(':').first;

    if (verbose) {
      print('database: $database');
      print('host: $host');
      print('password: $password');
      print('port: $port');
      print('username: $username');
    }

    final endpoint = Endpoint(
      database: database,
      host: host,
      isUnixSocket: false,
      password: password,
      port: port,
      username: username,
    );

    return endpoint;
  }
}
