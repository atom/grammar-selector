{SelectListView} = require 'atom'

# View to display a list of grammars to apply to the current editor.
module.exports =
class GrammarListView extends SelectListView
  initialize: (@editor) ->
    super

    @addClass('grammar-selector from-top overlay')
    @list.addClass('mark-active')

    @autoDetect = name: 'Auto Detect'
    @currentGrammar = @editor.getGrammar()
    @currentGrammar = @autoDetect if @currentGrammar is atom.syntax.nullGrammar

    @command 'grammar-selector:show', =>
      @cancel()
      false

    @setItems(@getGrammars())
    @attach()

  getFilterKey: ->
    'name'

  viewForItem: (grammar) ->
    element = document.createElement('li')
    element.classList.add('active') if grammar is @currentGrammar
    element.textContent = grammar.name
    element

  confirmed: (grammar) ->
    @cancel()
    if grammar is @autoDetect
      atom.syntax.clearGrammarOverrideForPath(@editor.getPath())
    else
      atom.syntax.setGrammarOverrideForPath(@editor.getPath(), grammar.scopeName)
    @editor.reloadGrammar()

  attach: ->
    @storeFocusedElement()
    atom.workspaceView.append(this)
    @focusEditor()

  getGrammars: ->
    grammars = atom.syntax.getGrammars().filter (grammar) ->
      grammar isnt atom.syntax.nullGrammar

    grammars.sort (grammarA, grammarB) ->
      if grammarA.scopeName is 'text.plain'
        -1
      else if grammarB.scopeName is 'text.plain'
        1
      else
        grammarA.name.localeCompare(grammarB.name)
    grammars.unshift(@autoDetect)
    grammars
