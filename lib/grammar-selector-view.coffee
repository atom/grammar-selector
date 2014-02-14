{_, $$, SelectListView} = require 'atom'

module.exports =
class GrammarSelector extends SelectListView
  @viewClass: -> "#{super} grammar-selector from-top overlay"

  filterKey: 'name'

  initialize: ->
    @editor = atom.workspaceView.getActivePaneItem()
    @list.addClass('mark-active') # TODO: there may be a better way to specify this.
    @currentGrammar = @editor.getGrammar()
    @autoDetect = name: 'Auto Detect'
    @currentGrammar = @autoDetect if @currentGrammar is atom.syntax.nullGrammar
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
    grammars = atom.syntax.grammars.filter (grammar) ->
      grammar isnt atom.syntax.nullGrammar

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
      atom.syntax.clearGrammarOverrideForPath(@path)
    else
      atom.syntax.setGrammarOverrideForPath(@path, grammar.scopeName)
    @editor.reloadGrammar()

  attach: ->
    super

    atom.workspaceView.append(this)
    @miniEditor.focus()
