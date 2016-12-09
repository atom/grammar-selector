GrammarListView = require './grammar-list-view'
GrammarStatusView = require './grammar-status-view'

commandDisposable = null
grammarListView = null
grammarStatusView = null

module.exports =
  activate: ->
    commandDisposable = atom.commands.add('atom-text-editor', 'grammar-selector:show', createGrammarListView)

  deactivate: ->
    commandDisposable?.dispose()
    commandDisposable = null

    grammarStatusView?.destroy()
    grammarStatusView = null

    grammarListView?.destroy()
    grammarListView = null

  consumeStatusBar: (statusBar) ->
    grammarStatusView = new GrammarStatusView(statusBar)
    grammarStatusView.attach()

createGrammarListView = ->
  grammarListView ?= new GrammarListView()
  grammarListView.toggle()
