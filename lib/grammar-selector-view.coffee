{SelectListView} = require 'atom'

module.exports =
class GrammarSelector extends SelectListView
  initialize: ->
    super

    @addClass('grammar-selector from-top overlay')
    @list.addClass('mark-active')

    @editor = atom.workspaceView.getActivePaneItem()
    @currentGrammar = @editor.getGrammar()

    @autoDetect = name: 'Auto Detect'
    @currentGrammar = @autoDetect if @currentGrammar is atom.syntax.nullGrammar

    @command 'grammar-selector:show', =>
      @cancel()
      false

    @populate()
    @attach()

  getFilterKey: ->
    'name'

  viewForItem: (grammar) ->
    element = document.createElement('li')
    element.classList.add('active') if grammar is @currentGrammar
    element.textContent = grammar.name
    element

  populate: ->
    grammars = atom.syntax.grammars.filter (grammar) ->
      grammar isnt atom.syntax.nullGrammar

    grammars.sort (grammarA, grammarB) ->
      if grammarA.scopeName is 'text.plain'
        -1
      else if grammarB.scopeName is 'text.plain'
        1
      else
        grammarA.name.localeCompare(grammarB.name)
    grammars.unshift(@autoDetect)
    @setItems(grammars)

  confirmed: (grammar) ->
    @cancel()
    if grammar is @autoDetect
      atom.syntax.clearGrammarOverrideForPath(@editor.getPath())
    else
      atom.syntax.setGrammarOverrideForPath(@editor.getPath(), grammar.scopeName)
    @editor.reloadGrammar()

  attach: ->
    super

    atom.workspaceView.append(this)
    @focusEditor()
