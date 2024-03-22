import 'package:args/command_runner.dart';
import 'src/commands.dart';

CommandRunner buildParser() {
  final runner = CommandRunner('migrator', 'A postgres migration tool')
    ..addCommand(VersionCommand())
    ..addCommand(CreateCommand())
    ..addCommand(MigrateCommand());

  return runner;
}

void main(List<String> arguments) async {
  final runner = buildParser();

  runner.run(arguments);
}
