
{Emitter, CompositeDisposable, Task, Range} = require 'atom'

module.exports =
  
  activate: ->
    console.log "activate!"

  getProvider: ->
    providerName: 'language-iso-ebnf'
    wordRegExp: /\b[a-z](?:\s?[a-z0-9])*\b(?!\s*=)/ig
    getSuggestionForWord: (editor, text, range) =>
      return unless /\b[a-z](?:\s?[a-z0-9])*\b/ig.test(text)
      scopes = editor.scopeDescriptorForBufferPosition(range).getScopesArray()
      return @isoProvider(editor, text, range) if 'source.iso-ebnf' in scopes
      return

  isoProvider: (editor, text, range) ->
    #console.log "text: '#{text}', range: #{range}"
    regex = ///(?<![A-Za-z0-9]+\s*)\b#{text}\b(?=\s*=)///ig
    #console.log "regex: #{regex}"
    matchRange = undefined
    editor.scan regex, (object) ->
      #console.log "#{object.matchText} in #{object.range}"
      if object.matchText == text
        #console.log "Hit!"
        matchRange = object.range
        object.stop()
    #console.log "matchRange: #{matchRange}"
    return unless matchRange?
    
    #element = document.createElement('span')
    #element.textContent = text
    
    return {
      range: range
      callback: ->
        #console.log "callback! #{text}"
        editor.scrollToBufferPosition matchRange.start, {center: true}
        
        layer = editor.getDefaultMarkerLayer()
        marker = layer.markBufferRange matchRange,
          invalidate: 'never'
          persistent: false
        decoration = editor.decorateMarker marker,
          type: 'highlight'
          class: 'sample-flash'
        setTimeout ->
          decoration.getMarker().destroy()
          editor.setSelectedBufferRange matchRange
        , 300
    }
