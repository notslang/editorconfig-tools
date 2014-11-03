require 'should'
File = require 'fobject'

InsertFinalNewline = require '../lib/rules/trim-trailing-whitespace'

describe 'trim_trailing_whitespace rule unit', ->
  before ->
    @rule = new InsertFinalNewline('fakefile')

  it 'should have the correct propertyName', ->
    @rule.propertyName.should.eql('trim_trailing_whitespace')

  it 'should detect trailing whitespace', ->
    @rule.inferLine('line \n').should.eql(false)
    @rule.inferLine('line\t\n').should.eql(false)
    @rule.inferLine('line  \t\n').should.eql(false)
    @rule.inferLine('line  \t').should.eql(false)
    @rule.inferLine('line\n').should.eql(true)
    @rule.inferLine('line').should.eql(true)
    @rule.inferLine('').should.eql(true)

  it 'should fix trailing whitespace', ->
    @rule.fixLine('line \n').should.eql('line\n')
    @rule.fixLine('line\t\n').should.eql('line\n')
    @rule.fixLine('line  \t\n').should.eql('line\n')
    @rule.fixLine('line\n').should.eql('line\n')
    @rule.fixLine('line').should.eql('line')
    @rule.fixLine('').should.eql('')

describe 'trim_trailing_whitespace rule integration (true)', ->
  before (done) ->
    @file = new File('./test/fixtures/trim-trailing-whitespace-true/file')
    @file.write(
      'line\n'
    ).done(done)
    @rule = new InsertFinalNewline('./test/fixtures/trim-trailing-whitespace-true/file')

  after (done) ->
    # reset file state
    @file.write(
      'line\nline\n'
    ).done(done)

  it 'should detect trailing whitespace', (done) ->
    @file.write(
      'line  \nline\t\n'
    ).then(
      @rule.infer
    ).done((res) ->
      res.should.eql(false)
      done()
    )

  it 'should detect mixed trailing whitespace', (done) ->
    @file.write(
      'line  \nline\n'
    ).then(
      @rule.infer
    ).done((res) ->
      res.should.eql(false)
      done()
    )

  it 'should detect lack of trailing whitespace', (done) ->
    @file.write(
      'line\nline'
    ).then(
      @rule.infer
    ).done((res) ->
      res.should.eql(true)
      done()
    )

  it 'should fix trailing whitespace', (done) ->
    @file.write(
      'line one  \nline two\n  '
    ).then(
      @rule.fix
    ).then( =>
      @file.read(encoding: 'utf8')
    ).done((res) ->
      String(res).should.eql('line one\nline two\n')
      done()
    )

  it 'should fix trailing whitespace when there is none', (done) ->
    @file.write(
      'line one\nline two\n'
    ).then(
      @rule.fix
    ).then( =>
      @file.read(encoding: 'utf8')
    ).done((res) ->
      String(res).should.eql('line one\nline two\n')
      done()
    )
