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
  unless grammarListView?
    GrammarListView = require './grammar-list-view'
    grammarListView = new GrammarListView()
  grammarListView.toggle()
