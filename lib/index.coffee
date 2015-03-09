_ = require 'lodash'
W = require 'when'
editorconfig = require 'editorconfig'
fs = require 'graceful-fs'
path = require 'path'

requireTree = require 'require-tree'
Rules = requireTree './rules'

check = (files) ->
  exitCode = 0
  promises = []
  Object.keys(Rules).forEach (ruleName) ->
    Rule = Rules[ruleName]
    files.forEach (filePath) ->
      if fs.lstatSync(filePath).isDirectory() then return
      property = undefined
      promises.push(
        (new Rule(filePath)).then((returnedProperty) ->
          property = returnedProperty
          property.check()
        ).then((res) ->
          res: res
          file: filePath
          rule: property.propertyName
        ).catch((err) ->
          file: filePath
          rule: property.propertyName
          error: err
        )
      )

  W.all(promises).done((res) ->
    files = _.uniq _.pluck(res, 'file')
    for file in files
      matches = _.where res, file: file
      verbose = true
      if verbose or _.compact(_.pluck(matches, 'error')).length > 0
        for match in matches
          if match.error?
            exitCode = 1
            text = "#{file} failed #{match.rule}"
            if match.error.lineNumber?
              text += " on line #{match.error.lineNumber}"
            if match.error.message?
              text += ": #{match.error.message}"
            console.log text
          else if verbose
            if match.res is null
              console.log "#{file} ignored #{match.rule} (no setting defined)"
            else
              #console.log "#{file} passed #{match.rule}"
    process.exit(exitCode)
  )

fix = (files) ->
  results = []
  promise = W.resolve()
  for ruleName in Object.keys(Rules)
    Rule = Rules[ruleName]
    for filePath in files
      if fs.lstatSync(filePath).isDirectory() then continue
      do (Rule, filePath) ->
        property = undefined
        promise = promise.then( ->
          new Rule(filePath)
        ).then((returnedProperty) ->
          property = returnedProperty
          property.fix()
        ).then((res) ->
          results.push(
            res: res
            file: filePath
            rule: property.propertyName
          )
        ).catch((err) ->
          results.push(
            file: filePath
            rule: property.propertyName
            error: err
          )
        )

  promise.done ->
    verbose = true
    for result in results
      if result.error?
        console.log "#{result.file} #{result.error.message}"
      else if verbose
        console.log "#{result.file} fixed"

infer = (files) ->
  promises = []
  Object.keys(Rules).forEach (ruleName) ->
    Rule = Rules[ruleName]
    files.forEach (filePath) ->
      if fs.lstatSync(filePath).isDirectory() then return
      property = undefined
      promises.push(
        (new Rule(filePath)).then((returnedProperty) ->
          property = returnedProperty
          property.infer()
        ).then((res) ->
          res: res
          file: filePath
          rule: property.propertyName
        ).catch((err) ->
          file: filePath
          rule: property.propertyName
          error: err
        )
      )

  W.all(promises).done((res) ->
    rules = {}
    _.remove(res, (e) -> not e.res?) # remove null results
    filteredResults = []
    for result in res
      if result.rule is 'indent_char'
        indentStyle = (
          if result.res is '\t'
            'tab'
          else
            'space'
        )
        filteredResults.push(
          rule: 'indent_style'
          res: indentStyle
          file: result.file
        )
        if indentStyle is 'space'
          filteredResults.push(
            rule: 'indent_size'
            res: String result.res.length
            file: result.file
          )
      else
        # convert result.res to a string because getting distributionOfValues
        # involves a step where it is used as an object key, so it becomes a
        # string and needs to be matched to.
        result.res = String result.res
        filteredResults.push(result)

    groups = _.groupBy(filteredResults, 'rule')
    for property, group of groups
      distributionOfValues = _.pairs _.countBy _.pluck(group, 'res'), (x) -> x
      sortedValues = _.sortBy distributionOfValues, (x) -> -x[1]

      # most common value gets to be global
      rules['[*]'] ?= []
      rules['[*]'].push([property, sortedValues[0][0]])

      # the rest are given a selector based on what files they hit
      for value in sortedValues[1..]
        files = _.pluck _.where(group, res: value[0]), 'file'
        selector = "[{#{files.join(',')}}]"
        rules[selector] ?= []
        rules[selector].push([property, value[0]])

    for selector, ruleGroup of rules
      console.log selector
      for rule in ruleGroup
        console.log "#{rule[0]} = #{rule[1]}"

      console.log ''
  )

module.exports = {check, fix, infer}
