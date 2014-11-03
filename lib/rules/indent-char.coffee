LineRule = require '../line-rule'
Rule = require '../rule'
detectIndent = require 'detect-indent'

EditorConfigError = require '../editorconfigerror'

class IndentChar extends LineRule
  ###*
   * This actually isn't an official property. It's a combination of the
     `indent_style` and `indent_size` properties that's used internally to do
     them both at once.
  ###
  propertyName: 'indent_char'

  fix: ->
    @infer().then((@_detectedSetting) =>
      if not @_detectedSetting?
        throw new Error('couldn\'t detect indentation')
      if @setting is @_detectedSetting then return
      @_indentRegex = new RegExp("^(?:#{@_detectedSetting})*")
      super() # loop through all the lines, fixing indentation
    )

  fixLine: (line) ->
    match = line.match(@_indentRegex)[0]
    totalIndents = match.length / @_detectedSetting.length
    Array(totalIndents + 1).join(@setting) + line[match.length..]

  check: Rule::check

  infer: ->
    @file.read(encoding: 'utf8').then((data) -> detectIndent(String(data)))

module.exports = IndentChar
