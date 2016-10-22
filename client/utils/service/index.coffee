Q = require 'q'
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

exports.cas = (ticket) ->
  post 'cas', {ticket}

exports.casLogin = (golestanNumber) ->
  post 'casLogin', {golestanNumber}

exports.autoPing = ->
  do fn = ->
    Q.all [post('ping'), Q.delay 5000]
    .fin ->
      setTimeout fn