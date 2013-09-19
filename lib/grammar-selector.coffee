{_, $$, Editor, SelectList} = require 'atom'

module.exports =
class GrammarSelector extends SelectList
  @viewClass: -> "#{super} grammar-selector from-top overlay"

  @activate: ->
    rootView.command 'grammar-selector:show', '.editor', => new GrammarSelector()

  filterKey: 'name'

  initialize: ->
    @editor = rootView.getActiveView()
    return unless @editor instanceof Editor
    @list.addClass('mark-active') # TODO: there may be a better way to specify this.
    @currentGrammar = @editor.getGrammar()
    @autoDetect = name: 'Auto Detect'
    @currentGrammar = @autoDetect if @currentGrammar is syntax.nullGrammar
    @path = @editor.getPath()
    @command 'grammar-selector:show', =>
      @cancel()
      false
    super

    @populate()
    @attach()

  itemForElement: (grammar) ->
    grammarClass = ''
    grammarClass = 'active' if grammar is @currentGrammar

    $$ ->
      @li grammar.name, class: grammarClass

  populate: ->
    grammars = new Array(syntax.grammars...)
    grammars = _.reject grammars, (grammar) -> grammar is syntax.nullGrammar
    grammars.sort (grammarA, grammarB) ->
      if grammarA.scopeName is 'text.plain'
        -1
      else if grammarB.scopeName is 'text.plain'
        1
      else if grammarA.name < grammarB.name
        -1
      else if grammarA.name > grammarB.name
        1
      else
        0
    grammars.unshift(@autoDetect)
    @setArray(grammars)

  confirmed: (grammar) ->
    @cancel()
    if grammar is @autoDetect
      syntax.clearGrammarOverrideForPath(@path)
    else
      syntax.setGrammarOverrideForPath(@path, grammar.scopeName)
    @editor.reloadGrammar()

  attach: ->
    super
    rootView.append(this)
    @miniEditor.focus()
