path = require 'path'
glob = require('glob').sync

packageInfo = require(path.join(__dirname, '../package.json'))
ArgumentParser = require('argparse').ArgumentParser
{check, fix, infer} = require './index'

argparser = new ArgumentParser(
  version: packageInfo.version
  addHelp: true
  description: packageInfo.description
)
subparsers = argparser.addSubparsers(
  title: 'action'
  dest: 'action'
)
inferCommand = subparsers.addParser(
  'infer'
  help: 'Infer .editorconfig settings from one or more files'
  addHelp: true
)
inferCommand.addArgument(
  ['files']
  type: 'string'
  metavar: 'FILE'
  nargs: '+'
  help: 'The file(s) to use'
)

checkCommand = subparsers.addParser(
  'check'
  help: 'Validate that file(s) adhere to .editorconfig settings, returning an
  error code if they don\'t'
  addHelp: true
)
checkCommand.addArgument(
  ['files']
  type: 'string'
  metavar: 'FILE'
  nargs: '+'
  help: 'The file(s) to use'
)

fixCommand = subparsers.addParser(
  'fix'
  help: 'Fix formatting errors that disobey .editorconfig settings'
  addHelp: true
)
fixCommand.addArgument(
  ['files']
  type: 'string'
  metavar: 'FILE'
  nargs: '+'
  help: 'The file(s) to use'
)

argv = argparser.parseArgs()

argv.files = Array::concat.apply [], (argv.files.map (f) -> glob f)

if argv.action is 'check'
  check(argv.files)
else if argv.action is 'fix'
  fix(argv.files)
else if argv.action is 'infer'
  infer(argv.files)
