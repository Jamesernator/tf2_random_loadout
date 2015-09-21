#!/usr/bin/env coffee
fs = require('fs')
CSON = require('cson')

CLASSES = ['Scout', 'Soldier', 'Pyro'
           'Demoman', 'Heavy', 'Engineer'
           'Medic', 'Sniper', 'Spy'
          ]

rebuild = ->
    for class_ in CLASSES
        new_file = "data2/#{class_}.cson"
        data = CSON.load("data/#{class_}.cson")[class_]
        new_data = CSON.createString data, {indent: ' '.repeat(4)}
        fs.writeFileSync new_file, new_data

main = ->
    complete = {}
    for class_ in CLASSES
        data = CSON.load("data/#{class_}.cson")
        complete[class_] = data
    compiled = CSON.createString complete, {indent: ' '.repeat(4)}
    fs.writeFileSync 'loadout_data.cson', compiled

main()
