path = require 'path'
File = require 'fobject'
W = require 'when'

EditorConfigError = require './editorconfigerror'
editorconfig = require './editorconfig'

class Rule
  ###*
   * The "official" name of the rule, according to the editorconfig spec.
   * @type {String}
  ###
  propertyName: ''

  ###*
   * The setting of the rule for the file being tested.
   * @type {String|Integer|Boolean}
  ###
  setting: undefined

  ###*
   * The file being tested.
   * @type {File}
  ###
  file: undefined

  ###*
   * Setup the Rule for a given filename so the other methods can be used.
   * @param {String} filename
  ###
  constructor: (filename) ->
    return editorconfig(filename).then((@editorconfig) =>
      @setting = @editorconfig[@propertyName]
      @file = new File(filename)
      return this
    )

  ###*
   * Fix the file so it matches the given editorconfig setting
   * @return {Promise}
  ###
  fix: =>
    if not @setting? or @setting == "unset"
      W.reject(new EditorConfigError(
        "cannot fix #{@propertyName} (no setting defined)"
      ))
    else
      W()

  ###*
   * Ensure that the file obeys the editorconfig setting. Throw an error if it
     doesn't.
   * @return {Promise}
  ###
  check: =>
    if not @setting?
      W.resolve(null) # the setting isn't defined, so we can't check it
    else
      @infer().then((detectedSetting) =>
        if detectedSetting? and detectedSetting isnt @setting
          throw new EditorConfigError(
            "found setting '#{detectedSetting}', should be '#{@setting}'"
            @file.path
          )
      )

  ###*
   * Determine the value of the setting based on the contents of the file.
   * @return {Promise} A promise for the value of the setting.
  ###
  infer: ->

module.exports = Rule
