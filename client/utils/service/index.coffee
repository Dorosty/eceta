ex = require './ex'
{gets, posts, others} = require './names'
{post} = require './getPost'
log = require('../log').service

exports.instance = (thisComponent) ->
  exports = {}

  gets.concat(posts).concat(others).forEach (x) ->
    exports[x] = (params) ->
      l = log.get thisComponent, x, params
      l()
      ex[x] params
      .then (data) ->
        l data
        data

  exports

exports.extendModule = (fn) ->
  fn ex

exports.getPerson = ->
  post 'getPerson'

exports.autoPing = ->
  do fn = ->
    post 'ping'
    .fin ->
      setTimeout fn