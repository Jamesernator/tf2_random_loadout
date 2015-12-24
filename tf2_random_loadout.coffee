#!/usr/bin/env coffee
"use strict"

_ = require('underscore')
s = require('underscore.string')
fs = require('fs')
async = require('./async.coffee')
CSON = require('cson')
process = require('process')
ArgumentParser = require('argparse').ArgumentParser

CLASSES = [
    "Scout"
    "Soldier"
    "Pyro"
    "Heavy"
    "Demoman"
    "Engineer"
    "Medic"
    "Sniper"
    "Spy"
]

# --- Argument parsing setup
parser = new ArgumentParser
    addHelp: true
    description: "Team Fortress 2 Random Loadout Generator"

parser.addArgument ['-c', '--class'],
    help: 'Player class, chosen randomly if not supplied'
    action: 'append'
    metavar: ['CLASS']

parser.addArgument ['--weighted-class'],
    help: "Adds the class with a different weight"
    action: 'append'
    nargs: 2
    metavar: ['CLASS', 'WEIGHT']

parser.addArgument ['--exclude-class'],
    help: "Excludes the given class from being selected"
    action: 'append'
    nargs: 1
    metavar: ['CLASS']

parser.addArgument ['-e', '--exclude'],
    help: 'Excludes a given weapon from being chosen'
    action: 'append'
    nargs: 3
    metavar: ['CLASS', 'SLOT', 'WEAPON']

parser.addArgument ['-f', '--force-slot'],
    help: "If this argument is used it will force the given slot for the given
           class to gain a weapon with this force slot"
    nargs: 3
    action: 'append'
    metavar: ['CLASS', 'SLOT', 'WEAPON']

parser.addArgument ['-s', '--stock'],
    help: "Forces the given slot on the given class to get the stock weapon
           for that class"
    nargs: 2
    action: 'append'
    metavar: ['CLASS', 'SLOT']

parser.addArgument ['-w', '--weight'],
    help: "Increases the chance of a given weapon being selected,
           adds one to the weight of the group containing it, if
           --ungrouped is used then it simply adds one to the weight
           of the weapon"
    nargs: 3
    action: 'append'
    metavar: ['CLASS', 'SLOT', 'WEAPON']

parser.addArgument ['--ungrouped'],
    help: "Ignores cosmetic group classes and gives equal initial weight to all
           weapons"
    nargs: 0
    action: 'storeTrue'

parser.addArgument ['-a', '--add', '--custom'],
    help: "This is a workaround if the weapon data is out of date, or customized
           weapons wish to be added"
    nargs: 3
    action: 'append'
    metavar: ['CLASS', 'SLOT', 'WEAPON']

parser.addArgument ['--custom-only'],
    help: "This option forces the generator to only consider weapons listed
           using the --custom option"
    nargs: 0
    action: 'storeTrue'

parser.addArgument ['--alternative-data-file'],
    help: "This allows use of an alternative data file (or folder) for
           obtaining, this is mutually exclusive with the --custom-only option"
    nargs: 1
    action: 'append'
    metavar: ['FILE|FOLDER']

parser.addArgument ['--ignore-nonexistent-weapons'],
    help: "If enabled then weapons listed in other arguments that don't exist
           will be ignored (if alternative data file is included it will
           test against the contents of that as well)"
    nargs: 0
    action: 'storeTrue'

# -------

expand_weight_map = (map) ->
    iter = map[Symbol.iterator]()
    result = []
    infinites = []
    while true
        {value, done} = iter.next()
        if done
            break
        [item, weight] = value
        if weight is Infinity
            infinites.push(item)
        else
            for i in [0...weight]
                result.push(item)
    if infinites.length > 0
        return infinites
    else
        return result


weighted_choice = (map) ->
    list = expand_weight_map(map)
    return _.sample(list)

load_class_data = ->
    # This loads all the data from the class files
    data = {}
    for _class in CLASSES
        filename = "./data/#{_class}.cson"
        data[_class] = CSON.load(filename)
    return data

select_class = (args) ->
    classes = args.class ? CLASSES
    if args.exclude_class?
        classes = _.without(classes, args.exclude_class...)
        console.log classes

    weighted = new Map()
    for _class in classes
        weighted.set(_class, 1)

    for [_class, weight] in args.weighted_class ? []
        weighted.set(_class, weight)

    return weighted_choice(weighted)


main = ->
    args = parser.parseArgs()
    _class = select_class(args)
    console.log _class.toUpperCase()

main()
