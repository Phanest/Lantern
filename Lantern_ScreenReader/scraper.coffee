#todo test this
import 'elements'
import jsonldRdfaParser from 'jsonld-rdfa-parser'
jsonld = require 'jsonld' #todo maybe use required everywhere
#jsonldRdfaParser = require 'jsonld-rdfa-parser'

console.log 'here'

src = 'C:\\Users\\Kanan-PC\\Desktop\\Lantern\\Example\\Example2.html'
content = null
jsonld.registerRDFParser 'text/html', jsonldRdfaParser
jsonld.fromRDF src, {format: 'text/html'}, (err, data) ->
  content = data

elements = {}
mark = 0
for element in content
#Skip declarations
  if mark == 0
    mark = 1
    continue

  node = addElement(element)
  if not node?
    continue

  a = [node, 0]
  elements[node.id] = a

#elements = {id: [node, 0]...}
for key of elements
  element = elements[key][0]
  element.addChildren(elements)

root = new tree(elements)
elements =
  elements: root.children,
  index: 0,
  notifications: []

chrome.storage.local.set {test: elements}