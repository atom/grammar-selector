GrammarSelector = require '../lib/grammar-selector'
{_, $, RootView} = require 'atom'

describe "GrammarSelector", ->
  [editor, textGrammar, jsGrammar] =  []

  beforeEach ->
    atom.rootView = new RootView
    atom.packages.activatePackage('grammar-selector')
    atom.packages.activatePackage('language-text', sync: true)
    atom.packages.activatePackage('language-javascript', sync: true)
    atom.rootView.openSync('sample.js')
    editor = atom.rootView.getActiveView()
    textGrammar = _.find atom.syntax.grammars, (grammar) -> grammar.name is 'Plain Text'
    expect(textGrammar).toBeTruthy()
    jsGrammar = _.find atom.syntax.grammars, (grammar) -> grammar.name is 'JavaScript'
    expect(jsGrammar).toBeTruthy()
    expect(editor.getGrammar()).toBe jsGrammar

  describe "when grammar-selector:show is triggered", ->
    it "displays a list of all the available grammars", ->
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      expect(grammarView).toExist()
      {grammars} = atom.syntax
      expect(grammarView.list.children('li').length).toBe grammars.length
      expect(grammarView.list.children('li:first').text()).toBe 'Auto Detect'
      for li in grammarView.list.children('li')
        expect($(li).text()).not.toBe atom.syntax.nullGrammar.name

  describe "when a grammar is selected", ->
    it "sets the new grammar on the editor", ->
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

  describe "when auto-detect is selected", ->
    it "restores the auto-detected grammar on the editor", ->
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      grammarView.confirmed(grammarView.array[0])
      expect(editor.getGrammar()).toBe jsGrammar

  describe "when the editor's current grammar is the null grammar", ->
    it "displays Auto Detect as the selected grammar", ->
      editor.activeEditSession.setGrammar(atom.syntax.nullGrammar)
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      expect(grammarView.list.children('li.active').text()).toBe 'Auto Detect'
