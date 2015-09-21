#!/usr/bin/env coffee
_ = require('underscore')
s = require('underscore.string')
fs = require('fs')
CSON = require('cson')
process = require('process')
ArgParse = require('argparse').ArgumentParser

ITEM_DATA = 'loadout_data.cson'

CLASSES = ['Scout', 'Soldier', 'Pyro'
           'Demoman', 'Heavy', 'Engineer'
           'Medic', 'Sniper', 'Spy'
          ]

parser =

select_random_loadout = (data, player_class, excludes=null) ->
    for type, data of data[s.capitalize(player_class)]
        set = _.sample(data)
        item = _.sample(set)
        if excludes?
            while item in excludes
                set = _.without(set, item)
        console.log "#{type}: #{item}"


parser = new ArgParse
    addHelp: true
    description: "Team Fortress 2 Random Loadout Generator"

parser.addArgument ['-c', '--class'],
    help: 'Player class, chosen randomly if not supplied'
    action: 'append'
    metavar: ['CLASS']

parser.addArgument ['-e', '--exclude'],
    help: 'Excludes a given weapon from being chosen'
    action: 'append'
    metavar: ['WEAPON']

parser.addArgument ['-i', '--include'],
    help: "If this argument is used then only weapons within the includes
           list will be chosen"
    action: 'append'
    metavar: ['WEAPON']

parser.addArgument ['-f', '--force-slot'],
    help: "If this argument is used it will force the given slot for the given
           class to gain a weapon with this force slot"
    nargs: 3
    action: 'append'
    metavar: ['CLASS', 'SLOT', 'WEAPON']

parser.addArgument ['-s', '--stock'],
    help: "Forces the given slot on the given class to get the stock weapon
           for that class"

main = ->
    console.log parser.parseArgs()

main()
