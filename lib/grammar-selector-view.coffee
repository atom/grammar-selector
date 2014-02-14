{SelectListView} = require 'atom'

# View to display a list of grammars to apply to the current editor.
module.exports =
class GrammarSelectorView extends SelectListView
  initialize: (@editor) ->
    super

    @addClass('grammar-selector from-top overlay')
    @list.addClass('mark-active')

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
