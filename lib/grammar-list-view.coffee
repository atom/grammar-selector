{$$, SelectListView} = require 'atom-space-pen-views'
{match} = require 'fuzzaldrin'

# View to display a list of grammars to apply to the current editor.
module.exports =
class GrammarListView extends SelectListView
  initialize: ->
    super

    @addClass('grammar-selector')
    @list.addClass('mark-active')
    @autoDetect = name: 'Auto Detect'

  getFilterKey: ->
    'name'

  destroy: ->
    @cancel()

  viewForItem: (grammar) ->
    # Style matched characters in search results
    filterQuery = @getFilterQuery()
    matches = match(grammar, filterQuery)

    $$ ->
      highlighter = (grammar, matches, offsetIndex) =>
        lastIndex = 0
        matchedChars = [] # Build up a set of matched chars to be more semantic

        for matchIndex in matches
          matchIndex -= offsetIndex
          continue if matchIndex < 0 # If marking up the basename, omit grammar matches
          unmatched = grammar.substring(lastIndex, matchIndex)
          if unmatched
            @span matchedChars.join(''), class: 'character-match' if matchedChars.length
            matchedChars = []
            @text unmatched
          matchedChars.push(grammar[matchIndex])
          lastIndex = matchIndex + 1

        @span matchedChars.join(''), class: 'character-match' if matchedChars.length

        # Remaining characters are plain text
        @text grammar.substring(lastIndex)

      element = document.createElement('li')
      element.classList.add('active') if grammar is @currentGrammar
      grammarName = grammar.name ? grammar.scopeName
      element.textContent = highlighter(grammar, matches, 0)
      element.dataset.grammar = grammarName
      element

  cancelled: ->
    @panel?.destroy()
    @panel = null
    @editor = null
    @currentGrammar = null

  confirmed: (grammar) ->
    if grammar is @autoDetect
      atom.grammars.clearGrammarOverrideForPath(@editor.getPath())
      @editor.reloadGrammar()
    else
      atom.grammars.setGrammarOverrideForPath(@editor.getPath(), grammar.scopeName)
      @editor.setGrammar(grammar)
    @cancel()

  attach: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()

  toggle: ->
    if @panel?
      @cancel()
    else if @editor = atom.workspace.getActiveTextEditor()
      @currentGrammar = @editor.getGrammar()
      @currentGrammar = @autoDetect if @currentGrammar is atom.grammars.nullGrammar
      @setItems(@getGrammars())
      @attach()

  getGrammars: ->
    grammars = atom.grammars.getGrammars().filter (grammar) ->
      grammar isnt atom.grammars.nullGrammar

    grammars.sort (grammarA, grammarB) ->
      if grammarA.scopeName is 'text.plain'
        -1
      else if grammarB.scopeName is 'text.plain'
        1
      else
        grammarA.name?.localeCompare?(grammarB.name) ? grammarA.scopeName?.localeCompare?(grammarB.name) ? 1

    grammars.unshift(@autoDetect)
    grammars
