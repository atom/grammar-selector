GrammarSelector = require '../lib/grammar-selector'
{_, $, RootView} = require 'atom'

describe "GrammarSelector", ->
  [editor, textGrammar, jsGrammar] =  []

  beforeEach ->
    window.rootView = new RootView
    atom.activatePackage('grammar-selector')
    atom.activatePackage('text-tmbundle', sync: true)
    atom.activatePackage('javascript-tmbundle', sync: true)
    rootView.openSync('sample.js')
    editor = rootView.getActiveView()
    textGrammar = _.find syntax.grammars, (grammar) -> grammar.name is 'Plain Text'
    expect(textGrammar).toBeTruthy()
    jsGrammar = _.find syntax.grammars, (grammar) -> grammar.name is 'JavaScript'
    expect(jsGrammar).toBeTruthy()
    expect(editor.getGrammar()).toBe jsGrammar

  describe "when grammar-selector:show is triggered", ->
    it "displays a list of all the available grammars", ->
      editor.trigger 'grammar-selector:show'
      grammarView = rootView.find('.grammar-selector').view()
      expect(grammarView).toExist()
      grammars = syntax.grammars
      expect(grammarView.list.children('li').length).toBe grammars.length
      expect(grammarView.list.children('li:first').text()).toBe 'Auto Detect'
      for li in grammarView.list.children('li')
        expect($(li).text()).not.toBe syntax.nullGrammar.name

  describe "when a grammar is selected", ->
    it "sets the new grammar on the editor", ->
      editor.trigger 'grammar-selector:show'
      grammarView = rootView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

  describe "when auto-detect is selected", ->
    it "restores the auto-detected grammar on the editor", ->
      editor.trigger 'grammar-selector:show'
      grammarView = rootView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

      editor.trigger 'grammar-selector:show'
      grammarView = rootView.find('.grammar-selector').view()
      grammarView.confirmed(grammarView.array[0])
      expect(editor.getGrammar()).toBe jsGrammar

  describe "when the editor's current grammar is the null grammar", ->
    it "displays Auto Detect as the selected grammar", ->
      editor.activeEditSession.setGrammar(syntax.nullGrammar)
      editor.trigger 'grammar-selector:show'
      grammarView = rootView.find('.grammar-selector').view()
      expect(grammarView.list.children('li.active').text()).toBe 'Auto Detect'
