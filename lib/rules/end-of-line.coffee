LineRule = require '../line-rule'
{eolRegex} = require '../util'

class EndOfLine extends LineRule
  propertyName: 'end_of_line'

  fixLine: (line) =>
    replacement = (
      switch @setting
        when 'crlf' then '\r\n'
        when 'cr' then '\r'
        when 'lf' then '\n'
        else
          throw new Error("unsupported value for end_of_line: #{@setting}")
    )
    line.replace(eolRegex, replacement)

  ###*
   * Infer the line ending, returning `undefined` if there is no line ending
   * @param {String} line
  ###
  inferLine: (line) ->
    switch line.match(eolRegex)?[0]
      when '\r\n' then 'crlf'
      when '\n' then 'lf'
      when '\r' then 'cr'

module.exports = EndOfLine
