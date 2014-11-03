require 'should'
File = require 'fobject'

InsertFinalNewline = require '../lib/rules/insert-final-newline'

describe 'insert_final_newline rule unit', ->
  before ->
    @rule = new InsertFinalNewline('fakefile')

  it 'should have the correct propertyName', ->
    @rule.propertyName.should.eql('insert_final_newline')

describe 'insert_final_newline rule integration (true)', ->
  before (done) ->
    @file = new File('./test/fixtures/insert-final-newline-true/file')
    @file.write(
      'line\n'
    ).done(done)
    @rule = new InsertFinalNewline('./test/fixtures/insert-final-newline-true/file')

  after (done) ->
    # reset file state
    @file.write(
      'line\n'
    ).done(done)

  it 'should detect line ending', (done) ->
    @file.write(
      'line\n'
    ).then(
      @rule.infer
    ).done((res) ->
      res.should.eql(true)
      done()
    )

  it 'should fix missing line ending', (done) ->
    @file.write(
      'line'
    ).then(
      @rule.fix
    ).then( =>
      @file.read(encoding: 'utf8')
    ).done((res) ->
      String(res).should.eql('line\n')
      done()
    )

  it 'should fix present line ending', (done) ->
    @file.write(
      'line\n'
    ).then(
      @rule.fix
    ).then( =>
      @file.read(encoding: 'utf8')
    ).done((res) ->
      String(res).should.eql('line\n')
      done()
    )

describe 'insert_final_newline rule integration (false)', ->
  before ->
    @file = new File('./test/fixtures/insert-final-newline-false/file')
    @rule = new InsertFinalNewline('./test/fixtures/insert-final-newline-false/file')

  after (done) ->
    # reset file state
    @file.write(
      'line'
    ).done(done)

  it 'should detect missing line ending', (done) ->
    @file.write(
      'line'
    ).then(
      @rule.infer
    ).done((res) ->
      res.should.eql(false)
      done()
    )

  it 'should fix missing line ending', (done) ->
    @file.write(
      'line'
    ).then(
      @rule.fix
    ).then( =>
      @file.read(encoding: 'utf8')
    ).done((res) ->
      String(res).should.eql('line')
      done()
    )

  it 'should fix present line ending', (done) ->
    @file.write(
      'line\n'
    ).then(
      @rule.fix
    ).then( =>
      @file.read(encoding: 'utf8')
    ).done((res) ->
      String(res).should.eql('line')
      done()
    )
