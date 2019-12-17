###
  Listens for events in the browser, if it's triggered it runs and then unloads itself
###

chrome.runtime.onInstalled.addListener ->
#storage lets multiple extension components access this parameter
  chrome.storage.sync.set {s: '#3aa757'}, ->
    console.log "green"

#loaded when needed and then removed
chrome.declarativeContent.onPageChanged.removeRules undefined, ->
  chrome.declarativeContent.onPageChanged.addRules [
    conditions: [new chrome.declarativeContent.PageStateMatcher
      pageUrl: {hostEquals: 'developer.chrome.com'}
    ],
    actions: [new chrome.declarativeContent.ShowPageAction]
  ]

if not elements?
  elements = null
#chrome.storage.local.get ['test'], (result) ->
#  elements = result.test

#TODO use onPageChange
#If no tree, or new page, or page change
#parse tree (content script)
#read elements name (function)

#On refresh rate
#parse page for notifications
#add list to notifications, change index to 0
#if change read elements name using index

#Notifications OPTIONAL
#Keep list of elements, {elements: [], index = 0, notifications: []}
#when issuing command, if index >= len(notifications) element[index] else notifications[index]

#Commands must be issued with Ctrl
chrome.commands.onCommand.addListener (command) ->
  alert command
  #TODO MESSAGE TEST

  alert 's'

  chrome.tabs.executeScript {file: './ab.js'}
  chrome.storage.local.get ['test'], (result) ->
    elements = result.test
#TODO MESSAGE TEST
#if no tree skip
#todo if tree is present change icon
#change UI with list of elements and index
#if 1, 2, 3, 4 (is for more)
#if number is functional
#if element has action
#Element.onAction (if it's a paragraph, onAction may include speaking, if it's a button clicking and if form, setting the cursor and notifying the user)
#if new list is returned
#add elements to UI, refresh index
#if 5
#if functional
#index + 4
#add elements to UI
#if esc
#if element in elements has parent has parent
#list is element.parent.parent.children()
#add elements to UI, refresh index, destroy notifications
#repeat does nothing but still reads the elements
#read list using index (function)