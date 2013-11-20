GrammarStatusView = require './grammar-status-view'
GrammarSelectorView = require './grammar-selector-view'

module.exports =
  activate: ->
    atom.rootView.command 'grammar-selector:show', '.editor', =>
      new GrammarSelectorView()

    createStatusEntry = ->
      view = new GrammarStatusView(atom.rootView.statusBar)
      atom.rootView.statusBar.appendLeft(view)

    if atom.rootView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', ->
        createStatusEntry()
