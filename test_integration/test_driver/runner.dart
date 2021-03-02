import 'package:args/args.dart';

import 'tests_abstract.dart';
import 'tests_config.dart';

void main(List<String> args) {
  final parser = ArgParser();
  final allowedModules =
      TestGroup.values.map((group) => group.toString().split('.')[1]).toList();
  parser.addOption(
    'modules',
    abbr: 'm',
    allowed: allowedModules,
    allowMultiple: true,
  );
  parser.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show this help content',
  );

  final argv = parser.parse(args);

  if (argv['help'] as bool) {
    print(parser.usage);
    return;
  }

  final modules = argv['modules'];
  if (modules != null) {
    if (modules is List) {
      runTests(
          groups: modules
              .map((module) =>
                  TestGroup.values[allowedModules.indexOf(module as String)])
              .toList());
    } else {
      runTests(
          groupName:
              TestGroup.values[allowedModules.indexOf(modules as String)]);
    }
  } else {
    runTests(all: true);
  }
}
