jsonld = require('../node_modules/jsonld')
jsonldRdfaParser = require('../node_modules/jsonld-rdfa-parser')

console.log 'here in b.coffee'

src = document.body
content = null
jsonld.registerRDFParser 'text/html', jsonldRdfaParser
jsonld.fromRDF src, {format: 'text/html'}, (err, data) ->
  content = data
  console.log data
  chrome.runtime.sendMessage {test: content}

  console.log 'message sent'