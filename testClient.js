(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
// shim for using process in browser
var process = module.exports = {};

// cached from whatever global is present so that test runners that stub it
// don't break things.  But we need to wrap it in a try catch in case it is
// wrapped in strict mode code which doesn't define any globals.  It's inside a
// function because try/catches deoptimize in certain engines.

var cachedSetTimeout;
var cachedClearTimeout;

function defaultSetTimout() {
    throw new Error('setTimeout has not been defined');
}
function defaultClearTimeout () {
    throw new Error('clearTimeout has not been defined');
}
(function () {
    try {
        if (typeof setTimeout === 'function') {
            cachedSetTimeout = setTimeout;
        } else {
            cachedSetTimeout = defaultSetTimout;
        }
    } catch (e) {
        cachedSetTimeout = defaultSetTimout;
    }
    try {
        if (typeof clearTimeout === 'function') {
            cachedClearTimeout = clearTimeout;
        } else {
            cachedClearTimeout = defaultClearTimeout;
        }
    } catch (e) {
        cachedClearTimeout = defaultClearTimeout;
    }
} ())
function runTimeout(fun) {
    if (cachedSetTimeout === setTimeout) {
        //normal enviroments in sane situations
        return setTimeout(fun, 0);
    }
    // if setTimeout wasn't available but was latter defined
    if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
        cachedSetTimeout = setTimeout;
        return setTimeout(fun, 0);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedSetTimeout(fun, 0);
    } catch(e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
            return cachedSetTimeout.call(null, fun, 0);
        } catch(e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
            return cachedSetTimeout.call(this, fun, 0);
        }
    }


}
function runClearTimeout(marker) {
    if (cachedClearTimeout === clearTimeout) {
        //normal enviroments in sane situations
        return clearTimeout(marker);
    }
    // if clearTimeout wasn't available but was latter defined
    if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
        cachedClearTimeout = clearTimeout;
        return clearTimeout(marker);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedClearTimeout(marker);
    } catch (e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
            return cachedClearTimeout.call(null, marker);
        } catch (e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
            return cachedClearTimeout.call(this, marker);
        }
    }



}
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    if (!draining || !currentQueue) {
        return;
    }
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = runTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    runClearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        runTimeout(drainQueue);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],2:[function(require,module,exports){
var addMessage, alert, service, uppercaseFirst,
  slice = [].slice;

service = require('./utils/service');

alert = require('./singletons/alert');

uppercaseFirst = require('./utils').uppercaseFirst;

addMessage = service.extendModule(function(exports) {
  var addMessageLastRequestQ;
  addMessageLastRequestQ = void 0;
  return function(name, arg) {
    var failure, prev, success;
    success = arg.success, failure = arg.failure;
    prev = exports[name];
    return exports[name] = function() {
      var addMessageRequestQ, args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return addMessageLastRequestQ = addMessageRequestQ = prev.apply(null, args).then(function(x) {
        if (success) {
          if (typeof success === 'function') {
            alert.instance.show(success(e), true);
          } else {
            alert.instance.show(success, true);
          }
          setTimeout((function() {
            if (addMessageLastRequestQ === addMessageRequestQ) {
              return alert.instance.hide();
            }
          }), 3000);
        }
        return x;
      })["catch"](function(e) {
        if (failure) {
          if (typeof failure === 'function') {
            alert.instance.show(failure(e), false);
          } else {
            alert.instance.show(failure, false);
          }
          setTimeout((function() {
            if (addMessageLastRequestQ === addMessageRequestQ) {
              return alert.instance.hide();
            }
          }), 3000);
        }
        throw e;
      });
    };
  };
});

exports["do"] = function() {
  addMessage('reportBug', {
    success: 'گزارش خطا با موفقیت ارسال شد.'
  });
  addMessage('casLogin', {
    success: 'خوش آمدید.',
    failure: 'شماره دانشجویی / پرسنلی انتخاب شده در سیستم موجود نمی‌باشد.'
  });
  addMessage('login', {
    success: 'خوش آمدید.'
  });
  addMessage('register', {
    success: 'رمز عبور با موفقیت ذخیره شد.'
  });
  addMessage('changeEmail', {
    success: 'ایمیل با موفقیت ذخیره شد.',
    failure: 'ایمیل قبلا استفاده شده‌است.'
  });
  addMessage('setStaticData', {
    success: 'تغییرات با موفقیت ذخیره شد.'
  });
  addMessage('sendRequestForAssistant', {
    success: 'درخواست با موفقیت ارسال شد.'
  });
  addMessage('deleteRequestForAssistant', {
    success: 'درخواست با موفقیت خذف شد.'
  });
  addMessage('addRequiredCourse', {
    success: 'تغییرات با موفقیت ذخیره شد.'
  });
  addMessage('removeRequiredCourse', {
    success: 'تغییرات با موفقیت ذخیره شد.'
  });
  addMessage('closeOffering', {
    success: 'درس با موفقیت نهایی شد.'
  });
  addMessage('batchAddOfferings', {
    success: 'عملیات با موفقیت انجام شد.',
    failure: 'در انجام عملیات مشکلی پیش آمد.'
  });
  [
    {
      name: 'person',
      persianName: 'شخص'
    }, {
      name: 'course',
      persianName: 'درس'
    }, {
      name: 'offering',
      persianName: 'فراخوان'
    }
  ].forEach(function(arg) {
    var name, persianName;
    name = arg.name, persianName = arg.persianName;
    addMessage("create" + (uppercaseFirst(name)), {
      success: persianName + " با موفقیت ایجاد شد."
    });
    addMessage("update" + (uppercaseFirst(name)), {
      success: "تغییرات " + persianName + " با موفقیت ذخیره شد."
    });
    return addMessage("delete" + (uppercaseFirst(name)), {
      success: persianName + " با موفقیت حذف شد."
    });
  });
  return ['createPerson', 'updatePerson'].forEach(function(x) {
    return addMessage(x, {
      failure: function(error) {
        switch (error) {
          case 'email':
            return 'ایمیل قبلا استفاده شده است.';
          case 'golestanNumber':
            return 'شماره دانشجویی / پرسنلی قبلا استفاده شده است.';
        }
      }
    });
  });
};


},{"./singletons/alert":32,"./utils":38,"./utils/service":44}],3:[function(require,module,exports){
var component;

component = require('../utils/component');

module.exports = component('alert', function(arg) {
  var E, addClass, alert, close, dom, events, onEvent, removeClass, returnObject, setStyle, text;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, addClass = dom.addClass, removeClass = dom.removeClass, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  alert = E({
    "class": 'alert fade',
    position: 'absolute',
    top: 100,
    left: '20%',
    right: '20%'
  }, close = E('button', {
    "class": 'close',
    zIndex: 10
  }, '×'), text = E('h4'));
  onEvent(close, 'click', function() {
    return removeClass(alert, 'in');
  });
  returnObject({
    show: function(_text, isOk) {
      removeClass(alert, ['success', 'danger'].map(function(x) {
        return "alert-" + x;
      }));
      addClass(alert, ['in', "alert-" + (isOk ? 'success' : 'danger')]);
      return setStyle(text, {
        text: _text
      });
    },
    hide: function() {
      return removeClass(alert, 'in');
    }
  });
  return alert;
});


},{"../utils/component":34}],4:[function(require,module,exports){
var toPersian;

toPersian = require('../../utils').toPersian;

exports["do"] = function(arg) {
  var arrow, components, dom, events, functions, input, itemsList, onEnter, onEvent, prevInputValue, setStyle, variables;
  components = arg.components, variables = arg.variables, functions = arg.functions, dom = arg.dom, events = arg.events;
  input = components.input, arrow = components.arrow, itemsList = components.itemsList;
  setStyle = dom.setStyle;
  onEvent = events.onEvent, onEnter = events.onEnter;
  onEvent(arrow, 'click', function() {
    return input.focus();
  });
  onEvent(input, 'focus', function() {
    return input.select();
  });
  prevInputValue = '';
  onEvent(input, ['input', 'focus'], function() {
    variables.manuallySelected = true;
    if (!variables.english) {
      setStyle(input, {
        value: input.value()
      });
    }
    if (functions.getFilteredItems().length) {
      prevInputValue = input.value();
    } else {
      setStyle(input, {
        englishValue: prevInputValue
      });
    }
    itemsList.set(functions.getFilteredItems());
    return itemsList.show();
  });
  onEvent(input, 'blur', function() {
    if (itemsList.value() != null) {
      variables.selectedId = String(functions.getId(itemsList.value()));
    }
    functions.updateDropdown();
    return itemsList.hide();
  });
  onEvent(input, 'keydown', function(e) {
    var code;
    code = e.keyCode || e.which;
    switch (code) {
      case 40:
        return itemsList.goDown();
      case 38:
        return itemsList.goUp();
    }
  });
  return onEnter(input, function() {
    return input.blur();
  });
};


},{"../../utils":38}],5:[function(require,module,exports){
var textIsInSearch;

textIsInSearch = require('../../utils').textIsInSearch;

exports.create = function(arg) {
  var components, dom, functions, input, itemsList, setStyle, variables;
  components = arg.components, variables = arg.variables, dom = arg.dom;
  input = components.input, itemsList = components.itemsList;
  setStyle = dom.setStyle;
  return functions = {
    setInputValue: function(value) {
      if (variables.english) {
        return setStyle(input, {
          englishValue: value
        });
      } else {
        return setStyle(input, {
          value: value
        });
      }
    },
    getFilteredItems: function() {
      return variables.allItems.filter(function(item) {
        return textIsInSearch(functions.getTitle(item), input.value());
      });
    },
    updateDropdown: function() {
      var filteredItems, selectedItem;
      if (document.activeElement !== input.fn.element) {
        if (variables.selectedId != null) {
          selectedItem = variables.allItems.filter(function(i) {
            return String(functions.getId(i)) === variables.selectedId;
          })[0];
          if (selectedItem != null) {
            functions.setInputValue(functions.getTitle(selectedItem));
          } else {
            functions.setInputValue('');
          }
        } else {
          filteredItems = functions.getFilteredItems();
          if (filteredItems.length) {
            functions.setInputValue(functions.getTitle(filteredItems[0]));
          } else {
            functions.setInputValue('');
          }
        }
        return itemsList.set(functions.getFilteredItems());
      }
    },
    showEmpty: function(showEmpty) {
      variables.showEmpty = showEmpty;
      return functions.update(variables.items);
    },
    update: function(items) {
      variables.items = items;
      if (variables.showEmpty) {
        variables.allItems = [-1].concat(items);
      } else {
        variables.allItems = items;
      }
      return functions.updateDropdown();
    },
    reset: function() {
      variables.selectedId = null;
      variables.manuallySelected = false;
      functions.setInputValue('');
      return functions.updateDropdown();
    },
    setSelectedId: function(id) {
      if (!variables.manuallySelected) {
        variables.selectedId = String(id);
        return functions.updateDropdown();
      }
    },
    undirty: function() {
      return variables.manuallySelected = false;
    },
    value: function() {
      var ref;
      return (ref = itemsList.value()) != null ? ref : -1;
    }
  };
};


},{"../../utils":38}],6:[function(require,module,exports){
var _eventHandlers, _functions, component, extend, list, ref, style, toPersian;

component = require('../../utils/component');

style = require('./style');

list = require('./list');

_functions = require('./functions');

_eventHandlers = require('./eventHandlers');

ref = require('../../utils'), extend = ref.extend, toPersian = ref.toPersian;

module.exports = component('dropdown', function(arg, args) {
  var E, components, dom, english, events, functions, getId, getTitle, ref1, ref2, reset, returnObject, setSelectedId, setStyle, setValue, showEmpty, undirty, update, value, variables;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  if (args == null) {
    args = {};
  }
  E = dom.E, setStyle = dom.setStyle;
  getId = (ref1 = args.getId) != null ? ref1 : (function(x) {
    return x;
  }), getTitle = (ref2 = args.getTitle) != null ? ref2 : (function(x) {
    return x;
  }), english = args.english;
  variables = {
    english: english,
    items: [],
    allItems: [],
    showEmpty: false,
    selectedId: null,
    manuallySelected: false
  };
  getId = (function(getId) {
    return function(x) {
      if (x === -1) {
        return -1;
      } else {
        return getId(x);
      }
    };
  })(getId);
  getTitle = (function(getTitle) {
    return function(x) {
      if (x === -1) {
        return '';
      } else if (variables.english) {
        return getTitle(x);
      } else {
        return toPersian(getTitle(x));
      }
    };
  })(getTitle);
  components = {};
  components.dropdown = E(style.dropdown, components.input = E('input', style.input), components.arrow = E('i', style.arrow), components.itemsList = E(list, getTitle));
  functions = _functions.create({
    variables: variables,
    components: components,
    dom: dom
  });
  extend(functions, {
    getId: getId,
    getTitle: getTitle
  });
  _eventHandlers["do"]({
    components: components,
    variables: variables,
    functions: functions,
    dom: dom,
    events: events
  });
  reset = functions.reset, undirty = functions.undirty, setSelectedId = functions.setSelectedId, showEmpty = functions.showEmpty, update = functions.update, value = functions.value, setValue = functions.setValue;
  returnObject({
    reset: reset,
    undirty: undirty,
    setSelectedId: setSelectedId,
    showEmpty: showEmpty,
    update: update,
    value: value,
    setValue: setValue,
    input: components.input
  });
  return components.dropdown;
});


},{"../../utils":38,"../../utils/component":34,"./eventHandlers":4,"./functions":5,"./list":7,"./style":10}],7:[function(require,module,exports){
var compare, component, style;

component = require('../../../utils/component');

style = require('./style');

compare = require('../../../utils').compare;

module.exports = component('dropdownList', function(arg, getTitle) {
  var E, append, dom, empty, entities, events, highlightCurrentItem, index, items, list, onMouseover, returnObject, setStyle, visible;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, empty = dom.empty, append = dom.append, setStyle = dom.setStyle;
  onMouseover = events.onMouseover;
  list = E(style.list);
  entities = items = visible = index = void 0;
  highlightCurrentItem = function() {
    if (!(items != null ? items.length : void 0)) {
      return;
    }
    setStyle(items, style.item);
    return setStyle(items[index], style.highlightedItem);
  };
  returnObject({
    set: function(_entities) {
      index = 0;
      empty(list);
      entities = _entities.sort(function(a, b) {
        return compare(getTitle(a), getTitle(b));
      });
      append(list, items = entities.map(function(entity, i) {
        var item;
        item = E({
          englishText: getTitle(entity)
        });
        onMouseover(item, function() {
          if (!visible) {
            return;
          }
          index = i;
          return highlightCurrentItem();
        });
        return item;
      }));
      return highlightCurrentItem();
    },
    goUp: function() {
      index--;
      if (index < 0) {
        index = 0;
      }
      return highlightCurrentItem();
    },
    goDown: function() {
      index++;
      if (index >= entities.length) {
        index = entities.length - 1;
      }
      return highlightCurrentItem();
    },
    value: function() {
      if ((entities != null) && (index != null)) {
        return entities[index];
      }
    },
    show: function() {
      setStyle(list, style.visibleList);
      return visible = true;
    },
    hide: function() {
      setStyle(list, style.list);
      return visible = false;
    }
  });
  return list;
});


},{"../../../utils":38,"../../../utils/component":34,"./style":8}],8:[function(require,module,exports){
exports.list = {
  position: 'absolute',
  backgroundColor: 'white',
  zIndex: 1000,
  top: 30,
  left: 0,
  right: 0,
  border: '1px solid #CCC',
  borderTop: 'none',
  borderRadius: '0 0 5px 5px',
  transition: '0.1s',
  opacity: 0,
  visibility: 'hidden'
};

exports.visibleList = {
  opacity: 1,
  visibility: 'visible'
};

exports.item = {
  height: 30,
  padding: 5,
  backgroundColor: 'transparent'
};

exports.highlightedItem = {
  backgroundColor: '#8CF'
};


},{}],9:[function(require,module,exports){
var component, dropdown, extend;

component = require('../../utils/component');

dropdown = require('.');

extend = require('../../utils').extend;

module.exports = component('stateSyncedDropdown', function(arg, arg1) {
  var E, d, dom, english, getId, getTitle, reset, ret, returnObject, selectedIdStateName, showEmpty, state, stateName, undirty, value;
  dom = arg.dom, state = arg.state, returnObject = arg.returnObject;
  getId = arg1.getId, getTitle = arg1.getTitle, stateName = arg1.stateName, selectedIdStateName = arg1.selectedIdStateName, english = arg1.english;
  E = dom.E;
  d = E(dropdown, {
    getId: getId,
    getTitle: getTitle,
    english: english
  });
  state[stateName].on(function(data) {
    return d.update(data);
  });
  if (selectedIdStateName) {
    state[selectedIdStateName].on(function(id) {
      return d.setSelectedId(id);
    });
  }
  reset = d.reset, undirty = d.undirty, showEmpty = d.showEmpty, value = d.value;
  ret = {
    reset: reset,
    undirty: undirty,
    showEmpty: showEmpty,
    value: value
  };
  if (!selectedIdStateName) {
    ret.setSelectedId = d.setSelectedId;
  }
  if (d.input) {
    ret.input = d.input;
  }
  ret.revalue = function() {
    d.undirty();
    return state[selectedIdStateName].on({
      once: true
    }, function(id) {
      return d.setSelectedId(id);
    });
  };
  returnObject(ret);
  return d;
});


},{".":6,"../../utils":38,"../../utils/component":34}],10:[function(require,module,exports){
exports.dropdown = {
  position: 'relative'
};

exports.input = {
  "class": 'form-control',
  paddingLeft: 30
};

exports.arrow = {
  "class": 'fa fa-chevron-down',
  position: 'absolute',
  top: 10,
  left: 10,
  cursor: 'pointer'
};


},{}],11:[function(require,module,exports){
exports.create = function(arg) {
  var addClass, append, components, disable, dom, empty, enable, functions, hide, removeClass, setStyle, show, variables;
  variables = arg.variables, components = arg.components, dom = arg.dom;
  setStyle = dom.setStyle, append = dom.append, empty = dom.empty, hide = dom.hide, show = dom.show, enable = dom.enable, disable = dom.disable, addClass = dom.addClass, removeClass = dom.removeClass;
  return functions = {
    submit: void 0,
    close: void 0,
    setEnabled: function(enabled) {
      variables.enabled = enabled;
      if (enabled) {
        return enable(components.submit);
      } else {
        return disable(components.submit);
      }
    },
    hide: function() {
      if (typeof functions.close === "function") {
        functions.close();
      }
      return $(components.modal.fn.element).modal('hide');
    },
    display: function(arg1) {
      var autoHide, close, closeText, contents, enabled, ref, ref1, ref2, submit, submitText, submitType, title;
      autoHide = (ref = arg1.autoHide) != null ? ref : false, submit = arg1.submit, close = arg1.close, title = arg1.title, contents = arg1.contents, submitText = arg1.submitText, closeText = arg1.closeText, submitType = (ref1 = arg1.submitType) != null ? ref1 : 'primary', enabled = (ref2 = arg1.enabled) != null ? ref2 : true;
      variables.autoHide = autoHide;
      setStyle(components.title, {
        text: title
      });
      empty(components.contents);
      append(components.contents, contents);
      functions.setEnabled(enabled);
      setStyle(components.submit, {
        text: submitText
      });
      if (submitText) {
        show(components.submit);
      } else {
        hide(components.submit);
      }
      setStyle(components.close, {
        text: closeText
      });
      if (closeText) {
        show(components.close);
      } else {
        hide(components.close);
      }
      ['btn-primary', 'btn-danger'].forEach(function(klass) {
        return removeClass(components.submit, klass);
      });
      addClass(components.submit, "btn-" + submitType);
      functions.submit = submit;
      functions.close = close;
      return $(components.modal.fn.element).modal({
        keyboard: false,
        backdrop: 'static'
      });
    }
  };
};


},{}],12:[function(require,module,exports){
var Q, _functions, component;

component = require('../../utils/component');

Q = require('../../q');

_functions = require('./functions');

module.exports = component('modal', function(arg) {
  var E, components, disable, dom, events, functions, onEvent, returnObject, variables;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, disable = dom.disable;
  onEvent = events.onEvent;
  variables = {
    enabled: false,
    autoHide: false
  };
  components = {
    modal: void 0,
    title: void 0,
    contents: void 0,
    submit: void 0,
    close: void 0
  };
  components.modal = E({
    "class": 'modal fade'
  }, E('div', {
    "class": 'modal-dialog'
  }, E('div', {
    "class": 'modal-content'
  }, E('div', {
    "class": 'modal-header'
  }, E('button', {
    "class": 'close'
  }), components.title = E('h4', {
    "class": 'modal-title'
  })), components.contents = E('div', {
    "class": 'modal-body'
  }), E('div', {
    "class": 'modal-footer'
  }, components.submit = E('button', {
    "class": 'btn btn-primary'
  }), components.close = E('button', {
    "class": 'btn btn-default'
  })))));
  functions = _functions.create({
    variables: variables,
    components: components,
    dom: dom
  });
  functions.newSubmit = function() {
    if (!variables.enabled) {
      return;
    }
    if (variables.autoHide) {
      disable(components.submit);
      return Q(functions.submit()).fin(function() {
        return functions.hide();
      }).done();
    } else {
      return functions.submit();
    }
  };
  onEvent(components.close, 'click', functions.hide);
  onEvent(components.submit, 'click', functions.newSubmit);
  returnObject({
    setEnabled: functions.setEnabled,
    display: functions.display,
    submit: functions.newSubmit,
    hide: functions.hide
  });
  return components.modal;
});


},{"../../q":28,"../../utils/component":34,"./functions":11}],13:[function(require,module,exports){
var component, restrictedInput;

component = require('../../utils/component');

restrictedInput = require('.');

module.exports = component('gradeInput', function(arg, isInteger) {
  var E, dom, input, returnObject;
  dom = arg.dom, returnObject = arg.returnObject;
  E = dom.E;
  input = E(restrictedInput, /^([0-9]|[0-9]\.[0-9]?[0-9]?|1[0-9]|1[0-9]\.[0-9]?[0-9]?|20|20\.0?0?)?$/);
  returnObject({
    value: function() {
      return input.value();
    }
  });
  return input;
});


},{".":14,"../../utils/component":34}],14:[function(require,module,exports){
var component, toEnglish;

component = require('../../utils/component');

toEnglish = require('../../utils').toEnglish;

module.exports = component('restrictedInput', function(arg, regex) {
  var E, dom, events, input, onEvent, prevValue, returnObject, setStyle;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  input = E('input');
  prevValue = '';
  onEvent(input, 'input', function() {
    var value;
    value = toEnglish(input.value());
    if (regex.test(value)) {
      prevValue = value;
    } else {
      value = prevValue;
    }
    return setStyle(input, {
      value: value
    });
  });
  returnObject({
    value: function() {
      return input.value();
    }
  });
  return input;
});


},{"../../utils":38,"../../utils/component":34}],15:[function(require,module,exports){
var component, restrictedInput;

component = require('../../utils/component');

restrictedInput = require('.');

module.exports = component('numberInput', function(arg, isInteger) {
  var E, dom, input, returnObject;
  dom = arg.dom, returnObject = arg.returnObject;
  E = dom.E;
  input = E(restrictedInput, isInteger ? /^[0-9]*$/ : /^([0-9]*|[0-9]*\.[0-9]+)$/);
  returnObject({
    value: function() {
      return input.value();
    }
  });
  return input;
});


},{".":14,"../../utils/component":34}],16:[function(require,module,exports){
var collection, compare, extend, modal, ref, remove, style, toPersian;

style = require('./style');

modal = require('../../singletons/modal');

ref = require('../../utils'), extend = ref.extend, toPersian = ref.toPersian, collection = ref.collection, compare = ref.compare, remove = ref.remove;

exports.create = function(arg) {
  var E, addClass, append, components, destroy, dom, events, functions, handlers, headers, hide, onEvent, properties, removeClass, setStyle, show, variables;
  headers = arg.headers, properties = arg.properties, handlers = arg.handlers, variables = arg.variables, components = arg.components, dom = arg.dom, events = arg.events;
  E = dom.E, destroy = dom.destroy, append = dom.append, setStyle = dom.setStyle, show = dom.show, hide = dom.hide, addClass = dom.addClass, removeClass = dom.removeClass;
  onEvent = events.onEvent;
  functions = {
    cover: function() {
      return setStyle(components.cover, style.cover);
    },
    uncover: function() {
      return setStyle(components.cover, style.hiddenCover);
    },
    update: function() {
      var descriptors;
      if (variables.descriptors) {
        hide(components.noData);
        show(components.yesData);
        if (variables.sort) {
          variables.descriptors = variables.descriptors.sort(function(arg1, arg2) {
            var a, b, first, firstValue, header, ref1, ref2, result, second, secondValue;
            a = arg1.entity;
            b = arg2.entity;
            header = variables.sort.header;
            if (variables.sort.direction === 'up') {
              ref1 = [a, b], first = ref1[0], second = ref1[1];
            } else {
              ref2 = [b, a], first = ref2[0], second = ref2[1];
            }
            if (header.getValue) {
              firstValue = toPersian(header.getValue(first));
              secondValue = toPersian(header.getValue(second));
            } else {
              firstValue = toPersian(first[header.key]);
              secondValue = toPersian(second[header.key]);
            }
            result = compare(firstValue, secondValue);
            if (result === 0 && variables.entityId) {
              return compare(first[variables.entityId], second[variables.entityId]);
            } else {
              return result;
            }
          });
        }
      }
      descriptors = variables.descriptors || [];
      variables.selectionMode = descriptors.some(function(arg1) {
        var selected;
        selected = arg1.selected;
        return selected;
      });
      functions.handleRows(descriptors);
      return handlers.update(descriptors);
    },
    setData: function(entities) {
      if (!variables.descriptors) {
        variables.descriptors = entities.map(function(entity) {
          return {
            entity: entity
          };
        });
      } else {
        variables.descriptors = entities.map(function(entity) {
          var returnValue, shouldReturn;
          returnValue = void 0;
          shouldReturn = variables.descriptors.some(function(x) {
            if (functions.isEqual(entity, x.entity)) {
              returnValue = x;
              return true;
            }
          });
          if (shouldReturn) {
            return returnValue;
          } else {
            return {
              entity: entity
            };
          }
        });
      }
      return functions.update();
    },
    setSelectedRows: function(callback) {
      variables.descriptors.forEach(function(descriptor) {
        return descriptor.selected = false;
      });
      callback(variables.descriptors).forEach(function(descriptor) {
        return descriptor.selected = true;
      });
      return functions.update();
    },
    setSort: function(header) {
      var sort;
      headers.forEach(function(arg1) {
        var arrow;
        arrow = arg1.arrow;
        return hide(arrow);
      });
      show(header.arrow);
      sort = variables.sort;
      if ((sort != null ? sort.header : void 0) === header && sort.direction === 'up') {
        setStyle(header.arrow, {
          "class": 'fa fa-caret-down'
        });
        sort.direction = 'down';
      } else {
        setStyle(header.arrow, {
          "class": 'fa fa-caret-up'
        });
        variables.sort = {
          header: header,
          direction: 'up'
        };
      }
      return functions.update();
    },
    getRowTdValue: function(entity, header) {
      if (header.key) {
        return entity[header.key];
      } else if (header.getValue) {
        return header.getValue(entity);
      }
    },
    styleTd: function(header, arg1, td, offs) {
      var entity;
      entity = arg1.entity;
      if (header.key || header.getValue) {
        setStyle(td, {
          text: functions.getRowTdValue(entity, header)
        });
      }
      if (header.styleTd) {
        header.styleTd(entity, td, offs);
      }
      return td;
    },
    setupRow: function(row, descriptor) {
      var notClickableTds;
      row.off = function() {
        row.offs.forEach(function(x) {
          return x();
        });
        return row.offs = [];
      };
      setStyle(row.checkbox, {
        checked: !!descriptor.selected
      });
      setStyle(row.tr, {
        "class": descriptor.selected ? 'info' : ''
      });
      if (handlers.select && !descriptor.unselectable) {
        row.offs.push(onEvent(row.tr, 'mousemove', function() {
          if (!variables.selectionMode || descriptor.selected) {
            return addClass(row.tr, 'info');
          } else {
            return removeClass(row.tr, 'info');
          }
        }));
        row.offs.push(onEvent(row.tr, 'mouseout', function() {
          if (variables.selectionMode && descriptor.selected) {
            return addClass(row.tr, 'info');
          } else {
            return removeClass(row.tr, 'info');
          }
        }));
      }
      if (properties.multiSelect) {
        row.offs.push(onEvent(row.checkbox, 'change', function() {
          descriptor.selected = row.checkbox.checked();
          return functions.update();
        }));
      }
      if (handlers.select && !descriptor.unselectable) {
        row.tds.forEach(function(td) {
          return setStyle(td, {
            cursor: 'pointer'
          });
        });
        notClickableTds = row.tds.filter(function(_, i) {
          return headers[i].notClickable;
        });
        row.offs.push(onEvent(row.tr, 'click', notClickableTds.concat(row.checkboxTd), function() {
          return handlers.select(descriptor.entity);
        }));
      }
      return row;
    },
    addRow: function(descriptor) {
      var row;
      row = {
        offs: []
      };
      append(components.body, row.tr = E('tr', null, properties.multiSelect ? row.checkboxTd = E('td', null, row.checkbox = E('input', {
        type: 'checkbox'
      })) : void 0, row.tds = headers.map(function(header) {
        return functions.styleTd(header, descriptor, E('td'), row.offs);
      })));
      return functions.setupRow(row, descriptor);
    },
    changeRow: function(descriptor, row) {
      row.off();
      row.tds.forEach(function(td, index) {
        return functions.styleTd(headers[index], descriptor, td, row.offs);
      });
      return functions.setupRow(row, descriptor);
    },
    removeRow: function(row) {
      row.off();
      return destroy(row.tr);
    }
  };
  functions.handleRows = collection(functions.addRow, functions.removeRow, functions.changeRow);
  return functions;
};


},{"../../singletons/modal":33,"../../utils":38,"./style":19}],17:[function(require,module,exports){
var _functions, component, extend, style;

component = require('../../utils/component');

style = require('./style');

_functions = require('./functions');

extend = require('../../utils').extend;

module.exports = component('table', function(arg, arg1) {
  var E, components, dom, entityId, events, functions, handlers, hasSearchBoxes, headers, hide, isEqual, onEvent, properties, ref, ref1, returnObject, sort, table, text, variables;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  headers = arg1.headers, entityId = arg1.entityId, isEqual = arg1.isEqual, sort = arg1.sort, properties = (ref = arg1.properties) != null ? ref : {}, handlers = (ref1 = arg1.handlers) != null ? ref1 : {};
  E = dom.E, text = dom.text, hide = dom.hide;
  onEvent = events.onEvent;
  hasSearchBoxes = headers.some(function(header) {
    return header.searchBox;
  });
  if (entityId == null) {
    entityId = 'id';
  }
  if (isEqual == null) {
    isEqual = function(a, b) {
      return a[entityId] === b[entityId];
    };
  }
  variables = {
    entityId: entityId,
    headers: [],
    descriptors: null,
    sort: sort || {
      header: headers[0],
      direction: 'up'
    }
  };
  components = {};
  functions = _functions.create({
    headers: headers,
    properties: properties,
    handlers: handlers,
    variables: variables,
    components: components,
    dom: dom,
    events: events
  });
  extend(functions, {
    isEqual: isEqual
  });
  table = E({
    position: 'relative'
  }, components.noData = E(null, 'در حال بارگزاری...'), hide(components.yesData = E(null, E('table', {
    "class": 'table table-bordered ' + (properties.notStriped ? '' : 'table-striped')
  }, E('thead', null, E('tr', null, properties.multiSelect ? E('th', {
    width: 20
  }) : void 0, headers.map(function(header) {
    var th;
    th = E('th', style.th, header.arrow = E(style.arrow), hasSearchBoxes ? [E(style.headerWithSearchBox, header.name), header.searchBox] : text(header.name));
    if (header.key || header.getValue) {
      onEvent(th, 'click', header.searchBox, function() {
        return functions.setSort(header);
      });
    }
    return th;
  }))), components.body = E('tbody', null)))), components.cover = E(style.cover));
  functions.uncover();
  returnObject({
    cover: functions.cover,
    uncover: functions.uncover,
    setData: functions.setData,
    setSelectedRows: functions.setSelectedRows
  });
  return table;
});


},{"../../utils":38,"../../utils/component":34,"./functions":16,"./style":19}],18:[function(require,module,exports){
var extend;

extend = require('../../utils').extend;

exports.font = {
  fontWeight: 'normal'
};

exports.input = {
  marginTop: 20,
  "class": 'form-control',
  placeholder: 'جستجو...'
};

exports.textbox = extend({}, exports.font, exports.input);


},{"../../utils":38}],19:[function(require,module,exports){
exports.arrow = {
  color: '#229',
  cursor: 'pointer',
  position: 'absolute',
  top: 5,
  left: 5
};

exports.cover = {
  position: 'absolute',
  top: 0,
  left: 0,
  right: 0,
  bottom: 0,
  backgroundColor: 'white',
  transition: '0.5s',
  opacity: 0.5,
  visibility: 'visible'
};

exports.hiddenCover = {
  opacity: 0,
  visibility: 'hidden'
};

exports.th = {
  position: 'relative',
  minWidth: 100,
  cursor: 'pointer',
  paddingLeft: 15
};

exports.headerWithSearchBox = {
  position: 'absolute',
  top: 5,
  cursor: 'pointer'
};


},{}],20:[function(require,module,exports){
var addPageCSS, addPageStyle, ref;

ref = require('./utils/dom'), addPageCSS = ref.addPageCSS, addPageStyle = ref.addPageStyle;

exports["do"] = function() {
  addPageCSS('font-awesome/css/font-awesome.css');
  addPageCSS('bootstrap.css');
  addPageCSS('bootstrap-rtl.css');
  return addPageStyle("@font-face { font-family: 'yekan'; src: url('assets/yekan/yekan.ttf'), url('assets/yekan/yekan.woff'), url('assets/yekan/yekan.eot'); } * { direction: rtl; -webkit-user-select: none; /* Chrome/Safari */ -moz-user-select: none; /* Firefox */ -ms-user-select: none; /* IE10+ */ -o-user-select: none; user-select: none; cursor: default; } input, textarea { cursor: text; } input[type='checkbox'] { cursor: pointer; } body { font-family: 'yekan', tahoma; height: 100%; overflow-x: hidden; } .hidden { display: 'none'; } .alert { padding: 0; margin-bottom: 0; height: 0; transition: all .15s linear } .alert.in { padding: 15px; margin-bottom: 20px; height: auto; }");
};


},{"./utils/dom":36}],21:[function(require,module,exports){
var Q, component, extend, generateId, modal, style;

component = require('../../utils/component');

modal = require('../../singletons/modal');

style = require('./style');

Q = require('../../q');

generateId = require('../../utils/dom').generateId;

extend = require('../../utils').extend;

module.exports = component('bugReport', function(arg) {
  var E, bugReport, contents, dom, events, id, onEvent, service, setStyle, state, textbox;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  bugReport = E(style.bugReport, 'گزارش خطا');
  contents = E({
    "class": 'form-group'
  }, E('label', {
    "for": id = generateId()
  }, 'توضیحات خطای رخ داده (در صورت تمایل، به منظور ارتباط، نام، ایمیل و شماره دانشجویی / پرسنلی خود را بنویسید.)'), textbox = E('textarea', extend({
    id: id
  }, style.bugReportTextbox)));
  onEvent(textbox, 'input', function() {
    return modal.instance.setEnabled(textbox.value());
  });
  onEvent(bugReport, 'click', function() {
    setStyle(textbox, {
      value: ''
    });
    return modal.instance.display({
      enabled: false,
      autoHide: true,
      title: 'گزارش خطا',
      submitText: 'ثبت',
      closeText: 'بستن',
      contents: contents,
      submit: function() {
        return Q.Promise(function(resolve) {
          disable(textbox);
          return state.person.on({
            once: true,
            allowNull: true
          }, function(person) {
            return resolve(service.reportBug({
              description: textbox.value(),
              platform: JSON.stringify(window.platform),
              person: JSON.stringify(person)
            })).then(function() {
              return enable(textbox);
            })["catch"](function() {
              return enable(textbox);
            });
          });
        });
      }
    });
  });
  return bugReport;
});


},{"../../q":28,"../../singletons/modal":33,"../../utils":38,"../../utils/component":34,"../../utils/dom":36,"./style":22}],22:[function(require,module,exports){
exports.bugReport = {
  color: '#51445f',
  cursor: 'pointer',
  position: 'absolute',
  width: 100,
  top: 80
};

exports.bugReportTextbox = {
  "class": 'form-control',
  minHeight: 100,
  minWidth: '100%',
  maxWidth: '100%'
};


},{}],23:[function(require,module,exports){
var body, component, document, emailIsValid, ref, style;

component = require('../../utils/component');

style = require('./style');

emailIsValid = require('../../utils/logic').emailIsValid;

ref = require('../../utils/dom'), document = ref.document, body = ref.body;

module.exports = component('navbarEmail', function(arg, arg1) {
  var E, container, content, currentEmail, disable, doSubmit, dom, enable, enabled, events, hid, hidePopover, icon, input, onEnter, onEvent, returnObject, service, setEnabled, setStyle, show, showPopover, state, submit;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, returnObject = arg.returnObject;
  container = arg1.container;
  E = dom.E, setStyle = dom.setStyle, show = dom.show, hid = dom.hid, enable = dom.enable, disable = dom.disable;
  onEvent = events.onEvent, onEnter = events.onEnter;
  currentEmail = void 0;
  enabled = false;
  icon = E(style.icon);
  content = E(style.content, input = E('input', style.input), submit = E('button', style.submit, 'تغییر ایمیل'));
  setEnabled = function() {
    enabled = input.value() && emailIsValid(input.value());
    if (enabled) {
      return enable(submit);
    } else {
      return disable(submit);
    }
  };
  $(icon.fn.element).popover({
    title: 'مشاهده/ویرایش ایمیل',
    trigger: 'manual',
    html: true,
    container: container,
    content: function() {
      setStyle(input, {
        value: currentEmail
      });
      setEnabled();
      return content.fn.element;
    }
  });
  showPopover = function() {
    return $(icon.fn.element).popover('show');
  };
  hidePopover = function() {
    return $(icon.fn.element).popover('hide');
  };
  onEvent(input, 'input', setEnabled);
  onEvent(icon, 'click', showPopover);
  onEvent(E(document), 'click', function(e) {
    var element;
    if (!currentEmail) {
      return;
    }
    element = e.target;
    while (element !== null && element !== E(body).fn.element) {
      if (element === icon.fn.element || ~((typeof element.getAttribute === "function" ? element.getAttribute('class') : void 0) || '').indexOf('popover')) {
        return;
      }
      element = element.parentNode;
    }
    return hidePopover();
  });
  doSubmit = function() {
    if (!enabled) {
      return;
    }
    disable(submit);
    return service.changeEmail({
      email: input.value()
    }).then(function() {
      hidePopover();
      return enable(submit);
    });
  };
  onEvent(submit, 'click', doSubmit);
  onEnter(input, doSubmit);
  state.person.on({
    allowNull: true
  }, function(person) {
    if (person) {
      currentEmail = person.email;
      setEnabled();
      if (!currentEmail) {
        return setTimeout(showPopover);
      }
    }
  });
  returnObject({
    hidePopover: hidePopover
  });
  return icon;
});


},{"../../utils/component":34,"../../utils/dom":36,"../../utils/logic":40,"./style":24}],24:[function(require,module,exports){
exports.icon = {
  "class": 'fa fa-envelope',
  marginLeft: 20,
  cursor: 'pointer'
};

exports.content = {
  "class": 'from-group',
  width: 245
};

exports.input = {
  "class": 'form-control',
  direction: 'ltr'
};

exports.submit = {
  "class": 'btn btn-primary',
  marginTop: 10
};


},{}],25:[function(require,module,exports){
var bugReport, component, email, style;

component = require('../utils/component');

style = require('./style');

email = require('./email');

bugReport = require('./bugReport');

module.exports = component('navbar', function(arg) {
  var E, append, dom, emailBox, events, hide, logout, navbar, onEvent, personBox, personName, service, setStyle, show, state;
  dom = arg.dom, events = arg.events, service = arg.service, state = arg.state;
  E = dom.E, append = dom.append, setStyle = dom.setStyle, show = dom.show, hide = dom.hide;
  onEvent = events.onEvent;
  navbar = E(style.navbar, E(style.wrapper, E(style.title, 'سامانه مدیریت دستیاران آموزشی'), E(style.betaDisclaimer, '- نسخه آزمایشی'), E(bugReport), personBox = E(style.personBox)));
  append(personBox, [
    emailBox = E(email, {
      container: personBox.fn.element
    }), personName = E(style.personName), logout = E('a', style.logout, 'خروج')
  ]);
  onEvent(logout, 'click', function() {
    emailBox.hidePopover();
    return service.logout();
  });
  state.person.on({
    allowNull: true
  }, function(person) {
    if (person) {
      setStyle(personName, {
        text: person.fullName
      });
      return show(personBox);
    } else {
      return hide(personBox);
    }
  });
  return navbar;
});


},{"../utils/component":34,"./bugReport":21,"./email":23,"./style":26}],26:[function(require,module,exports){
exports.navbar = {
  minWidth: 1000,
  backgroundColor: '#51445f',
  height: 80,
  color: '#CBC7CF',
  padding: 7,
  position: 'relative'
};

exports.title = {
  display: 'inline-block',
  lineHeight: '64px',
  marginTop: 5,
  fontSize: 30
};

exports.betaDisclaimer = {
  display: 'inline-block',
  marginRight: 5
};

exports.wrapper = {
  width: 1000,
  margin: '0 auto'
};

exports.personBox = {
  position: 'relative',
  float: 'left',
  marginTop: 22
};

exports.personName = {
  display: 'inline-block'
};

exports.logout = {
  color: '#e05d6f',
  marginRight: 10,
  cursor: 'pointer'
};


},{}],27:[function(require,module,exports){
var alert, body, component, modal, navbar, singletonAlert, singletonModal, views;

component = require('./utils/component');

navbar = require('./navbar');

views = require('./views');

alert = require('./components/alert');

modal = require('./components/modal');

singletonAlert = require('./singletons/alert');

singletonModal = require('./singletons/modal');

body = require('./utils/dom').body;

module.exports = component('page', function(arg) {
  var E, alertE, append, dom, modalE;
  dom = arg.dom;
  E = dom.E, append = dom.append;
  append(E(body), E(navbar));
  append(E(body), E(views));
  append(E(body), alertE = E(alert));
  append(E(body), modalE = E(modal));
  singletonAlert.set(alertE);
  return singletonModal.set(modalE);
});


},{"./components/alert":3,"./components/modal":12,"./navbar":25,"./singletons/alert":32,"./singletons/modal":33,"./utils/component":34,"./utils/dom":36,"./views":71}],28:[function(require,module,exports){
(function (process){
// vim:ts=4:sts=4:sw=4:
/*!
 *
 * Copyright 2009-2012 Kris Kowal under the terms of the MIT
 * license found at http://github.com/kriskowal/q/raw/master/LICENSE
 *
 * With parts by Tyler Close
 * Copyright 2007-2009 Tyler Close under the terms of the MIT X license found
 * at http://www.opensource.org/licenses/mit-license.html
 * Forked at ref_send.js version: 2009-05-11
 *
 * With parts by Mark Miller
 * Copyright (C) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

(function (definition) {
    "use strict";

    // This file will function properly as a <script> tag, or a module
    // using CommonJS and NodeJS or RequireJS module formats.  In
    // Common/Node/RequireJS, the module exports the Q API and when
    // executed as a simple <script>, it creates a Q global instead.

    // Montage Require
    if (typeof bootstrap === "function") {
        bootstrap("promise", definition);

    // CommonJS
    } else if (typeof exports === "object" && typeof module === "object") {
        module.exports = definition();

    // RequireJS
    } else if (typeof define === "function" && define.amd) {
        define(definition);

    // SES (Secure EcmaScript)
    } else if (typeof ses !== "undefined") {
        if (!ses.ok()) {
            return;
        } else {
            ses.makeQ = definition;
        }

    // <script>
    } else if (typeof window !== "undefined" || typeof self !== "undefined") {
        // Prefer window over self for add-on scripts. Use self for
        // non-windowed contexts.
        var global = typeof window !== "undefined" ? window : self;

        // Get the `window` object, save the previous Q global
        // and initialize Q as a global.
        var previousQ = global.Q;
        global.Q = definition();

        // Add a noConflict function so Q can be removed from the
        // global namespace.
        global.Q.noConflict = function () {
            global.Q = previousQ;
            return this;
        };

    } else {
        throw new Error("This environment was not anticipated by Q. Please file a bug.");
    }

})(function () {
"use strict";

var hasStacks = false;
try {
    throw new Error();
} catch (e) {
    hasStacks = !!e.stack;
}

// All code after this point will be filtered from stack traces reported
// by Q.
var qStartingLine = captureLine();
var qFileName;

// shims

// used for fallback in "allResolved"
var noop = function () {};

// Use the fastest possible means to execute a task in a future turn
// of the event loop.
var nextTick =(function () {
    // linked list of tasks (single, with head node)
    var head = {task: void 0, next: null};
    var tail = head;
    var flushing = false;
    var requestTick = void 0;
    var isNodeJS = false;
    // queue for late tasks, used by unhandled rejection tracking
    var laterQueue = [];

    function flush() {
        /* jshint loopfunc: true */
        var task, domain;

        while (head.next) {
            head = head.next;
            task = head.task;
            head.task = void 0;
            domain = head.domain;

            if (domain) {
                head.domain = void 0;
                domain.enter();
            }
            runSingle(task, domain);

        }
        while (laterQueue.length) {
            task = laterQueue.pop();
            runSingle(task);
        }
        flushing = false;
    }
    // runs a single function in the async queue
    function runSingle(task, domain) {
        try {
            task();

        } catch (e) {
            if (isNodeJS) {
                // In node, uncaught exceptions are considered fatal errors.
                // Re-throw them synchronously to interrupt flushing!

                // Ensure continuation if the uncaught exception is suppressed
                // listening "uncaughtException" events (as domains does).
                // Continue in next event to avoid tick recursion.
                if (domain) {
                    domain.exit();
                }
                setTimeout(flush, 0);
                if (domain) {
                    domain.enter();
                }

                throw e;

            } else {
                // In browsers, uncaught exceptions are not fatal.
                // Re-throw them asynchronously to avoid slow-downs.
                setTimeout(function () {
                    throw e;
                }, 0);
            }
        }

        if (domain) {
            domain.exit();
        }
    }

    nextTick = function (task) {
        tail = tail.next = {
            task: task,
            domain: isNodeJS && process.domain,
            next: null
        };

        if (!flushing) {
            flushing = true;
            requestTick();
        }
    };

    if (typeof process === "object" &&
        process.toString() === "[object process]" && process.nextTick) {
        // Ensure Q is in a real Node environment, with a `process.nextTick`.
        // To see through fake Node environments:
        // * Mocha test runner - exposes a `process` global without a `nextTick`
        // * Browserify - exposes a `process.nexTick` function that uses
        //   `setTimeout`. In this case `setImmediate` is preferred because
        //    it is faster. Browserify's `process.toString()` yields
        //   "[object Object]", while in a real Node environment
        //   `process.nextTick()` yields "[object process]".
        isNodeJS = true;

        requestTick = function () {
            process.nextTick(flush);
        };

    } else if (typeof setImmediate === "function") {
        // In IE10, Node.js 0.9+, or https://github.com/NobleJS/setImmediate
        if (typeof window !== "undefined") {
            requestTick = setImmediate.bind(window, flush);
        } else {
            requestTick = function () {
                setImmediate(flush);
            };
        }

    } else if (typeof MessageChannel !== "undefined") {
        // modern browsers
        // http://www.nonblocking.io/2011/06/windownexttick.html
        var channel = new MessageChannel();
        // At least Safari Version 6.0.5 (8536.30.1) intermittently cannot create
        // working message ports the first time a page loads.
        channel.port1.onmessage = function () {
            requestTick = requestPortTick;
            channel.port1.onmessage = flush;
            flush();
        };
        var requestPortTick = function () {
            // Opera requires us to provide a message payload, regardless of
            // whether we use it.
            channel.port2.postMessage(0);
        };
        requestTick = function () {
            setTimeout(flush, 0);
            requestPortTick();
        };

    } else {
        // old browsers
        requestTick = function () {
            setTimeout(flush, 0);
        };
    }
    // runs a task after all other tasks have been run
    // this is useful for unhandled rejection tracking that needs to happen
    // after all `then`d tasks have been run.
    nextTick.runAfter = function (task) {
        laterQueue.push(task);
        if (!flushing) {
            flushing = true;
            requestTick();
        }
    };
    return nextTick;
})();

// Attempt to make generics safe in the face of downstream
// modifications.
// There is no situation where this is necessary.
// If you need a security guarantee, these primordials need to be
// deeply frozen anyway, and if you don’t need a security guarantee,
// this is just plain paranoid.
// However, this **might** have the nice side-effect of reducing the size of
// the minified code by reducing x.call() to merely x()
// See Mark Miller’s explanation of what this does.
// http://wiki.ecmascript.org/doku.php?id=conventions:safe_meta_programming
var call = Function.call;
function uncurryThis(f) {
    return function () {
        return call.apply(f, arguments);
    };
}
// This is equivalent, but slower:
// uncurryThis = Function_bind.bind(Function_bind.call);
// http://jsperf.com/uncurrythis

var array_slice = uncurryThis(Array.prototype.slice);

var array_reduce = uncurryThis(
    Array.prototype.reduce || function (callback, basis) {
        var index = 0,
            length = this.length;
        // concerning the initial value, if one is not provided
        if (arguments.length === 1) {
            // seek to the first value in the array, accounting
            // for the possibility that is is a sparse array
            do {
                if (index in this) {
                    basis = this[index++];
                    break;
                }
                if (++index >= length) {
                    throw new TypeError();
                }
            } while (1);
        }
        // reduce
        for (; index < length; index++) {
            // account for the possibility that the array is sparse
            if (index in this) {
                basis = callback(basis, this[index], index);
            }
        }
        return basis;
    }
);

var array_indexOf = uncurryThis(
    Array.prototype.indexOf || function (value) {
        // not a very good shim, but good enough for our one use of it
        for (var i = 0; i < this.length; i++) {
            if (this[i] === value) {
                return i;
            }
        }
        return -1;
    }
);

var array_map = uncurryThis(
    Array.prototype.map || function (callback, thisp) {
        var self = this;
        var collect = [];
        array_reduce(self, function (undefined, value, index) {
            collect.push(callback.call(thisp, value, index, self));
        }, void 0);
        return collect;
    }
);

var object_create = Object.create || function (prototype) {
    function Type() { }
    Type.prototype = prototype;
    return new Type();
};

var object_hasOwnProperty = uncurryThis(Object.prototype.hasOwnProperty);

var object_keys = Object.keys || function (object) {
    var keys = [];
    for (var key in object) {
        if (object_hasOwnProperty(object, key)) {
            keys.push(key);
        }
    }
    return keys;
};

var object_toString = uncurryThis(Object.prototype.toString);

function isObject(value) {
    return value === Object(value);
}

// generator related shims

// FIXME: Remove this function once ES6 generators are in SpiderMonkey.
function isStopIteration(exception) {
    return (
        object_toString(exception) === "[object StopIteration]" ||
        exception instanceof QReturnValue
    );
}

// FIXME: Remove this helper and Q.return once ES6 generators are in
// SpiderMonkey.
var QReturnValue;
if (typeof ReturnValue !== "undefined") {
    QReturnValue = ReturnValue;
} else {
    QReturnValue = function (value) {
        this.value = value;
    };
}

// long stack traces

var STACK_JUMP_SEPARATOR = "From previous event:";

function makeStackTraceLong(error, promise) {
    // If possible, transform the error stack trace by removing Node and Q
    // cruft, then concatenating with the stack trace of `promise`. See #57.
    if (hasStacks &&
        promise.stack &&
        typeof error === "object" &&
        error !== null &&
        error.stack &&
        error.stack.indexOf(STACK_JUMP_SEPARATOR) === -1
    ) {
        var stacks = [];
        for (var p = promise; !!p; p = p.source) {
            if (p.stack) {
                stacks.unshift(p.stack);
            }
        }
        stacks.unshift(error.stack);

        var concatedStacks = stacks.join("\n" + STACK_JUMP_SEPARATOR + "\n");
        error.stack = filterStackString(concatedStacks);
    }
}

function filterStackString(stackString) {
    var lines = stackString.split("\n");
    var desiredLines = [];
    for (var i = 0; i < lines.length; ++i) {
        var line = lines[i];

        if (!isInternalFrame(line) && !isNodeFrame(line) && line) {
            desiredLines.push(line);
        }
    }
    return desiredLines.join("\n");
}

function isNodeFrame(stackLine) {
    return stackLine.indexOf("(module.js:") !== -1 ||
           stackLine.indexOf("(node.js:") !== -1;
}

function getFileNameAndLineNumber(stackLine) {
    // Named functions: "at functionName (filename:lineNumber:columnNumber)"
    // In IE10 function name can have spaces ("Anonymous function") O_o
    var attempt1 = /at .+ \((.+):(\d+):(?:\d+)\)$/.exec(stackLine);
    if (attempt1) {
        return [attempt1[1], Number(attempt1[2])];
    }

    // Anonymous functions: "at filename:lineNumber:columnNumber"
    var attempt2 = /at ([^ ]+):(\d+):(?:\d+)$/.exec(stackLine);
    if (attempt2) {
        return [attempt2[1], Number(attempt2[2])];
    }

    // Firefox style: "function@filename:lineNumber or @filename:lineNumber"
    var attempt3 = /.*@(.+):(\d+)$/.exec(stackLine);
    if (attempt3) {
        return [attempt3[1], Number(attempt3[2])];
    }
}

function isInternalFrame(stackLine) {
    var fileNameAndLineNumber = getFileNameAndLineNumber(stackLine);

    if (!fileNameAndLineNumber) {
        return false;
    }

    var fileName = fileNameAndLineNumber[0];
    var lineNumber = fileNameAndLineNumber[1];

    return fileName === qFileName &&
        lineNumber >= qStartingLine &&
        lineNumber <= qEndingLine;
}

// discover own file name and line number range for filtering stack
// traces
function captureLine() {
    if (!hasStacks) {
        return;
    }

    try {
        throw new Error();
    } catch (e) {
        var lines = e.stack.split("\n");
        var firstLine = lines[0].indexOf("@") > 0 ? lines[1] : lines[2];
        var fileNameAndLineNumber = getFileNameAndLineNumber(firstLine);
        if (!fileNameAndLineNumber) {
            return;
        }

        qFileName = fileNameAndLineNumber[0];
        return fileNameAndLineNumber[1];
    }
}

function deprecate(callback, name, alternative) {
    return function () {
        if (typeof console !== "undefined" &&
            typeof console.warn === "function") {
            console.warn(name + " is deprecated, use " + alternative +
                         " instead.", new Error("").stack);
        }
        return callback.apply(callback, arguments);
    };
}

// end of shims
// beginning of real work

/**
 * Constructs a promise for an immediate reference, passes promises through, or
 * coerces promises from different systems.
 * @param value immediate reference or promise
 */
function Q(value) {
    // If the object is already a Promise, return it directly.  This enables
    // the resolve function to both be used to created references from objects,
    // but to tolerably coerce non-promises to promises.
    if (value instanceof Promise) {
        return value;
    }

    // assimilate thenables
    if (isPromiseAlike(value)) {
        return coerce(value);
    } else {
        return fulfill(value);
    }
}
Q.resolve = Q;

/**
 * Performs a task in a future turn of the event loop.
 * @param {Function} task
 */
Q.nextTick = nextTick;

/**
 * Controls whether or not long stack traces will be on
 */
Q.longStackSupport = false;

// enable long stacks if Q_DEBUG is set
if (typeof process === "object" && process && process.env && process.env.Q_DEBUG) {
    Q.longStackSupport = true;
}

/**
 * Constructs a {promise, resolve, reject} object.
 *
 * `resolve` is a callback to invoke with a more resolved value for the
 * promise. To fulfill the promise, invoke `resolve` with any value that is
 * not a thenable. To reject the promise, invoke `resolve` with a rejected
 * thenable, or invoke `reject` with the reason directly. To resolve the
 * promise to another thenable, thus putting it in the same state, invoke
 * `resolve` with that other thenable.
 */
Q.defer = defer;
function defer() {
    // if "messages" is an "Array", that indicates that the promise has not yet
    // been resolved.  If it is "undefined", it has been resolved.  Each
    // element of the messages array is itself an array of complete arguments to
    // forward to the resolved promise.  We coerce the resolution value to a
    // promise using the `resolve` function because it handles both fully
    // non-thenable values and other thenables gracefully.
    var messages = [], progressListeners = [], resolvedPromise;

    var deferred = object_create(defer.prototype);
    var promise = object_create(Promise.prototype);

    promise.promiseDispatch = function (resolve, op, operands) {
        var args = array_slice(arguments);
        if (messages) {
            messages.push(args);
            if (op === "when" && operands[1]) { // progress operand
                progressListeners.push(operands[1]);
            }
        } else {
            Q.nextTick(function () {
                resolvedPromise.promiseDispatch.apply(resolvedPromise, args);
            });
        }
    };

    // XXX deprecated
    promise.valueOf = function () {
        if (messages) {
            return promise;
        }
        var nearerValue = nearer(resolvedPromise);
        if (isPromise(nearerValue)) {
            resolvedPromise = nearerValue; // shorten chain
        }
        return nearerValue;
    };

    promise.inspect = function () {
        if (!resolvedPromise) {
            return { state: "pending" };
        }
        return resolvedPromise.inspect();
    };

    if (Q.longStackSupport && hasStacks) {
        try {
            throw new Error();
        } catch (e) {
            // NOTE: don't try to use `Error.captureStackTrace` or transfer the
            // accessor around; that causes memory leaks as per GH-111. Just
            // reify the stack trace as a string ASAP.
            //
            // At the same time, cut off the first line; it's always just
            // "[object Promise]\n", as per the `toString`.
            promise.stack = e.stack.substring(e.stack.indexOf("\n") + 1);
        }
    }

    // NOTE: we do the checks for `resolvedPromise` in each method, instead of
    // consolidating them into `become`, since otherwise we'd create new
    // promises with the lines `become(whatever(value))`. See e.g. GH-252.

    function become(newPromise) {
        resolvedPromise = newPromise;
        promise.source = newPromise;

        array_reduce(messages, function (undefined, message) {
            Q.nextTick(function () {
                newPromise.promiseDispatch.apply(newPromise, message);
            });
        }, void 0);

        messages = void 0;
        progressListeners = void 0;
    }

    deferred.promise = promise;
    deferred.resolve = function (value) {
        if (resolvedPromise) {
            return;
        }

        become(Q(value));
    };

    deferred.fulfill = function (value) {
        if (resolvedPromise) {
            return;
        }

        become(fulfill(value));
    };
    deferred.reject = function (reason) {
        if (resolvedPromise) {
            return;
        }

        become(reject(reason));
    };
    deferred.notify = function (progress) {
        if (resolvedPromise) {
            return;
        }

        array_reduce(progressListeners, function (undefined, progressListener) {
            Q.nextTick(function () {
                progressListener(progress);
            });
        }, void 0);
    };

    return deferred;
}

/**
 * Creates a Node-style callback that will resolve or reject the deferred
 * promise.
 * @returns a nodeback
 */
defer.prototype.makeNodeResolver = function () {
    var self = this;
    return function (error, value) {
        if (error) {
            self.reject(error);
        } else if (arguments.length > 2) {
            self.resolve(array_slice(arguments, 1));
        } else {
            self.resolve(value);
        }
    };
};

/**
 * @param resolver {Function} a function that returns nothing and accepts
 * the resolve, reject, and notify functions for a deferred.
 * @returns a promise that may be resolved with the given resolve and reject
 * functions, or rejected by a thrown exception in resolver
 */
Q.Promise = promise; // ES6
Q.promise = promise;
function promise(resolver) {
    if (typeof resolver !== "function") {
        throw new TypeError("resolver must be a function.");
    }
    var deferred = defer();
    try {
        resolver(deferred.resolve, deferred.reject, deferred.notify);
    } catch (reason) {
        deferred.reject(reason);
    }
    return deferred.promise;
}

promise.race = race; // ES6
promise.all = all; // ES6
promise.reject = reject; // ES6
promise.resolve = Q; // ES6

// XXX experimental.  This method is a way to denote that a local value is
// serializable and should be immediately dispatched to a remote upon request,
// instead of passing a reference.
Q.passByCopy = function (object) {
    //freeze(object);
    //passByCopies.set(object, true);
    return object;
};

Promise.prototype.passByCopy = function () {
    //freeze(object);
    //passByCopies.set(object, true);
    return this;
};

/**
 * If two promises eventually fulfill to the same value, promises that value,
 * but otherwise rejects.
 * @param x {Any*}
 * @param y {Any*}
 * @returns {Any*} a promise for x and y if they are the same, but a rejection
 * otherwise.
 *
 */
Q.join = function (x, y) {
    return Q(x).join(y);
};

Promise.prototype.join = function (that) {
    return Q([this, that]).spread(function (x, y) {
        if (x === y) {
            // TODO: "===" should be Object.is or equiv
            return x;
        } else {
            throw new Error("Can't join: not the same: " + x + " " + y);
        }
    });
};

/**
 * Returns a promise for the first of an array of promises to become settled.
 * @param answers {Array[Any*]} promises to race
 * @returns {Any*} the first promise to be settled
 */
Q.race = race;
function race(answerPs) {
    return promise(function (resolve, reject) {
        // Switch to this once we can assume at least ES5
        // answerPs.forEach(function (answerP) {
        //     Q(answerP).then(resolve, reject);
        // });
        // Use this in the meantime
        for (var i = 0, len = answerPs.length; i < len; i++) {
            Q(answerPs[i]).then(resolve, reject);
        }
    });
}

Promise.prototype.race = function () {
    return this.then(Q.race);
};

/**
 * Constructs a Promise with a promise descriptor object and optional fallback
 * function.  The descriptor contains methods like when(rejected), get(name),
 * set(name, value), post(name, args), and delete(name), which all
 * return either a value, a promise for a value, or a rejection.  The fallback
 * accepts the operation name, a resolver, and any further arguments that would
 * have been forwarded to the appropriate method above had a method been
 * provided with the proper name.  The API makes no guarantees about the nature
 * of the returned object, apart from that it is usable whereever promises are
 * bought and sold.
 */
Q.makePromise = Promise;
function Promise(descriptor, fallback, inspect) {
    if (fallback === void 0) {
        fallback = function (op) {
            return reject(new Error(
                "Promise does not support operation: " + op
            ));
        };
    }
    if (inspect === void 0) {
        inspect = function () {
            return {state: "unknown"};
        };
    }

    var promise = object_create(Promise.prototype);

    promise.promiseDispatch = function (resolve, op, args) {
        var result;
        try {
            if (descriptor[op]) {
                result = descriptor[op].apply(promise, args);
            } else {
                result = fallback.call(promise, op, args);
            }
        } catch (exception) {
            result = reject(exception);
        }
        if (resolve) {
            resolve(result);
        }
    };

    promise.inspect = inspect;

    // XXX deprecated `valueOf` and `exception` support
    if (inspect) {
        var inspected = inspect();
        if (inspected.state === "rejected") {
            promise.exception = inspected.reason;
        }

        promise.valueOf = function () {
            var inspected = inspect();
            if (inspected.state === "pending" ||
                inspected.state === "rejected") {
                return promise;
            }
            return inspected.value;
        };
    }

    return promise;
}

Promise.prototype.toString = function () {
    return "[object Promise]";
};

Promise.prototype.then = function (fulfilled, rejected, progressed) {
    var self = this;
    var deferred = defer();
    var done = false;   // ensure the untrusted promise makes at most a
                        // single call to one of the callbacks

    function _fulfilled(value) {
        try {
            return typeof fulfilled === "function" ? fulfilled(value) : value;
        } catch (exception) {
            return reject(exception);
        }
    }

    function _rejected(exception) {
        if (typeof rejected === "function") {
            makeStackTraceLong(exception, self);
            try {
                return rejected(exception);
            } catch (newException) {
                return reject(newException);
            }
        }
        return reject(exception);
    }

    function _progressed(value) {
        return typeof progressed === "function" ? progressed(value) : value;
    }

    Q.nextTick(function () {
        self.promiseDispatch(function (value) {
            if (done) {
                return;
            }
            done = true;

            deferred.resolve(_fulfilled(value));
        }, "when", [function (exception) {
            if (done) {
                return;
            }
            done = true;

            deferred.resolve(_rejected(exception));
        }]);
    });

    // Progress propagator need to be attached in the current tick.
    self.promiseDispatch(void 0, "when", [void 0, function (value) {
        var newValue;
        var threw = false;
        try {
            newValue = _progressed(value);
        } catch (e) {
            threw = true;
            if (Q.onerror) {
                Q.onerror(e);
            } else {
                throw e;
            }
        }

        if (!threw) {
            deferred.notify(newValue);
        }
    }]);

    return deferred.promise;
};

Q.tap = function (promise, callback) {
    return Q(promise).tap(callback);
};

/**
 * Works almost like "finally", but not called for rejections.
 * Original resolution value is passed through callback unaffected.
 * Callback may return a promise that will be awaited for.
 * @param {Function} callback
 * @returns {Q.Promise}
 * @example
 * doSomething()
 *   .then(...)
 *   .tap(console.log)
 *   .then(...);
 */
Promise.prototype.tap = function (callback) {
    callback = Q(callback);

    return this.then(function (value) {
        return callback.fcall(value).thenResolve(value);
    });
};

/**
 * Registers an observer on a promise.
 *
 * Guarantees:
 *
 * 1. that fulfilled and rejected will be called only once.
 * 2. that either the fulfilled callback or the rejected callback will be
 *    called, but not both.
 * 3. that fulfilled and rejected will not be called in this turn.
 *
 * @param value      promise or immediate reference to observe
 * @param fulfilled  function to be called with the fulfilled value
 * @param rejected   function to be called with the rejection exception
 * @param progressed function to be called on any progress notifications
 * @return promise for the return value from the invoked callback
 */
Q.when = when;
function when(value, fulfilled, rejected, progressed) {
    return Q(value).then(fulfilled, rejected, progressed);
}

Promise.prototype.thenResolve = function (value) {
    return this.then(function () { return value; });
};

Q.thenResolve = function (promise, value) {
    return Q(promise).thenResolve(value);
};

Promise.prototype.thenReject = function (reason) {
    return this.then(function () { throw reason; });
};

Q.thenReject = function (promise, reason) {
    return Q(promise).thenReject(reason);
};

/**
 * If an object is not a promise, it is as "near" as possible.
 * If a promise is rejected, it is as "near" as possible too.
 * If it’s a fulfilled promise, the fulfillment value is nearer.
 * If it’s a deferred promise and the deferred has been resolved, the
 * resolution is "nearer".
 * @param object
 * @returns most resolved (nearest) form of the object
 */

// XXX should we re-do this?
Q.nearer = nearer;
function nearer(value) {
    if (isPromise(value)) {
        var inspected = value.inspect();
        if (inspected.state === "fulfilled") {
            return inspected.value;
        }
    }
    return value;
}

/**
 * @returns whether the given object is a promise.
 * Otherwise it is a fulfilled value.
 */
Q.isPromise = isPromise;
function isPromise(object) {
    return object instanceof Promise;
}

Q.isPromiseAlike = isPromiseAlike;
function isPromiseAlike(object) {
    return isObject(object) && typeof object.then === "function";
}

/**
 * @returns whether the given object is a pending promise, meaning not
 * fulfilled or rejected.
 */
Q.isPending = isPending;
function isPending(object) {
    return isPromise(object) && object.inspect().state === "pending";
}

Promise.prototype.isPending = function () {
    return this.inspect().state === "pending";
};

/**
 * @returns whether the given object is a value or fulfilled
 * promise.
 */
Q.isFulfilled = isFulfilled;
function isFulfilled(object) {
    return !isPromise(object) || object.inspect().state === "fulfilled";
}

Promise.prototype.isFulfilled = function () {
    return this.inspect().state === "fulfilled";
};

/**
 * @returns whether the given object is a rejected promise.
 */
Q.isRejected = isRejected;
function isRejected(object) {
    return isPromise(object) && object.inspect().state === "rejected";
}

Promise.prototype.isRejected = function () {
    return this.inspect().state === "rejected";
};

//// BEGIN UNHANDLED REJECTION TRACKING

// This promise library consumes exceptions thrown in handlers so they can be
// handled by a subsequent promise.  The exceptions get added to this array when
// they are created, and removed when they are handled.  Note that in ES6 or
// shimmed environments, this would naturally be a `Set`.
var unhandledReasons = [];
var unhandledRejections = [];
var reportedUnhandledRejections = [];
var trackUnhandledRejections = true;

function resetUnhandledRejections() {
    unhandledReasons.length = 0;
    unhandledRejections.length = 0;

    if (!trackUnhandledRejections) {
        trackUnhandledRejections = true;
    }
}

function trackRejection(promise, reason) {
    if (!trackUnhandledRejections) {
        return;
    }
    if (typeof process === "object" && typeof process.emit === "function") {
        Q.nextTick.runAfter(function () {
            if (array_indexOf(unhandledRejections, promise) !== -1) {
                process.emit("unhandledRejection", reason, promise);
                reportedUnhandledRejections.push(promise);
            }
        });
    }

    unhandledRejections.push(promise);
    if (reason && typeof reason.stack !== "undefined") {
        unhandledReasons.push(reason.stack);
    } else {
        unhandledReasons.push("(no stack) " + reason);
    }
}

function untrackRejection(promise) {
    if (!trackUnhandledRejections) {
        return;
    }

    var at = array_indexOf(unhandledRejections, promise);
    if (at !== -1) {
        if (typeof process === "object" && typeof process.emit === "function") {
            Q.nextTick.runAfter(function () {
                var atReport = array_indexOf(reportedUnhandledRejections, promise);
                if (atReport !== -1) {
                    process.emit("rejectionHandled", unhandledReasons[at], promise);
                    reportedUnhandledRejections.splice(atReport, 1);
                }
            });
        }
        unhandledRejections.splice(at, 1);
        unhandledReasons.splice(at, 1);
    }
}

Q.resetUnhandledRejections = resetUnhandledRejections;

Q.getUnhandledReasons = function () {
    // Make a copy so that consumers can't interfere with our internal state.
    return unhandledReasons.slice();
};

Q.stopUnhandledRejectionTracking = function () {
    resetUnhandledRejections();
    trackUnhandledRejections = false;
};

resetUnhandledRejections();

//// END UNHANDLED REJECTION TRACKING

/**
 * Constructs a rejected promise.
 * @param reason value describing the failure
 */
Q.reject = reject;
function reject(reason) {
    var rejection = Promise({
        "when": function (rejected) {
            // note that the error has been handled
            if (rejected) {
                untrackRejection(this);
            }
            return rejected ? rejected(reason) : this;
        }
    }, function fallback() {
        return this;
    }, function inspect() {
        return { state: "rejected", reason: reason };
    });

    // Note that the reason has not been handled.
    trackRejection(rejection, reason);

    return rejection;
}

/**
 * Constructs a fulfilled promise for an immediate reference.
 * @param value immediate reference
 */
Q.fulfill = fulfill;
function fulfill(value) {
    return Promise({
        "when": function () {
            return value;
        },
        "get": function (name) {
            return value[name];
        },
        "set": function (name, rhs) {
            value[name] = rhs;
        },
        "delete": function (name) {
            delete value[name];
        },
        "post": function (name, args) {
            // Mark Miller proposes that post with no name should apply a
            // promised function.
            if (name === null || name === void 0) {
                return value.apply(void 0, args);
            } else {
                return value[name].apply(value, args);
            }
        },
        "apply": function (thisp, args) {
            return value.apply(thisp, args);
        },
        "keys": function () {
            return object_keys(value);
        }
    }, void 0, function inspect() {
        return { state: "fulfilled", value: value };
    });
}

/**
 * Converts thenables to Q promises.
 * @param promise thenable promise
 * @returns a Q promise
 */
function coerce(promise) {
    var deferred = defer();
    Q.nextTick(function () {
        try {
            promise.then(deferred.resolve, deferred.reject, deferred.notify);
        } catch (exception) {
            deferred.reject(exception);
        }
    });
    return deferred.promise;
}

/**
 * Annotates an object such that it will never be
 * transferred away from this process over any promise
 * communication channel.
 * @param object
 * @returns promise a wrapping of that object that
 * additionally responds to the "isDef" message
 * without a rejection.
 */
Q.master = master;
function master(object) {
    return Promise({
        "isDef": function () {}
    }, function fallback(op, args) {
        return dispatch(object, op, args);
    }, function () {
        return Q(object).inspect();
    });
}

/**
 * Spreads the values of a promised array of arguments into the
 * fulfillment callback.
 * @param fulfilled callback that receives variadic arguments from the
 * promised array
 * @param rejected callback that receives the exception if the promise
 * is rejected.
 * @returns a promise for the return value or thrown exception of
 * either callback.
 */
Q.spread = spread;
function spread(value, fulfilled, rejected) {
    return Q(value).spread(fulfilled, rejected);
}

Promise.prototype.spread = function (fulfilled, rejected) {
    return this.all().then(function (array) {
        return fulfilled.apply(void 0, array);
    }, rejected);
};

/**
 * The async function is a decorator for generator functions, turning
 * them into asynchronous generators.  Although generators are only part
 * of the newest ECMAScript 6 drafts, this code does not cause syntax
 * errors in older engines.  This code should continue to work and will
 * in fact improve over time as the language improves.
 *
 * ES6 generators are currently part of V8 version 3.19 with the
 * --harmony-generators runtime flag enabled.  SpiderMonkey has had them
 * for longer, but under an older Python-inspired form.  This function
 * works on both kinds of generators.
 *
 * Decorates a generator function such that:
 *  - it may yield promises
 *  - execution will continue when that promise is fulfilled
 *  - the value of the yield expression will be the fulfilled value
 *  - it returns a promise for the return value (when the generator
 *    stops iterating)
 *  - the decorated function returns a promise for the return value
 *    of the generator or the first rejected promise among those
 *    yielded.
 *  - if an error is thrown in the generator, it propagates through
 *    every following yield until it is caught, or until it escapes
 *    the generator function altogether, and is translated into a
 *    rejection for the promise returned by the decorated generator.
 */
Q.async = async;
function async(makeGenerator) {
    return function () {
        // when verb is "send", arg is a value
        // when verb is "throw", arg is an exception
        function continuer(verb, arg) {
            var result;

            // Until V8 3.19 / Chromium 29 is released, SpiderMonkey is the only
            // engine that has a deployed base of browsers that support generators.
            // However, SM's generators use the Python-inspired semantics of
            // outdated ES6 drafts.  We would like to support ES6, but we'd also
            // like to make it possible to use generators in deployed browsers, so
            // we also support Python-style generators.  At some point we can remove
            // this block.

            if (typeof StopIteration === "undefined") {
                // ES6 Generators
                try {
                    result = generator[verb](arg);
                } catch (exception) {
                    return reject(exception);
                }
                if (result.done) {
                    return Q(result.value);
                } else {
                    return when(result.value, callback, errback);
                }
            } else {
                // SpiderMonkey Generators
                // FIXME: Remove this case when SM does ES6 generators.
                try {
                    result = generator[verb](arg);
                } catch (exception) {
                    if (isStopIteration(exception)) {
                        return Q(exception.value);
                    } else {
                        return reject(exception);
                    }
                }
                return when(result, callback, errback);
            }
        }
        var generator = makeGenerator.apply(this, arguments);
        var callback = continuer.bind(continuer, "next");
        var errback = continuer.bind(continuer, "throw");
        return callback();
    };
}

/**
 * The spawn function is a small wrapper around async that immediately
 * calls the generator and also ends the promise chain, so that any
 * unhandled errors are thrown instead of forwarded to the error
 * handler. This is useful because it's extremely common to run
 * generators at the top-level to work with libraries.
 */
Q.spawn = spawn;
function spawn(makeGenerator) {
    Q.done(Q.async(makeGenerator)());
}

// FIXME: Remove this interface once ES6 generators are in SpiderMonkey.
/**
 * Throws a ReturnValue exception to stop an asynchronous generator.
 *
 * This interface is a stop-gap measure to support generator return
 * values in older Firefox/SpiderMonkey.  In browsers that support ES6
 * generators like Chromium 29, just use "return" in your generator
 * functions.
 *
 * @param value the return value for the surrounding generator
 * @throws ReturnValue exception with the value.
 * @example
 * // ES6 style
 * Q.async(function* () {
 *      var foo = yield getFooPromise();
 *      var bar = yield getBarPromise();
 *      return foo + bar;
 * })
 * // Older SpiderMonkey style
 * Q.async(function () {
 *      var foo = yield getFooPromise();
 *      var bar = yield getBarPromise();
 *      Q.return(foo + bar);
 * })
 */
Q["return"] = _return;
function _return(value) {
    throw new QReturnValue(value);
}

/**
 * The promised function decorator ensures that any promise arguments
 * are settled and passed as values (`this` is also settled and passed
 * as a value).  It will also ensure that the result of a function is
 * always a promise.
 *
 * @example
 * var add = Q.promised(function (a, b) {
 *     return a + b;
 * });
 * add(Q(a), Q(B));
 *
 * @param {function} callback The function to decorate
 * @returns {function} a function that has been decorated.
 */
Q.promised = promised;
function promised(callback) {
    return function () {
        return spread([this, all(arguments)], function (self, args) {
            return callback.apply(self, args);
        });
    };
}

/**
 * sends a message to a value in a future turn
 * @param object* the recipient
 * @param op the name of the message operation, e.g., "when",
 * @param args further arguments to be forwarded to the operation
 * @returns result {Promise} a promise for the result of the operation
 */
Q.dispatch = dispatch;
function dispatch(object, op, args) {
    return Q(object).dispatch(op, args);
}

Promise.prototype.dispatch = function (op, args) {
    var self = this;
    var deferred = defer();
    Q.nextTick(function () {
        self.promiseDispatch(deferred.resolve, op, args);
    });
    return deferred.promise;
};

/**
 * Gets the value of a property in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of property to get
 * @return promise for the property value
 */
Q.get = function (object, key) {
    return Q(object).dispatch("get", [key]);
};

Promise.prototype.get = function (key) {
    return this.dispatch("get", [key]);
};

/**
 * Sets the value of a property in a future turn.
 * @param object    promise or immediate reference for object object
 * @param name      name of property to set
 * @param value     new value of property
 * @return promise for the return value
 */
Q.set = function (object, key, value) {
    return Q(object).dispatch("set", [key, value]);
};

Promise.prototype.set = function (key, value) {
    return this.dispatch("set", [key, value]);
};

/**
 * Deletes a property in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of property to delete
 * @return promise for the return value
 */
Q.del = // XXX legacy
Q["delete"] = function (object, key) {
    return Q(object).dispatch("delete", [key]);
};

Promise.prototype.del = // XXX legacy
Promise.prototype["delete"] = function (key) {
    return this.dispatch("delete", [key]);
};

/**
 * Invokes a method in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of method to invoke
 * @param value     a value to post, typically an array of
 *                  invocation arguments for promises that
 *                  are ultimately backed with `resolve` values,
 *                  as opposed to those backed with URLs
 *                  wherein the posted value can be any
 *                  JSON serializable object.
 * @return promise for the return value
 */
// bound locally because it is used by other methods
Q.mapply = // XXX As proposed by "Redsandro"
Q.post = function (object, name, args) {
    return Q(object).dispatch("post", [name, args]);
};

Promise.prototype.mapply = // XXX As proposed by "Redsandro"
Promise.prototype.post = function (name, args) {
    return this.dispatch("post", [name, args]);
};

/**
 * Invokes a method in a future turn.
 * @param object    promise or immediate reference for target object
 * @param name      name of method to invoke
 * @param ...args   array of invocation arguments
 * @return promise for the return value
 */
Q.send = // XXX Mark Miller's proposed parlance
Q.mcall = // XXX As proposed by "Redsandro"
Q.invoke = function (object, name /*...args*/) {
    return Q(object).dispatch("post", [name, array_slice(arguments, 2)]);
};

Promise.prototype.send = // XXX Mark Miller's proposed parlance
Promise.prototype.mcall = // XXX As proposed by "Redsandro"
Promise.prototype.invoke = function (name /*...args*/) {
    return this.dispatch("post", [name, array_slice(arguments, 1)]);
};

/**
 * Applies the promised function in a future turn.
 * @param object    promise or immediate reference for target function
 * @param args      array of application arguments
 */
Q.fapply = function (object, args) {
    return Q(object).dispatch("apply", [void 0, args]);
};

Promise.prototype.fapply = function (args) {
    return this.dispatch("apply", [void 0, args]);
};

/**
 * Calls the promised function in a future turn.
 * @param object    promise or immediate reference for target function
 * @param ...args   array of application arguments
 */
Q["try"] =
Q.fcall = function (object /* ...args*/) {
    return Q(object).dispatch("apply", [void 0, array_slice(arguments, 1)]);
};

Promise.prototype.fcall = function (/*...args*/) {
    return this.dispatch("apply", [void 0, array_slice(arguments)]);
};

/**
 * Binds the promised function, transforming return values into a fulfilled
 * promise and thrown errors into a rejected one.
 * @param object    promise or immediate reference for target function
 * @param ...args   array of application arguments
 */
Q.fbind = function (object /*...args*/) {
    var promise = Q(object);
    var args = array_slice(arguments, 1);
    return function fbound() {
        return promise.dispatch("apply", [
            this,
            args.concat(array_slice(arguments))
        ]);
    };
};
Promise.prototype.fbind = function (/*...args*/) {
    var promise = this;
    var args = array_slice(arguments);
    return function fbound() {
        return promise.dispatch("apply", [
            this,
            args.concat(array_slice(arguments))
        ]);
    };
};

/**
 * Requests the names of the owned properties of a promised
 * object in a future turn.
 * @param object    promise or immediate reference for target object
 * @return promise for the keys of the eventually settled object
 */
Q.keys = function (object) {
    return Q(object).dispatch("keys", []);
};

Promise.prototype.keys = function () {
    return this.dispatch("keys", []);
};

/**
 * Turns an array of promises into a promise for an array.  If any of
 * the promises gets rejected, the whole array is rejected immediately.
 * @param {Array*} an array (or promise for an array) of values (or
 * promises for values)
 * @returns a promise for an array of the corresponding values
 */
// By Mark Miller
// http://wiki.ecmascript.org/doku.php?id=strawman:concurrency&rev=1308776521#allfulfilled
Q.all = all;
function all(promises) {
    return when(promises, function (promises) {
        var pendingCount = 0;
        var deferred = defer();
        array_reduce(promises, function (undefined, promise, index) {
            var snapshot;
            if (
                isPromise(promise) &&
                (snapshot = promise.inspect()).state === "fulfilled"
            ) {
                promises[index] = snapshot.value;
            } else {
                ++pendingCount;
                when(
                    promise,
                    function (value) {
                        promises[index] = value;
                        if (--pendingCount === 0) {
                            deferred.resolve(promises);
                        }
                    },
                    deferred.reject,
                    function (progress) {
                        deferred.notify({ index: index, value: progress });
                    }
                );
            }
        }, void 0);
        if (pendingCount === 0) {
            deferred.resolve(promises);
        }
        return deferred.promise;
    });
}

Promise.prototype.all = function () {
    return all(this);
};

/**
 * Returns the first resolved promise of an array. Prior rejected promises are
 * ignored.  Rejects only if all promises are rejected.
 * @param {Array*} an array containing values or promises for values
 * @returns a promise fulfilled with the value of the first resolved promise,
 * or a rejected promise if all promises are rejected.
 */
Q.any = any;

function any(promises) {
    if (promises.length === 0) {
        return Q.resolve();
    }

    var deferred = Q.defer();
    var pendingCount = 0;
    array_reduce(promises, function (prev, current, index) {
        var promise = promises[index];

        pendingCount++;

        when(promise, onFulfilled, onRejected, onProgress);
        function onFulfilled(result) {
            deferred.resolve(result);
        }
        function onRejected() {
            pendingCount--;
            if (pendingCount === 0) {
                deferred.reject(new Error(
                    "Can't get fulfillment value from any promise, all " +
                    "promises were rejected."
                ));
            }
        }
        function onProgress(progress) {
            deferred.notify({
                index: index,
                value: progress
            });
        }
    }, undefined);

    return deferred.promise;
}

Promise.prototype.any = function () {
    return any(this);
};

/**
 * Waits for all promises to be settled, either fulfilled or
 * rejected.  This is distinct from `all` since that would stop
 * waiting at the first rejection.  The promise returned by
 * `allResolved` will never be rejected.
 * @param promises a promise for an array (or an array) of promises
 * (or values)
 * @return a promise for an array of promises
 */
Q.allResolved = deprecate(allResolved, "allResolved", "allSettled");
function allResolved(promises) {
    return when(promises, function (promises) {
        promises = array_map(promises, Q);
        return when(all(array_map(promises, function (promise) {
            return when(promise, noop, noop);
        })), function () {
            return promises;
        });
    });
}

Promise.prototype.allResolved = function () {
    return allResolved(this);
};

/**
 * @see Promise#allSettled
 */
Q.allSettled = allSettled;
function allSettled(promises) {
    return Q(promises).allSettled();
}

/**
 * Turns an array of promises into a promise for an array of their states (as
 * returned by `inspect`) when they have all settled.
 * @param {Array[Any*]} values an array (or promise for an array) of values (or
 * promises for values)
 * @returns {Array[State]} an array of states for the respective values.
 */
Promise.prototype.allSettled = function () {
    return this.then(function (promises) {
        return all(array_map(promises, function (promise) {
            promise = Q(promise);
            function regardless() {
                return promise.inspect();
            }
            return promise.then(regardless, regardless);
        }));
    });
};

/**
 * Captures the failure of a promise, giving an oportunity to recover
 * with a callback.  If the given promise is fulfilled, the returned
 * promise is fulfilled.
 * @param {Any*} promise for something
 * @param {Function} callback to fulfill the returned promise if the
 * given promise is rejected
 * @returns a promise for the return value of the callback
 */
Q.fail = // XXX legacy
Q["catch"] = function (object, rejected) {
    return Q(object).then(void 0, rejected);
};

Promise.prototype.fail = // XXX legacy
Promise.prototype["catch"] = function (rejected) {
    return this.then(void 0, rejected);
};

/**
 * Attaches a listener that can respond to progress notifications from a
 * promise's originating deferred. This listener receives the exact arguments
 * passed to ``deferred.notify``.
 * @param {Any*} promise for something
 * @param {Function} callback to receive any progress notifications
 * @returns the given promise, unchanged
 */
Q.progress = progress;
function progress(object, progressed) {
    return Q(object).then(void 0, void 0, progressed);
}

Promise.prototype.progress = function (progressed) {
    return this.then(void 0, void 0, progressed);
};

/**
 * Provides an opportunity to observe the settling of a promise,
 * regardless of whether the promise is fulfilled or rejected.  Forwards
 * the resolution to the returned promise when the callback is done.
 * The callback can return a promise to defer completion.
 * @param {Any*} promise
 * @param {Function} callback to observe the resolution of the given
 * promise, takes no arguments.
 * @returns a promise for the resolution of the given promise when
 * ``fin`` is done.
 */
Q.fin = // XXX legacy
Q["finally"] = function (object, callback) {
    return Q(object)["finally"](callback);
};

Promise.prototype.fin = // XXX legacy
Promise.prototype["finally"] = function (callback) {
    callback = Q(callback);
    return this.then(function (value) {
        return callback.fcall().then(function () {
            return value;
        });
    }, function (reason) {
        // TODO attempt to recycle the rejection with "this".
        return callback.fcall().then(function () {
            throw reason;
        });
    });
};

/**
 * Terminates a chain of promises, forcing rejections to be
 * thrown as exceptions.
 * @param {Any*} promise at the end of a chain of promises
 * @returns nothing
 */
Q.done = function (object, fulfilled, rejected, progress) {
    return Q(object).done(fulfilled, rejected, progress);
};

Promise.prototype.done = function (fulfilled, rejected, progress) {
    var onUnhandledError = function (error) {
        // forward to a future turn so that ``when``
        // does not catch it and turn it into a rejection.
        Q.nextTick(function () {
            makeStackTraceLong(error, promise);
            if (Q.onerror) {
                Q.onerror(error);
            } else {
                throw error;
            }
        });
    };

    // Avoid unnecessary `nextTick`ing via an unnecessary `when`.
    var promise = fulfilled || rejected || progress ?
        this.then(fulfilled, rejected, progress) :
        this;

    if (typeof process === "object" && process && process.domain) {
        onUnhandledError = process.domain.bind(onUnhandledError);
    }

    promise.then(void 0, onUnhandledError);
};

/**
 * Causes a promise to be rejected if it does not get fulfilled before
 * some milliseconds time out.
 * @param {Any*} promise
 * @param {Number} milliseconds timeout
 * @param {Any*} custom error message or Error object (optional)
 * @returns a promise for the resolution of the given promise if it is
 * fulfilled before the timeout, otherwise rejected.
 */
Q.timeout = function (object, ms, error) {
    return Q(object).timeout(ms, error);
};

Promise.prototype.timeout = function (ms, error) {
    var deferred = defer();
    var timeoutId = setTimeout(function () {
        if (!error || "string" === typeof error) {
            error = new Error(error || "Timed out after " + ms + " ms");
            error.code = "ETIMEDOUT";
        }
        deferred.reject(error);
    }, ms);

    this.then(function (value) {
        clearTimeout(timeoutId);
        deferred.resolve(value);
    }, function (exception) {
        clearTimeout(timeoutId);
        deferred.reject(exception);
    }, deferred.notify);

    return deferred.promise;
};

/**
 * Returns a promise for the given value (or promised value), some
 * milliseconds after it resolved. Passes rejections immediately.
 * @param {Any*} promise
 * @param {Number} milliseconds
 * @returns a promise for the resolution of the given promise after milliseconds
 * time has elapsed since the resolution of the given promise.
 * If the given promise rejects, that is passed immediately.
 */
Q.delay = function (object, timeout) {
    if (timeout === void 0) {
        timeout = object;
        object = void 0;
    }
    return Q(object).delay(timeout);
};

Promise.prototype.delay = function (timeout) {
    return this.then(function (value) {
        var deferred = defer();
        setTimeout(function () {
            deferred.resolve(value);
        }, timeout);
        return deferred.promise;
    });
};

/**
 * Passes a continuation to a Node function, which is called with the given
 * arguments provided as an array, and returns a promise.
 *
 *      Q.nfapply(FS.readFile, [__filename])
 *      .then(function (content) {
 *      })
 *
 */
Q.nfapply = function (callback, args) {
    return Q(callback).nfapply(args);
};

Promise.prototype.nfapply = function (args) {
    var deferred = defer();
    var nodeArgs = array_slice(args);
    nodeArgs.push(deferred.makeNodeResolver());
    this.fapply(nodeArgs).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Passes a continuation to a Node function, which is called with the given
 * arguments provided individually, and returns a promise.
 * @example
 * Q.nfcall(FS.readFile, __filename)
 * .then(function (content) {
 * })
 *
 */
Q.nfcall = function (callback /*...args*/) {
    var args = array_slice(arguments, 1);
    return Q(callback).nfapply(args);
};

Promise.prototype.nfcall = function (/*...args*/) {
    var nodeArgs = array_slice(arguments);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.fapply(nodeArgs).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Wraps a NodeJS continuation passing function and returns an equivalent
 * version that returns a promise.
 * @example
 * Q.nfbind(FS.readFile, __filename)("utf-8")
 * .then(console.log)
 * .done()
 */
Q.nfbind =
Q.denodeify = function (callback /*...args*/) {
    var baseArgs = array_slice(arguments, 1);
    return function () {
        var nodeArgs = baseArgs.concat(array_slice(arguments));
        var deferred = defer();
        nodeArgs.push(deferred.makeNodeResolver());
        Q(callback).fapply(nodeArgs).fail(deferred.reject);
        return deferred.promise;
    };
};

Promise.prototype.nfbind =
Promise.prototype.denodeify = function (/*...args*/) {
    var args = array_slice(arguments);
    args.unshift(this);
    return Q.denodeify.apply(void 0, args);
};

Q.nbind = function (callback, thisp /*...args*/) {
    var baseArgs = array_slice(arguments, 2);
    return function () {
        var nodeArgs = baseArgs.concat(array_slice(arguments));
        var deferred = defer();
        nodeArgs.push(deferred.makeNodeResolver());
        function bound() {
            return callback.apply(thisp, arguments);
        }
        Q(bound).fapply(nodeArgs).fail(deferred.reject);
        return deferred.promise;
    };
};

Promise.prototype.nbind = function (/*thisp, ...args*/) {
    var args = array_slice(arguments, 0);
    args.unshift(this);
    return Q.nbind.apply(void 0, args);
};

/**
 * Calls a method of a Node-style object that accepts a Node-style
 * callback with a given array of arguments, plus a provided callback.
 * @param object an object that has the named method
 * @param {String} name name of the method of object
 * @param {Array} args arguments to pass to the method; the callback
 * will be provided by Q and appended to these arguments.
 * @returns a promise for the value or error
 */
Q.nmapply = // XXX As proposed by "Redsandro"
Q.npost = function (object, name, args) {
    return Q(object).npost(name, args);
};

Promise.prototype.nmapply = // XXX As proposed by "Redsandro"
Promise.prototype.npost = function (name, args) {
    var nodeArgs = array_slice(args || []);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

/**
 * Calls a method of a Node-style object that accepts a Node-style
 * callback, forwarding the given variadic arguments, plus a provided
 * callback argument.
 * @param object an object that has the named method
 * @param {String} name name of the method of object
 * @param ...args arguments to pass to the method; the callback will
 * be provided by Q and appended to these arguments.
 * @returns a promise for the value or error
 */
Q.nsend = // XXX Based on Mark Miller's proposed "send"
Q.nmcall = // XXX Based on "Redsandro's" proposal
Q.ninvoke = function (object, name /*...args*/) {
    var nodeArgs = array_slice(arguments, 2);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    Q(object).dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

Promise.prototype.nsend = // XXX Based on Mark Miller's proposed "send"
Promise.prototype.nmcall = // XXX Based on "Redsandro's" proposal
Promise.prototype.ninvoke = function (name /*...args*/) {
    var nodeArgs = array_slice(arguments, 1);
    var deferred = defer();
    nodeArgs.push(deferred.makeNodeResolver());
    this.dispatch("post", [name, nodeArgs]).fail(deferred.reject);
    return deferred.promise;
};

/**
 * If a function would like to support both Node continuation-passing-style and
 * promise-returning-style, it can end its internal promise chain with
 * `nodeify(nodeback)`, forwarding the optional nodeback argument.  If the user
 * elects to use a nodeback, the result will be sent there.  If they do not
 * pass a nodeback, they will receive the result promise.
 * @param object a result (or a promise for a result)
 * @param {Function} nodeback a Node.js-style callback
 * @returns either the promise or nothing
 */
Q.nodeify = nodeify;
function nodeify(object, nodeback) {
    return Q(object).nodeify(nodeback);
}

Promise.prototype.nodeify = function (nodeback) {
    if (nodeback) {
        this.then(function (value) {
            Q.nextTick(function () {
                nodeback(null, value);
            });
        }, function (error) {
            Q.nextTick(function () {
                nodeback(error);
            });
        });
    } else {
        return this;
    }
};

Q.noConflict = function() {
    throw new Error("Q.noConflict only works when Q is used as a global");
};

// All code before this point will be filtered from stack traces.
var qEndingLine = captureLine();

return Q;

});

}).call(this,require('_process'))
},{"_process":1}],29:[function(require,module,exports){
var component, dropdown, generateId, modal, toEnglish;

component = require('../utils/component');

modal = require('../singletons/modal');

dropdown = require('../components/dropdown');

generateId = require('../utils/dom').generateId;

toEnglish = require('../utils').toEnglish;

module.exports = component('chooseGolestanNumber', function(arg) {
  var E, contents, dom, events, golestanNumber, id, returnObject, service, setStyle;
  dom = arg.dom, events = arg.events, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle;
  id = generateId();
  golestanNumber = E(dropdown);
  setStyle(golestanNumber.input, {
    id: id
  });
  contents = E({
    "class": 'form-group'
  }, E('label', {
    "for": id
  }, 'شماره دانشجویی / پرسنلی'), golestanNumber);
  return returnObject({
    display: function(golestanNumbers) {
      golestanNumber.update(golestanNumbers);
      return modal.instance.display({
        autoHide: true,
        Title: 'شماره دانشجویی / پرسنلی مورد نظر را انتخاب کنید',
        SubmitText: 'ورود',
        submit: function() {
          return service.casLogin({
            golestanNumber: toEnglish(golestanNumber.value())
          });
        }
      });
    }
  });
});


},{"../components/dropdown":6,"../singletons/modal":33,"../utils":38,"../utils/component":34,"../utils/dom":36}],30:[function(require,module,exports){
var component, emailIsValid, errorNames, generateId, modal, passwordIsValid, ref;

component = require('../utils/component');

modal = require('../singletons/modal');

generateId = require('../utils/dom').generateId;

ref = require('../utils/logic'), emailIsValid = ref.emailIsValid, passwordIsValid = ref.passwordIsValid;

errorNames = {
  email: {
    empty: 'لطفا ایمیل را وارد کنید',
    invalid: 'ایمیل نامعتبر است',
    notExists: 'کاربری با این ایمیل وجود ندارد'
  },
  password: {
    empty: 'لطفا رمز عبور را وارد کنید',
    short: 'رمز عبور باید حد اقل ۶ حرف باشد'
  }
};

module.exports = component('login', function(arg) {
  var E, addClass, disable, dom, enable, events, hide, login, loginEmailValid, onEnter, onEvent, removeClass, returnObject, service, show;
  dom = arg.dom, events = arg.events, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, addClass = dom.addClass, removeClass = dom.removeClass, show = dom.show, hide = dom.hide, enable = dom.enable, disable = dom.disable;
  onEvent = events.onEvent, onEnter = events.onEnter;
  loginEmailValid = service.loginEmailValid, login = service.login;
  return returnObject({
    display: function() {
      var alert, errors, fields, setEnabled, submit, submitting, updates, valid;
      alert = void 0;
      fields = {};
      errors = {
        email: errorNames.email.empty,
        password: errorNames.password.empty
      };
      valid = false;
      submitting = false;
      (setEnabled = function() {
        return modal.instance.setEnabled(valid = !errors.email && !errors.password && !submitting);
      })();
      updates = [];
      submit = function() {
        var email, password;
        updates.forEach(function(update) {
          return update(true);
        });
        if (!valid) {
          return;
        }
        submitting = true;
        setEnabled();
        email = fields.email, password = fields.password;
        disable([email, password]);
        return login({
          email: email.value(),
          password: password.value()
        }).then(modal.instance.hide)["catch"](function() {
          return addClass(alert, 'in');
        }).fin(function() {
          enable([email, password]);
          submitting = false;
          return setEnabled();
        });
      };
      return modal.instance.display({
        title: 'ورود',
        submitText: 'ورود',
        submitType: 'primary',
        closeText: 'بستن',
        submit: submit,
        contents: (function() {
          var alertClose, bindFieldevents, emailId, passwordId, spinner, view;
          bindFieldevents = function(fieldName) {
            var blurred, checkQ, field, loading, onAction, update;
            field = fields[fieldName];
            blurred = false;
            loading = false;
            updates.push(update = function(force) {
              var JQElem, error, prevTooltip;
              JQElem = $(field.fn.element);
              error = errors[fieldName];
              if (error && (blurred || force) && !loading) {
                prevTooltip = JQElem.data('bs.tooltip');
                if (prevTooltip) {
                  prevTooltip.options.title = error;
                } else {
                  JQElem.tooltip({
                    trigger: 'manual',
                    placement: 'bottom',
                    title: error
                  });
                }
                if (JQElem.next('.tooltip').length === 0) {
                  JQElem.tooltip('show');
                }
              } else {
                JQElem.tooltip('hide');
              }
              return setEnabled();
            });
            checkQ = null;
            onAction = function(isChange) {
              return function(e) {
                var element, value, xQ;
                element = e.target;
                value = element.value;
                blurred = document.activeElement !== element;
                switch (fieldName) {
                  case 'email':
                    if (!value) {
                      errors[fieldName] = errorNames.email.empty;
                    } else if (!emailIsValid(value)) {
                      errors[fieldName] = errorNames.email.invalid;
                    } else {
                      if (isChange) {
                        errors[fieldName] = errorNames.email.notExists;
                        loading = true;
                        show(spinner);
                        checkQ = xQ = loginEmailValid({
                          email: value
                        }).then(function(isValid) {
                          if (checkQ !== xQ) {
                            return;
                          }
                          loading = false;
                          hide(spinner);
                          if (isValid) {
                            delete errors[fieldName];
                          }
                          return update();
                        }).done();
                      }
                    }
                    break;
                  case 'password':
                    if (!value) {
                      errors[fieldName] = errorNames.password.empty;
                    } else if (passwordIsValid(value)) {
                      delete errors[fieldName];
                    } else {
                      errors[fieldName] = errorNames.password.short;
                    }
                }
                return update();
              };
            };
            onEvent(field, 'input', onAction(true));
            onEvent(field, 'focusin', onAction(true));
            onEvent(field, 'focusout', function() {
              blurred = true;
              return update();
            });
            return onEnter(field, submit);
          };
          emailId = generateId();
          passwordId = generateId();
          view = [
            alert = E({
              "class": 'alert alert-danger fade'
            }, alertClose = E('button', {
              "class": 'close',
              zIndex: 10
            }, '×'), E('h4', null, 'رمز عبور اشتباه است.')), E({
              "class": 'form-group',
              position: 'relative'
            }, E('label', {
              "for": emailId
            }, 'ایمیل'), fields.email = E('input', {
              id: emailId,
              "class": 'form-control',
              type: 'email',
              direction: 'ltr'
            }), spinner = E({
              "class": 'fa fa-circle-o-notch fa-spin fa-fw',
              position: 'absolute',
              right: 7,
              top: 35
            })), E({
              "class": 'form-group'
            }, E('label', {
              "for": passwordId
            }, 'رمز عبور'), fields.password = E('input', {
              id: passwordId,
              "class": 'form-control',
              type: 'password',
              direction: 'ltr'
            }))
          ];
          bindFieldevents('email');
          bindFieldevents('password');
          hide(spinner);
          onEvent(alertClose, 'click', function() {
            return removeClass(alert, 'in');
          });
          return view;
        })()
      });
    }
  });
});


},{"../singletons/modal":33,"../utils/component":34,"../utils/dom":36,"../utils/logic":40}],31:[function(require,module,exports){
var component, errorNames, generateId, modal, passwordIsValid;

component = require('../utils/component');

modal = require('../singletons/modal');

generateId = require('../utils/dom').generateId;

passwordIsValid = require('../utils/logic').passwordIsValid;

errorNames = {
  password: {
    empty: 'لطفا رمز عبور را وارد کنید',
    short: 'رمز عبور باید حد اقل ۶ حرف باشد'
  },
  confirmPassword: {
    notEqual: 'رمز عبور‌ها مطابقت ندارند'
  }
};

module.exports = component('register', function(arg) {
  var E, addClass, disable, dom, enable, events, onEnter, onEvent, register, removeClass, returnObject, service;
  dom = arg.dom, events = arg.events, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, addClass = dom.addClass, removeClass = dom.removeClass, enable = dom.enable, disable = dom.disable;
  onEvent = events.onEvent, onEnter = events.onEnter;
  register = service.register;
  return returnObject({
    display: function() {
      var alert, errors, fields, setEnabled, submit, submitting, updates, valid;
      alert = void 0;
      fields = {};
      errors = {
        password: errorNames.password.empty,
        confirmPassword: errorNames.confirmPassword.notEqual
      };
      valid = false;
      submitting = false;
      (setEnabled = function() {
        return modal.setEnabled(valid = !errors.password && !errors.confirmPassword && !submitting);
      })();
      updates = [];
      submit = function() {
        var confirmPassword, email, params, password, verificationCode;
        updates.forEach(function(update) {
          return update(true);
        });
        if (!valid) {
          return;
        }
        params = location.href.split('?');
        if (params.length > 1 && params[1].indexOf('email=') === 0) {
          params = params[1].split('&');
          if (params.length > 1 && (params[0].indexOf('email=') === 0) && (params[1].indexOf('verificationCode=') === 0)) {
            email = params[0].substr('email='.length);
            verificationCode = params[1].substr('verificationCode='.length);
          } else {
            return;
          }
        } else {
          return;
        }
        submitting = true;
        setEnabled();
        password = fields.password, confirmPassword = fields.confirmPassword;
        disable([password, confirmPassword]);
        return register({
          email: email,
          verificationCode: verificationCode,
          password: password.value
        }).then(modal.hide)["catch"](function() {
          return addClass(alert, 'in');
        }).fin(function() {
          enable([password, confirmPassword]);
          submitting = false;
          return setEnabled();
        });
      };
      return modal.instance.display({
        title: 'تغییر رمز عبور',
        submitText: 'ثبت',
        submitType: 'primary',
        closeText: 'بستن',
        submit: submit,
        contents: (function() {
          var alertClose, bindFieldevents, confirmPasswordId, passwordId, view;
          bindFieldevents = function(fieldName) {
            var blurred, checkQ, field, loading, onAction, update;
            field = fields[fieldName];
            blurred = false;
            loading = false;
            updates.push(update = function(force) {
              var JQElem, error, prevTooltip;
              JQElem = $(field);
              error = errors[fieldName];
              if (error && (blurred || force) && !loading) {
                prevTooltip = JQElem.data('bs.tooltip');
                if (prevTooltip) {
                  prevTooltip.options.title = error;
                } else {
                  JQElem.tooltip({
                    trigger: 'manual',
                    placement: 'bottom',
                    title: error
                  });
                }
                if (JQElem.next('.tooltip').length === 0) {
                  JQElem.tooltip('show');
                }
              } else {
                JQElem.tooltip('hide');
              }
              return setEnabled();
            });
            checkQ = null;
            onAction = function(isChange) {
              return function(e) {
                var element, value;
                element = e.target;
                value = element.value;
                blurred = document.activeElement !== element;
                switch (fieldName) {
                  case 'password':
                    if (!value) {
                      errors[fieldName] = errorNames.password.empty;
                    } else {
                      if (passwordIsValid(value)) {
                        delete errors[fieldName];
                      } else {
                        errors[fieldName] = errorNames.password.short;
                      }
                      if (fields.confirmPassword.value === value) {
                        delete errors.confirmPassword;
                      } else {
                        errors.confirmPassword = errorNames.confirmPassword.notEqual;
                      }
                    }
                    break;
                  case 'confirmPassword':
                    if (fields.password.value === value) {
                      delete errors[fieldName];
                    } else {
                      errors[fieldName] = errorNames.confirmPassword.notEqual;
                    }
                }
                return update();
              };
            };
            onEvent(field, 'input', onAction(true));
            onEvent(field, 'focusin', onAction(true));
            onEvent(field, 'focusout', function() {
              blurred = true;
              return update();
            });
            return onEnter(field, submit);
          };
          passwordId = generateId();
          confirmPasswordId = generateId();
          view = [
            alert = E({
              "class": 'alert alert-danger fade'
            }, alertClose = E('button', {
              "class": 'close',
              zIndex: 10
            }, '×'), E('h4', null, 'رمز عبور اشتباه است')), E({
              "class": 'form-group'
            }, E('label', {
              "for": passwordId
            }, 'رمز عبور'), fields.password = E('input', {
              id: passwordId,
              "class": 'form-control',
              type: 'password',
              direction: 'ltr'
            })), E({
              "class": 'form-group'
            }, E('label', {
              "for": confirmPasswordId
            }, 'تکرار رمز عبور'), fields.confirmPassword = E('input', {
              id: confirmPasswordId,
              "class": 'form-control',
              type: 'password',
              direction: 'ltr'
            }))
          ];
          bindFieldevents('password');
          bindFieldevents('confirmPassword');
          onEvent(alertClose, 'click', function() {
            return removeClass(alert, 'in');
          });
          return view;
        })()
      });
    }
  });
});


},{"../singletons/modal":33,"../utils/component":34,"../utils/dom":36,"../utils/logic":40}],32:[function(require,module,exports){
exports.set = function(x) {
  return exports.instance = x;
};


},{}],33:[function(require,module,exports){
arguments[4][32][0].apply(exports,arguments)
},{"dup":32}],34:[function(require,module,exports){
var _dom, _events, _service, _state, extend, log,
  slice = [].slice;

_state = require('./state');

_service = require('./service');

_dom = require('./dom');

_events = require('./events');

log = require('./log').component;

extend = require('.').extend;

module.exports = function(componentName, create) {
  return function() {
    var args, c, component, dom, events, others, ref, ref1, returnObject, service, state;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    component = {};
    component.fn = {
      name: componentName,
      off: function() {}
    };
    log.create(0, component);
    dom = _dom.instance(component);
    events = _events.instance(component);
    state = _state.instance(component);
    service = _service.instance(component);
    returnObject = function(returnObject) {
      return extend(component, returnObject);
    };
    others = {
      loading: function(stateNames, yesData, noData) {
        if (!Array.isArray(stateNames)) {
          stateNames = [stateNames];
        }
        dom.hide(yesData);
        return state.all(stateNames, function() {
          dom.hide(noData);
          return dom.show(yesData);
        });
      }
    };
    c = create.apply(null, [{
      dom: dom,
      events: events,
      state: state,
      service: service,
      returnObject: returnObject,
      others: others
    }].concat(slice.call(args)));
    if (c != null ? (ref = c.fn) != null ? ref.element : void 0 : void 0) {
      component.fn.element = c.fn.element;
    }
    if (c != null ? (ref1 = c.fn) != null ? ref1.pInputListeners : void 0 : void 0) {
      component.fn.pInputListeners = c.fn.pInputListeners;
    }
    if (Array.isArray(c)) {
      component.fn.element = c;
    }
    log.create(1, component);
    return component;
  };
};


},{".":38,"./dom":36,"./events":37,"./log":39,"./service":44,"./state":48}],35:[function(require,module,exports){
var createCookie, eraseCookie, readCookie;

createCookie = function(name, value, days) {
  var date, expires;
  if (days) {
    date = new Date();
    date.setTime(+date + (days * 24 * 60 * 60 * 1000));
    expires = "; expires=" + (date.toGMTString());
  } else {
    expires = '';
  }
  return document.cookie = name + "=" + value + expires + "; path=/";
};

readCookie = function(name) {
  var nameEQ, result, resultArray;
  nameEQ = name + "=";
  resultArray = document.cookie.split(';').map(function(c) {
    while (c.charAt(0) === ' ') {
      c = c.substring(1, c.length);
    }
    return c;
  }).filter(function(c) {
    return c.indexOf(nameEQ) === 0;
  });
  result = resultArray[0];
  return result != null ? result.substring(nameEQ.length) : void 0;
};

eraseCookie = function(name) {
  return createCookie(name, '', -1);
};

module.exports = {
  createCookie: createCookie,
  readCookie: readCookie,
  eraseCookie: eraseCookie
};


},{}],36:[function(require,module,exports){
var extend, log, ref, remove, toPersian, uppercaseFirst,
  slice = [].slice;

log = require('./log').dom;

ref = require('.'), toPersian = ref.toPersian, uppercaseFirst = ref.uppercaseFirst, extend = ref.extend, remove = ref.remove;

exports.window = function() {
  return {
    fn: {
      name: 'window',
      element: window,
      off: function() {}
    }
  };
};

exports.document = function() {
  return {
    fn: {
      name: 'document',
      element: document,
      off: function() {}
    }
  };
};

exports.body = function() {
  return {
    fn: {
      name: 'body',
      element: document.body,
      off: function() {}
    }
  };
};

exports.head = function() {
  return {
    fn: {
      name: 'head',
      element: document.head,
      off: function() {}
    }
  };
};

exports.addPageCSS = function(url) {
  var cssNode;
  cssNode = document.createElement('link');
  cssNode.setAttribute('rel', 'stylesheet');
  cssNode.setAttribute('href', "assets/" + url);
  return document.head.appendChild(cssNode);
};

exports.addPageStyle = function(code) {
  var styleNode;
  styleNode = document.createElement('style');
  styleNode.type = 'text/css';
  styleNode.textContent = code;
  return document.head.appendChild(styleNode);
};

exports.generateId = (function() {
  var i;
  i = 0;
  return function() {
    return i++;
  };
})();

exports.instance = function(thisComponent) {
  var exports;
  exports = {};
  exports.E = (function() {
    var e;
    e = function(parent, tagName, style, children) {
      var appendChildren, component, element;
      element = document.createElement(tagName);
      component = {
        value: function() {
          return element.value;
        },
        checked: function() {
          return element.checked;
        },
        focus: function() {
          return element.focus();
        },
        blur: function() {
          return element.blur();
        },
        select: function() {
          return element.select();
        },
        fn: {
          pInputListeners: [],
          name: tagName,
          element: element,
          parent: parent,
          off: function() {}
        }
      };
      exports.setStyle(component, style);
      (appendChildren = function(children) {
        return children.forEach(function(x) {
          var ref1;
          if ((ref1 = typeof x) === 'string' || ref1 === 'number') {
            return exports.setStyle(component, {
              text: x
            });
          } else if (Array.isArray(x)) {
            return appendChildren(x);
          } else {
            return exports.append(component, x);
          }
        });
      })(children);
      return component;
    };
    return function() {
      var args, children, component, firstArg, l, prevOff, restOfArgs, style, tagName;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      firstArg = args[0];
      if (typeof firstArg === 'function') {
        l = log.E0(thisComponent);
        restOfArgs = args.slice(1);
        l(null, restOfArgs);
        component = firstArg.apply(null, restOfArgs);
        component.fn.parent = thisComponent;
        l(component, restOfArgs);
      } else {
        if (typeof firstArg === 'string') {
          tagName = firstArg;
          style = args[1] || {};
          children = args.slice(2);
        } else if (typeof firstArg === 'object' && !Array.isArray(firstArg)) {
          tagName = 'div';
          style = firstArg || {};
          children = args.slice(1);
        } else {
          tagName = 'div';
          style = {};
          children = args.slice(1);
        }
        l = log.E1(thisComponent, tagName, style, children, parent);
        l();
        component = e(thisComponent, tagName, style, children);
        l();
      }
      prevOff = thisComponent.fn.off;
      thisComponent.fn.off = function() {
        prevOff();
        return component.fn.off();
      };
      return component;
    };
  })();
  exports.text = function(text) {
    var component, l;
    l = log.text(thisComponent, text);
    l();
    component = {
      fn: {
        name: "text[" + text + "]",
        element: document.createTextNode(text),
        off: function() {}
      }
    };
    l();
    return component;
  };
  exports.append = function(parent, component) {
    var base, l;
    if (!component) {
      return;
    }
    if (Array.isArray(component)) {
      return component.forEach(function(component) {
        return exports.append(parent, component);
      });
    }
    l = log.append(thisComponent, parent, component);
    l();
    parent.fn.element.appendChild(component.fn.element);
    component.fn.domParent = parent;
    if ((base = parent.fn).childComponents == null) {
      base.childComponents = [];
    }
    parent.fn.childComponents.push(component);
    return l();
  };
  exports.detatch = function(component) {
    var element, l;
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.detatch(component);
      });
    }
    element = component.fn.element;
    l = log.detatch(thisComponent, component);
    l();
    element.parentNode.removeChild(element);
    remove(component.fn.domParent.fn.childComponents, component);
    return l();
  };
  exports.destroy = function(component) {
    var l;
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.destroy(component);
      });
    }
    l = log.destroy(thisComponent, component);
    l();
    exports.detatch(component);
    component.fn.off();
    return l();
  };
  exports.empty = function(component) {
    var element, l, ref1;
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.empty(elemcomponentent);
      });
    }
    element = component.fn.element;
    l = log.empty(thisComponent, component);
    l();
    if ((ref1 = component.fn.childComponents) != null) {
      ref1.slice().forEach(exports.destroy);
    }
    return l();
  };
  exports.setStyle = function(component, style) {
    var element, l;
    if (style == null) {
      style = {};
    }
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.setStyle(component, style);
      });
    }
    element = component.fn.element;
    l = log.setStyle(thisComponent, component, style, thisComponent);
    l();
    component.fn.style = style;
    Object.keys(style).forEach(function(key) {
      var value;
      value = style[key];
      switch (key) {
        case 'text':
          return element.textContent = element.innerText = toPersian(value);
        case 'englishText':
          return element.textContent = element.innerText = value != null ? value : '';
        case 'value':
          if (element.value !== toPersian(value)) {
            element.value = toPersian(value);
            return setTimeout(function() {
              return component.fn.pInputListeners.forEach(function(x) {
                return x({});
              });
            });
          }
          break;
        case 'englishValue':
          if (element.value !== value) {
            element.value = value != null ? value : '';
            return setTimeout(function() {
              return component.fn.pInputListeners.forEach(function(x) {
                return x({});
              });
            });
          }
          break;
        case 'checked':
          return element.checked = value;
        case 'placeholder':
          return element.setAttribute(key, toPersian(value));
        case 'class':
        case 'type':
        case 'id':
        case 'for':
        case 'src':
        case 'href':
        case 'target':
          return element.setAttribute(key, value);
        default:
          if ((typeof value === 'number') && !(key === 'opacity' || key === 'zIndex')) {
            value = Math.floor(value) + 'px';
          }
          if (key === 'float') {
            key = 'cssFloat';
          }
          return element.style[key] = value;
      }
    });
    l();
    return component;
  };
  exports.addClass = function(component, klass) {
    var element, l, ref1;
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.addClass(component, klass);
      });
    }
    if (Array.isArray(klass)) {
      klass.forEach(function(klass) {
        return exports.addClass(component, klass);
      });
      return component;
    }
    exports.removeClass(component, klass);
    element = component.fn.element;
    l = log.addClass(thisComponent, component, klass);
    l();
    element.setAttribute('class', (((ref1 = element.getAttribute('class')) != null ? ref1 : '') + ' ' + klass).replace(/\ +/g, ' ').trim());
    l();
    return component;
  };
  exports.removeClass = function(component, klass) {
    var classIndex, element, l, previousClass, ref1;
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.removeClass(component, klass);
      });
    }
    if (Array.isArray(klass)) {
      klass.forEach(function(klass) {
        return exports.removeClass(component, klass);
      });
      return component;
    }
    element = component.fn.element;
    l = log.removeClass(thisComponent, component, klass);
    l();
    previousClass = (ref1 = element.getAttribute('class')) != null ? ref1 : '';
    classIndex = previousClass.indexOf(klass);
    if (~classIndex) {
      element.setAttribute('class', ((previousClass.substr(0, classIndex)) + (previousClass.substr(classIndex + klass.length))).replace(/\ +/g, ' ').trim());
    }
    l();
    return component;
  };
  exports.show = function(component) {
    var l;
    l = log.show(thisComponent, component);
    l();
    exports.removeClass(component, 'hidden');
    l();
    return component;
  };
  exports.hide = function(component) {
    var l;
    l = log.hide(thisComponent, component);
    l();
    exports.addClass(component, 'hidden');
    l();
    return component;
  };
  exports.enable = function(component) {
    var element, l;
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.enable(component);
      });
    }
    element = component.fn.element;
    l = log.enable(thisComponent, component);
    l();
    element.removeAttribute('disabled');
    l();
    return component;
  };
  exports.disable = function(component) {
    var element, l;
    if (Array.isArray(component)) {
      return component.map(function(component) {
        return exports.disable(component);
      });
    }
    element = component.fn.element;
    l = log.disable(thisComponent, component);
    l();
    element.setAttribute('disabled', 'disabled');
    l();
    return component;
  };
  return exports;
};


},{".":38,"./log":39}],37:[function(require,module,exports){
var body, isIn, log, ref, remove, window,
  slice = [].slice;

log = require('./log').events;

ref = require('./dom'), window = ref.window, body = ref.body;

remove = require('.').remove;

isIn = function(component, arg) {
  var maxX, maxY, minX, minY, pageX, pageY, rect;
  pageX = arg.pageX, pageY = arg.pageY;
  rect = component.fn.element.getBoundingClientRect();
  minX = rect.left;
  maxX = rect.left + rect.width;
  minY = rect.top + window().fn.element.scrollY;
  maxY = rect.top + window().fn.element.scrollY + rect.height;
  return (minX < pageX && pageX < maxX) && (minY < pageY && pageY < maxY);
};

exports.instance = function(thisComponent) {
  var exports;
  exports = {};
  exports.onEvent = function() {
    var args, callback, component, element, event, ignores, l, prevOff, unbind, unbinds;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    switch (args.length) {
      case 3:
        component = args[0], event = args[1], callback = args[2];
        break;
      case 4:
        component = args[0], event = args[1], ignores = args[2], callback = args[3];
        if (!Array.isArray(ignores)) {
          ignores = [ignores].filter(function(x) {
            return x;
          });
        }
    }
    if (Array.isArray(component)) {
      unbinds = component.map(function(component) {
        args[0] = component;
        return exports.onEvent.apply(null, args);
      });
      return function() {
        return unbinds.forEach(function(unbind) {
          return unbind();
        });
      };
    }
    if (Array.isArray(event)) {
      unbinds = event.map(function(event) {
        args[1] = event;
        return exports.onEvent.apply(null, args);
      });
      return function() {
        return unbinds.forEach(function(unbind) {
          return unbind();
        });
      };
    }
    element = component.fn.element;
    l = log.onEvent(thisComponent, component, event, ignores, callback);
    callback = (function(callback) {
      return function(e) {
        var shouldIgnore, target;
        if (e.target == null) {
          e.target = e.srcElement;
        }
        if (ignores) {
          target = e.target;
          while (target && target !== document && target !== document.body) {
            shouldIgnore = ignores.some(function(ignore) {
              if (target === ignore.fn.element) {
                l.ignore(ignore, e);
                return true;
              }
            });
            if (shouldIgnore) {
              return;
            }
            target = target.parentNode || target.parentElement;
          }
        }
        l(1, e);
        callback(e);
        return l(1, e);
      };
    })(callback);
    l(0);
    if (event === 'pInput') {
      component.fn.pInputListeners.push(callback);
    } else if (element.addEventListener) {
      element.addEventListener(event, callback);
    } else if (element.attachEvent) {
      element.attachEvent("on" + (uppercaseFirst(event)), callback);
    }
    l(0);
    unbind = function() {
      l(2);
      if (event === 'pInput') {
        remove(component.fn.pInputListeners, callback);
      } else if (element.removeEventListener) {
        element.removeEventListener(event, callback);
      } else if (element.detachEvent) {
        element.detachEvent("on" + (uppercaseFirst(event)), callback);
      }
      return l(2);
    };
    prevOff = component.fn.off;
    component.fn.off = function() {
      prevOff();
      return unbind();
    };
    return unbind;
  };
  exports.onLoad = function(callback) {
    var l, unbind;
    l = log.onLoad(thisComponent, callback);
    l(0);
    unbind = exports.onEvent(window(), 'load', function(e) {
      l(1, e);
      callback(e);
      return l(1, e);
    });
    l(0);
    return function() {
      l(2);
      unbind();
      return l(2);
    };
  };
  exports.onResize = function(callback) {
    var l, unbind;
    l = log.onResize(thisComponent, callback);
    l(0);
    unbind = exports.onEvent(window(), 'resize', function(e) {
      l(1, e);
      callback(e);
      return l(1, e);
    });
    l(0);
    return function() {
      l(2);
      unbind();
      return l(2);
    };
  };
  exports.onMouseover = function(component, callback) {
    var allreadyIn, l, unbind;
    l = log.onMouseover(thisComponent, component, callback);
    allreadyIn = false;
    l(0);
    unbind = exports.onEvent(body(), 'mousemove', function(e) {
      if (isIn(component, e)) {
        l(1, e);
        if (!allreadyIn) {
          callback(e);
        }
        l(1, e);
        return allreadyIn = true;
      } else {
        return allreadyIn = false;
      }
    });
    l(0);
    return function() {
      l(2);
      unbind();
      return l(2);
    };
  };
  exports.onMouseout = function(component, callback) {
    var allreadyOut, l, unbind0, unbind1;
    l = log.onMouseout(thisComponent, component, callback);
    allreadyOut = false;
    if (component) {
      l(0.0);
      unbind0 = exports.onEvent(body(), 'mousemove', function(e) {
        if (!isIn(component, e)) {
          l(1.0, e);
          if (!allreadyOut) {
            callback(e);
          }
          l(1.0, e);
          return allreadyOut = true;
        } else {
          return allreadyOut = false;
        }
      });
      l(0.0);
    }
    l(0.1);
    unbind1 = exports.onEvent(body(), 'mouseout', function(e) {
      var from;
      from = e.relatedTarget || e.toElement;
      if (!from || from.nodeName === 'HTML') {
        l(1.1, e);
        allreadyOut = true;
        callback(e);
        return l(1.1, e);
      }
    });
    l(0.1);
    return function() {
      l(2.0);
      if (typeof unbind0 === "function") {
        unbind0();
      }
      l(2.0);
      l(2.1);
      unbind1();
      return l(2.1);
    };
  };
  exports.onMouseup = function(callback) {
    var unbind0, unbind1;
    l(0.0);
    unbind0 = exports.onEvent(body(), 'mouseup', function(e) {
      l(1.0, e);
      callback(e);
      return l(1.0, e);
    });
    l(0.0);
    l(0.1);
    unbind1 = exports.onEvent(body(), 'mouseout', function(e) {
      var from;
      from = e.relatedTarget || e.toElement;
      if (!from || from.nodeName === 'HTML') {
        l(1.1, e);
        callback(e);
        return l(1.1, e);
      }
    });
    l(0.1);
    return function() {
      l(2.0);
      unbind0();
      l(2.0);
      l(2.1);
      unbind1();
      return l(2.1);
    };
  };
  exports.onEnter = function(component, callback) {
    var l, unbind;
    l = log.onEnter(thisComponent, component, callback);
    l(0);
    unbind = exports.onEvent(component, 'keydown', function(e) {
      if (e.keyCode === 13) {
        l(1, e);
        callback();
        return l(1, e);
      }
    });
    l(0);
    return function() {
      l(2);
      unbind();
      return l(2);
    };
  };
  return exports;
};


},{".":38,"./dom":36,"./log":39}],38:[function(require,module,exports){
var slice = [].slice;

exports.compare = function(a, b) {
  if (a > b) {
    return 1;
  } else if (a < b) {
    return -1;
  } else {
    return 0;
  }
};

exports.remove = function(array, item) {
  var index;
  index = array.indexOf(item);
  if (~index) {
    array.splice(index, 1);
  }
  return array;
};

exports.extend = function() {
  var sources, target;
  target = arguments[0], sources = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  sources.forEach(function(source) {
    return Object.keys(source).forEach(function(key) {
      return target[key] = source[key];
    });
  });
  return target;
};

exports.uppercaseFirst = function(name) {
  return name.charAt(0).toUpperCase() + name.substr(1);
};

exports.toEnglish = function(value) {
  if (value == null) {
    value = '';
  }
  value = '' + value;
  '۰۱۲۳۴۵۶۷۸۹'.split('').forEach(function(digit, i) {
    return value = value.replace(new RegExp(digit, 'g'), i);
  });
  return value.replace('/', '.');
};

exports.toPersian = function(value) {
  if (value == null) {
    value = '';
  }
  value = '' + value;
  '۰۱۲۳۴۵۶۷۸۹'.split('').forEach(function(digit, i) {
    return value = value.replace(new RegExp('' + i, 'g'), digit);
  });
  return value.replace(/ي/g, 'ی').replace(/ك/g, 'ک');
};

exports.toDate = function(timestamp) {
  var date, day, j, month, year;
  date = new Date(timestamp);
  day = date.getDate();
  month = date.getMonth() + 1;
  year = date.getFullYear();
  j = jalaali.toJalaali(year, month, day);
  day = j.jd;
  month = j.jm;
  year = j.jy;
  return String(year).substr(2) + '/' + month + '/' + day;
};

exports.textIsInSearch = function(text, search, notPersian, caseSensitive) {
  var searchWords, textWords;
  if (!notPersian) {
    text = exports.toPersian(text);
    search = exports.toPersian(search);
  }
  if (!caseSensitive) {
    text = text.toLowerCase();
    search = search.toLowerCase();
  }
  searchWords = search.trim().split(' ').map(function(x) {
    return x.trim();
  }).filter(function(x) {
    return x;
  });
  textWords = text.trim().split(' ').map(function(x) {
    return x.trim();
  }).filter(function(x) {
    return x;
  });
  return searchWords.every(function(searchWord) {
    return textWords.some(function(textWord) {
      return ~textWord.indexOf(searchWord);
    });
  });
};

exports.collection = function(add, destroy, change) {
  var data;
  data = [];
  return function(newData) {
    var k, l, m, n, ref, ref1, ref2, ref3, ref4, results, results1, results2, results3, results4;
    if (newData.length > data.length) {
      if (data.length) {
        (function() {
          results = [];
          for (var k = 0, ref = data.length - 1; 0 <= ref ? k <= ref : k >= ref; 0 <= ref ? k++ : k--){ results.push(k); }
          return results;
        }).apply(this).forEach(function(i) {
          return data[i] = change(newData[i], data[i]);
        });
      }
      return (function() {
        results1 = [];
        for (var l = ref1 = data.length, ref2 = newData.length - 1; ref1 <= ref2 ? l <= ref2 : l >= ref2; ref1 <= ref2 ? l++ : l--){ results1.push(l); }
        return results1;
      }).apply(this).forEach(function(i) {
        return data[i] = add(newData[i]);
      });
    } else if (data.length > newData.length) {
      if (newData.length) {
        (function() {
          results2 = [];
          for (var m = 0, ref3 = newData.length - 1; 0 <= ref3 ? m <= ref3 : m >= ref3; 0 <= ref3 ? m++ : m--){ results2.push(m); }
          return results2;
        }).apply(this).forEach(function(i) {
          return data[i] = change(newData[i], data[i]);
        });
      }
      results3 = [];
      while (data.length > newData.length) {
        destroy(data[data.length - 1]);
        results3.push(data.splice(data.length - 1, 1));
      }
      return results3;
    } else if (data.length) {
      return (function() {
        results4 = [];
        for (var n = 0, ref4 = data.length - 1; 0 <= ref4 ? n <= ref4 : n >= ref4; 0 <= ref4 ? n++ : n--){ results4.push(n); }
        return results4;
      }).apply(this).forEach(function(i) {
        return data[i] = change(newData[i], data[i]);
      });
    }
  };
};


},{}],39:[function(require,module,exports){
var getFullName, log;

log = function(x) {
  return console.log(x);
};

getFullName = function(component) {
  var name;
  name = '';
  while (component) {
    name = component.fn.name + ">" + name;
    component = component.parent;
  }
  return name.substr(0, name.length - 1);
};

exports.component = {
  create: function(part, component) {
    return;
    return log(part + ":create:" + (getFullName(component)));
  }
};

exports.dom = {
  E0: function(thisComponent) {
    var part;
    part = 0;
    return function(component, args) {
      var error, stringifiedArgs;
      return;
      try {
        stringifiedArgs = JSON.stringify(args);
      } catch (error) {
        stringifiedArgs = '[Cannot Stringify]';
      }
      return log((part++) + ":dom.E:" + (component ? getFullName(component) : 'UnknownComponent') + (args.length ? ':' + stringifiedArgs : '') + "|" + (getFullName(thisComponent)));
    };
  },
  E1: function(thisComponent, tagName, style, children) {
    var logText, part;
    logText = "dom.E:" + (getFullName({
      fn: {
        name: tagName,
        parent: thisComponent
      }
    }));
    if (Object.keys(style).length) {
      logText += ':' + JSON.stringify(style);
    }
    if (children.length) {
      logText += ':HasChildren';
    }
    logText += "|" + (getFullName(thisComponent));
    part = 0;
    return function() {
      return;
      return log((part++) + ":" + logText);
    };
  },
  text: function(thisComponent, text) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.text:" + text + "|" + (getFullName(thisComponent)));
    };
  },
  append: function(thisComponent, parent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.append:" + (getFullName(parent)) + "--->" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  detatch: function(thisComponent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.detatch:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  destroy: function(thisComponent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.destroy:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  empty: function(thisComponent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.empty:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  setStyle: function(thisComponent, component, style) {
    var logText, part;
    logText = "dom.setStyle:" + (getFullName(component));
    if (Object.keys(style).length) {
      logText += ':' + JSON.stringify(style);
    }
    logText += "|" + (getFullName(thisComponent));
    part = 0;
    return function() {
      return;
      return log((part++) + ":" + logText);
    };
  },
  addClass: function(thisComponent, component, klass) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.addClass:" + (getFullName(component)) + ":" + klass + "|" + (getFullName(thisComponent)));
    };
  },
  removeClass: function(thisComponent, component, klass) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.removeClass:" + (getFullName(component)) + ":" + klass + "|" + (getFullName(thisComponent)));
    };
  },
  show: function(thisComponent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.show:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  hide: function(thisComponent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.hide:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  enable: function(thisComponent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.enable:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  disable: function(thisComponent, component) {
    var part;
    part = 0;
    return function() {
      return;
      return log((part++) + ":dom.disable:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  }
};

exports.events = {
  onEvent: function(thisComponent, component, event, ignores, callback) {
    var l, logText, parts;
    logText = "events.onEvent:" + (getFullName(component)) + ":" + event;
    if (ignores) {
      logText += ":ignore:" + (JSON.stringify(ignores.map(function(component) {
        return getFullName(component);
      })));
    }
    logText += "|" + (getFullName(thisComponent));
    parts = [0, 0, 0];
    l = function(partIndex, e) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + (e ? ':' + JSON.stringify(e) : '') + ":" + logText);
    };
    l.ignore = function(ignoredComponent, e) {
      return;
      return log("ignore " + (getFullName(ignoredComponent)) + (e ? ':' + JSON.stringify(e) : '') + ":" + logText);
    };
    return l;
  },
  onLoad: function(thisComponent, callback) {
    var parts;
    parts = [0, 0, 0];
    return function(partIndex) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + ":events.onLoad|" + (getFullName(thisComponent)));
    };
  },
  onResize: function(thisComponent, callback) {
    var parts;
    parts = [0, 0, 0];
    return function(partIndex) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + ":events.onResize|" + (getFullName(thisComponent)));
    };
  },
  onMouseover: function(thisComponent, component, callback) {
    var parts;
    parts = [0, 0, 0];
    return function(partIndex) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + ":events.onMouseover:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  onMouseout: function(thisComponent, component, callback) {
    var parts;
    parts = [0, 0, 0];
    return function(partIndex) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + ":events.onMouseout:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  },
  onMouseup: function(thisComponent, callback) {
    var parts;
    parts = [0, 0, 0];
    return function(partIndex) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + ":events.onMouseup|" + (getFullName(thisComponent)));
    };
  },
  onEnter: function(thisComponent, component, callback) {
    var parts;
    parts = [0, 0, 0];
    return function(partIndex) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + ":events.onEnter:" + (getFullName(component)) + "|" + (getFullName(thisComponent)));
    };
  }
};

exports.state = {
  createPubsub: function(thisComponent) {
    return {
      on: function(options, callback) {
        var parts;
        parts = [0, 0, 0];
        return function(partIndex, data) {
          var logText;
          return;
          logText = partIndex + ":" + (parts[partIndex]++) + ":state.createPubsub.on:" + (JSON.stringify(options));
          if (partIndex === 1) {
            logText += ':' + JSON.stringify(data);
          }
          logText += "|" + (getFullName(thisComponent));
          return log(logText);
        };
      },
      set: function(data) {
        var part;
        part = 0;
        return function() {
          return;
          return log((part++) + ":state.createPubsub.set:" + (JSON.stringify(data)) + "|" + (getFullName(thisComponent)));
        };
      }
    };
  },
  pubsub: function(thisComponent, name) {
    return {
      on: function(options, callback) {
        var parts;
        parts = [0, 0, 0];
        return function(partIndex, data) {
          var logText;
          return;
          logText = partIndex + ":" + (parts[partIndex]++) + ":state.pubsub.on:" + name + ":" + (JSON.stringify(options));
          if (partIndex === 1) {
            logText += ':' + JSON.stringify(data);
          }
          logText += "|" + (getFullName(thisComponent));
          return log(logText);
        };
      },
      set: function(data) {
        var part;
        part = 0;
        return function() {
          return;
          return log((part++) + ":state.pubsub.set:" + name + ":" + (JSON.stringify(data)) + "|" + (getFullName(thisComponent)));
        };
      }
    };
  },
  all: function(thisComponent, options, keys, callback) {
    var parts;
    parts = [0, 0, 0];
    return function(partIndex, data) {
      return;
      return log(partIndex + ":" + (parts[partIndex]++) + ":state.all:" + (JSON.stringify(keys)) + ":" + (JSON.stringify(options)) + (data ? ':' + JSON.stringify(data) : '') + "|" + (getFullName(thisComponent)));
    };
  }
};

exports.service = {
  get: function(thisComponent, url, params) {
    return function(data) {
      return;
      return log("service.get:" + url + (params ? ':' + JSON.stringify(params) : '') + (data ? ':' + JSON.stringify(data) : '') + "|" + (getFullName(thisComponent)));
    };
  },
  post: function(thisComponent, url, params) {
    return function(data) {
      return;
      return log("service.post:" + url + (params ? ':' + JSON.stringify(params) : '') + (data ? ':' + JSON.stringify(data) : '') + "|" + (getFullName(thisComponent)));
    };
  }
};


},{}],40:[function(require,module,exports){
exports.emailIsValid = function(email) {
  return /^.+@.+\..+$/.test(email);
};

exports.passwordIsValid = function(password) {
  return password.length >= 6;
};


},{}],41:[function(require,module,exports){
var Q, mock;

Q = require('../../q');

mock = require('./mock');

module.exports = function(isGet, serviceName, params) {
  var url;
  if (params == null) {
    params = {};
  }
  if (mock[serviceName]) {
    return mock[serviceName](params);
  }
  url = "/" + serviceName;
  if (isGet) {
    url += '?' + Object.keys(params).map(function(param) {
      return param + "=" + params[param];
    }).join('&');
  }
  return Q.promise(function(resolve, reject) {
    var methodType, xhr;
    xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          return resolve(JSON.parse(xhr.responseText));
        } else {
          return reject(xhr.responseText);
        }
      }
    };
    methodType = isGet ? 'GET' : 'POST';
    xhr.open(methodType, url, true);
    if (isGet) {
      return xhr.send();
    } else {
      xhr.setRequestHeader('Content-Type', 'application/json');
      return xhr.send(JSON.stringify(params));
    }
  });
};


},{"../../q":28,"./mock":45}],42:[function(require,module,exports){
var Q, cruds, eraseCookie, get, gets, post, posts, ref, ref1, state, stateChangingServices, uppercaseFirst,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Q = require('../../q');

state = require('../state');

stateChangingServices = require('./stateChangingServices');

ref = require('./names'), gets = ref.gets, posts = ref.posts, cruds = ref.cruds;

ref1 = require('./getPost'), get = ref1.get, post = ref1.post;

eraseCookie = require('../cookies').eraseCookie;

uppercaseFirst = require('..').uppercaseFirst;

exports.logout = function(automatic) {
  if (automatic !== true) {
    stateChangingServices.logout.running = true;
  }
  ['person', 'gpa', 'grades', 'isTrained'].forEach(function(x) {
    return state[x].set(null);
  });
  eraseCookie('id');
  if (automatic !== true) {
    eraseCookie('data');
  }
  state.cas.on({
    once: true,
    allowNull: true
  }, function(cas) {
    if (automatic !== true) {
      stateChangingServices.logout.running = false;
      stateChangingServices.logout.endedAt = +new Date();
    }
    if (cas) {
      while (document.body.children.length) {
        document.body.removeChild(document.body.children[0]);
      }
      return location.href = 'https://auth.ut.ac.ir:8443/cas/logout';
    }
  });
  return Q();
};

exports.casLogin = function(x) {
  return post('casLogin', x).then(function() {
    return state.cas.set(true);
  });
};

exports.setStaticData = function(x) {
  return post('setStaticData', x).then(function() {
    return x.forEach(function(x) {
      if (x.key === 'currentTerm') {
        return state.currentTerm.set(x.value);
      }
    });
  });
};

gets.forEach(function(x) {
  return exports[x] = function(params) {
    return get(x, params);
  };
});

posts.forEach(function(x) {
  return exports[x] = function(params) {
    return post(x, params);
  };
});

cruds.forEach(function(arg) {
  var name, persianName, serviceName;
  name = arg.name, persianName = arg.persianName;
  posts.push(serviceName = "update" + (uppercaseFirst(name)));
  return exports[serviceName] = function(entity) {
    return post(serviceName, entity).then(function() {
      return state[name + "s"].on({
        once: true
      }, function(entities) {
        entities = entities.filter(function(arg1) {
          var id;
          id = arg1.id;
          return id !== entity.id;
        });
        entities.push(entity);
        return state[name + "s"].set(entities);
      });
    });
  };
});

cruds.forEach(function(arg) {
  var name, persianName, serviceName;
  name = arg.name, persianName = arg.persianName;
  posts.push(serviceName = "create" + (uppercaseFirst(name)));
  return exports[serviceName] = function(entity) {
    return post(serviceName, entity).then(function(id) {
      return state[name + "s"].on({
        once: true
      }, function(entities) {
        extend(entity, {
          id: id
        });
        entities.push(entity);
        return state[name + "s"].set(entities);
      });
    });
  };
});

cruds.forEach(function(arg) {
  var name, persianName, serviceName;
  name = arg.name, persianName = arg.persianName;
  posts.push(serviceName = "delete" + (uppercaseFirst(name)) + "s");
  return exports[serviceName] = function(ids) {
    return post(serviceName, {
      ids: ids
    }).then(function() {
      return state[name + "s"].on({
        once: true
      }, function(entities) {
        entities = entities.filter(function(arg1) {
          var id;
          id = arg1.id;
          return !(indexOf.call(ids, id) >= 0);
        });
        return state[name + "s"].set(entities);
      });
    });
  };
});


},{"..":38,"../../q":28,"../cookies":35,"../state":48,"./getPost":43,"./names":46,"./stateChangingServices":47}],43:[function(require,module,exports){
var ajax, ex, handle, state, stateChangingServices, states;

ajax = require('./ajax');

stateChangingServices = require('./stateChangingServices');

ex = require('./ex');

states = require('./names').states;

state = require('../state');

handle = function(isGet) {
  return function(serviceName, params) {
    var ref, startedAt;
    if ((ref = stateChangingServices[serviceName]) != null) {
      ref.running = true;
    }
    startedAt = +new Date();
    return ajax(isGet, serviceName, params).then(function(response) {
      states.forEach(function(name) {
        var dontSetState, ref1, ref2, responseValue;
        if ((ref1 = stateChangingServices[serviceName]) != null) {
          ref1.running = false;
        }
        if ((ref2 = stateChangingServices[serviceName]) != null) {
          ref2.endedAt = +new Date();
        }
        dontSetState = Object.keys(stateChangingServices).some(function(_serviceName) {
          var service;
          service = stateChangingServices[_serviceName];
          if (service.stateName === name) {
            if (_serviceName === serviceName) {
              return false;
            } else if (service.running) {
              return true;
            } else if (!service.endedAt) {
              return false;
            } else {
              return service.endedAt >= startedAt;
            }
          } else {
            return false;
          }
        });
        if (!dontSetState) {
          if (response[name]) {
            responseValue = response[name];
            setTimeout(function() {
              return state[name].set(responseValue);
            });
          }
          if (name === 'person' && response.loggedOut) {
            return setTimeout(function() {
              return ex.logout(true);
            });
          }
        }
      });
      delete response.person;
      delete response.loggedOut;
      if (response.value != null) {
        response = response.value;
      }
      return response;
    });
  };
};

exports.get = handle(true);

exports.post = handle(false);


},{"../state":48,"./ajax":41,"./ex":42,"./names":46,"./stateChangingServices":47}],44:[function(require,module,exports){
var ex, gets, log, others, post, posts, ref;

ex = require('./ex');

ref = require('./names'), gets = ref.gets, posts = ref.posts, others = ref.others;

post = require('./getPost').post;

log = require('../log').service;

exports.instance = function(thisComponent) {
  var exports;
  exports = {};
  gets.concat(posts).concat(others).forEach(function(x) {
    return exports[x] = function(params) {
      var l;
      l = log.get(thisComponent, x, params);
      l();
      return ex[x](params).then(function(data) {
        l(data);
        return data;
      });
    };
  });
  return exports;
};

exports.extendModule = function(fn) {
  return fn(ex);
};

exports.getPerson = function() {
  return post('getPerson');
};

exports.autoPing = function() {
  var fn;
  return (fn = function() {
    return post('ping').fin(function() {
      return setTimeout(fn);
    });
  })();
};


},{"../log":39,"./ex":42,"./getPost":43,"./names":46}],45:[function(require,module,exports){
return;


},{}],46:[function(require,module,exports){
exports.gets = ['loginEmailValid'];

exports.posts = ['getPermissions', 'getRoles', 'getPersons', 'getProfessors', 'getChores', 'getCurrentTerm', 'getTerms', 'getOfferings', 'getCourses', 'getRequestForAssistants', 'getStudentRequestForAssistants', 'getProfessorOfferings', 'reportBug', 'cas', 'login', 'register', 'changeEmail', 'addRequiredCourse', 'removeRequiredCourse', 'sendRequestForAssistant', 'changeRequestForAssistant', 'deleteRequestForAssistant', 'closeOffering', 'batchAddOfferings', 'sendEmail', 'resetPassword'];

exports.cruds = [
  {
    name: 'person',
    persianName: 'شخص'
  }, {
    name: 'course',
    persianName: 'درس'
  }, {
    name: 'offering',
    persianName: 'گروه درسی'
  }, {
    name: 'requestForAssistant',
    persianName: 'درخواست'
  }
];

exports.others = ['logout', 'casLogin', 'setStaticData'];

exports.states = ['person', 'roles', 'permissions', 'terms', 'currentTerm', 'offerings', 'courses', 'persons', 'chores', 'professors', 'deputies', 'requestForAssistants', 'studentDegree', 'studentRequestForAssistants', 'professorOfferings'];


},{}],47:[function(require,module,exports){
var cruds, uppercaseFirst;

cruds = require('./names').cruds;

uppercaseFirst = require('..').uppercaseFirst;

module.exports = {
  logout: {
    stateName: 'person'
  },
  register: {
    stateName: 'person'
  },
  login: {
    stateName: 'person'
  },
  casLogin: {
    stateName: 'person'
  },
  verify: {
    stateName: 'person'
  },
  addRequiredCourse: {
    stateName: 'proferrorOfferings'
  },
  removeRequiredCourse: {
    stateName: 'proferrorOfferings'
  },
  sendRequestForAssistant: {
    stateName: 'studentRequestForAssistants'
  },
  deleteRequestForAssistant: {
    stateName: 'studentRequestForAssistants'
  },
  changeRequestForAssistantState: {
    stateName: 'professorOfferings'
  },
  closeOffering: {
    stateName: 'professorOfferings'
  },
  batchAddOfferings: {
    stateName: 'offerings'
  }
};

cruds.forEach(function(arg) {
  var name;
  name = arg.name;
  ['create', 'update'].forEach(function(method) {
    return module.exports["" + method + (uppercaseFirst(name))] = {
      stateName: name + "s"
    };
  });
  return module.exports["delete" + (uppercaseFirst(name)) + "s"] = {
    stateName: name + "s"
  };
});


},{"..":38,"./names":46}],48:[function(require,module,exports){
var createPubSub, log, names, pubSubs;

names = require('./names');

log = require('../log').state;

createPubSub = function(name) {
  var data, dataNotNull, subscribers;
  data = dataNotNull = void 0;
  subscribers = [];
  return {
    on: function(options, callback) {
      var firstDataSent, unsubscribe, wrappedCallback;
      firstDataSent = false;
      if (!options.omitFirst) {
        if (!options.allowNull) {
          if (dataNotNull !== void 0) {
            callback(dataNotNull);
            firstDataSent = true;
          }
        } else {
          callback(data);
          firstDataSent = true;
        }
      }
      if (options.once && !options.omitFirst && firstDataSent) {
        return function() {};
      }
      subscribers.push(wrappedCallback = function(data) {
        if (!options.allowNull && (data == null)) {
          return;
        }
        callback(data);
        if (options.once) {
          return unsubscribe();
        }
      });
      return unsubscribe = function() {
        var index;
        index = subscribers.indexOf(wrappedCallback);
        if (~index) {
          return subscribers.splice(index, 1);
        }
      };
    },
    set: function(_data) {
      if (JSON.stringify(data) === JSON.stringify(_data)) {
        return;
      }
      data = _data;
      if (data != null) {
        dataNotNull = data;
      }
      return subscribers.forEach(function(callback) {
        return callback(data);
      });
    }
  };
};

pubSubs = names.map(function(name) {
  return {
    name: name,
    pubSub: exports[name] = createPubSub(name)
  };
});

exports.instance = function(thisComponent) {
  var exports;
  exports = {};
  exports.createPubSub = function(name) {
    var l, pubsub;
    l = log.pubsub(thisComponent, name);
    pubsub = createPubSub(name);
    return {
      on: function() {
        var callback, ll, options, prevOff, unsubscribe;
        if (arguments.length === 1) {
          callback = arguments[0];
          options = {};
        } else {
          options = arguments[0], callback = arguments[1];
        }
        ll = l.on(options, callback);
        ll(0);
        unsubscribe = pubSub.on(options, function(data) {
          ll(1, data);
          callback(data);
          return ll(1, data);
        });
        ll(0);
        unsubscribe = (function(unsubscribe) {
          return function() {
            ll(2);
            unsubscribe();
            return ll(2);
          };
        })(unsubscribe);
        prevOff = thisComponent.fn.off;
        thisComponent.fn.off = function() {
          prevOff();
          return unsubscribe();
        };
        return unsubscribe;
      },
      set: function() {
        var ll;
        ll = l.set(data);
        ll();
        pubSub.set(data);
        return ll();
      }
    };
  };
  pubSubs.forEach(function(arg) {
    var instancePubSub, l, name, pubSub;
    name = arg.name, pubSub = arg.pubSub;
    l = log.pubsub(thisComponent, name);
    instancePubSub = {};
    instancePubSub.on = function() {
      var callback, ll, options, prevOff, unsubscribe;
      if (arguments.length === 1) {
        callback = arguments[0];
        options = {};
      } else {
        options = arguments[0], callback = arguments[1];
      }
      ll = l.on(options, callback);
      ll(0);
      unsubscribe = pubSub.on(options, function(data) {
        ll(1, data);
        callback(data);
        return ll(1, data);
      });
      ll(0);
      unsubscribe = (function(unsubscribe) {
        return function() {
          ll(2);
          unsubscribe();
          return ll(2);
        };
      })(unsubscribe);
      prevOff = thisComponent.fn.off;
      thisComponent.fn.off = function() {
        prevOff();
        return unsubscribe();
      };
      return unsubscribe;
    };
    instancePubSub.set = function(data) {
      var ll;
      ll = l.set(data);
      ll();
      pubSub.set(data);
      return ll();
    };
    return exports[name] = instancePubSub;
  });
  exports.all = function() {
    var callback, keys, l, options, prevOff, resolved, unsubscribe, unsubscribes, values;
    if (arguments.length === 2) {
      keys = arguments[0], callback = arguments[1];
      options = {};
    } else {
      keys = arguments[0], options = arguments[1], callback = arguments[2];
    }
    l = log.all(thisComponent, options, keys, callback);
    resolved = {};
    values = {};
    l(0);
    unsubscribes = keys.map(function(key) {
      return exports[key].on(options, function(value) {
        resolved[key] = true;
        values[key] = value;
        if (keys.every(function(keys) {
          return resolved[keys];
        })) {
          l(1);
          callback(keys.map(function(key) {
            return values[key];
          }));
          return l(1);
        }
      });
    });
    l(0);
    unsubscribe = function() {
      l(2);
      unsubscribes.forEach(function(unsubscribe) {
        return unsubscribe();
      });
      return l(2);
    };
    prevOff = thisComponent.fn.off;
    thisComponent.fn.off = function() {
      prevOff();
      return unsubscribe();
    };
    return unsubscribe;
  };
  return exports;
};

exports.persons.on({}, function(persons) {
  exports.professors.set(persons.filter(function(arg) {
    var type;
    type = arg.type;
    return type === 'استاد';
  }));
  return exports.deputies.set(persons.filter(function(arg) {
    var type;
    type = arg.type;
    return type === 'نماینده استاد';
  }));
});


},{"../log":39,"./names":49}],49:[function(require,module,exports){
module.exports = ['person', 'roles', 'permissions', 'terms', 'currentTerm', 'offerings', 'courses', 'persons', 'chores', 'professors', 'deputies', 'requestForAssistants', 'studentDegree', 'studentRequestForAssistants', 'professorOfferings', 'cas', 'gpa', 'grades', 'isTrained'];


},{}],50:[function(require,module,exports){
var component, extend, generateId, modal, numberInput, ref, toEnglish;

component = require('../../../utils/component');

modal = require('../../../singletons/modal');

numberInput = require('../../../components/restrictedInput/number');

generateId = require('../../../utils/dom').generateId;

ref = require('../../../utils'), extend = ref.extend, toEnglish = ref.toEnglish;

module.exports = component('coursesCredit', function(arg) {
  var E, allInputs, contents, disable, dom, enable, events, getServiceData, ids, name, number, offState, onEnter, onEvent, returnObject, service, setStyle, state;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, enable = dom.enable, disable = dom.disable;
  onEvent = events.onEvent, onEnter = events.onEnter;
  ids = [0, 1].map(generateId);
  name = E('input', {
    id: ids[0],
    "class": 'form-control'
  });
  number = E(numberInput, true);
  setStyle(number, {
    id: ids[1],
    "class": 'form-control'
  });
  contents = [
    E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[0]
    }, 'نام درس'), name), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[1]
    }, 'شماره درس'), number)
  ];
  allInputs = [name, number];
  onEvent(allInputs, ['input', 'pInput'], function() {
    return modal.instance.setEnabled(~name.value() && ~number.value());
  });
  onEnter(allInputs, function() {
    return modal.instance.submit();
  });
  allInputs.forEach(function(input) {
    return onEvent(input, ['focus', 'input'], function() {
      return input.dirty = true;
    });
  });
  getServiceData = function() {
    return {
      name: name.value(),
      number: toEnglish(number.value())
    };
  };
  offState = void 0;
  return returnObject({
    credit: function(isEdit) {
      return function(course) {
        allInputs.forEach(function(input) {
          return input.dirty = false;
        });
        if (isEdit) {
          offState = state.courses.on(function(courses) {
            course = (courses.filter(function(arg1) {
              var id;
              id = arg1.id;
              return id === course.id;
            }))[0];
            if (!course) {
              return modal.instance.hide();
            }
            if (!name.dirty) {
              setStyle(name, {
                value: course.name
              });
            }
            if (!number.dirty) {
              return setStyle(number, {
                value: course.number
              });
            }
          });
        } else {
          setStyle(name, {
            value: ''
          });
          setStyle(number, {
            value: ''
          });
        }
        return modal.instance.display({
          enabled: isEdit,
          autoHide: true,
          title: (isEdit ? 'جزئیات/ویرایش' : 'ایجاد') + ' درس',
          submitText: isEdit ? 'ثبت تغییرات' : 'ایجاد',
          closeText: isEdit ? 'لغو تغییرات' : 'لغو',
          contents: contents,
          close: function() {
            if (typeof offState === "function") {
              offState();
            }
            return offState = null;
          },
          submit: function() {
            var submitQ;
            allInputs.forEach(function(x) {
              return disable(x);
            });
            submitQ = isEdit ? service.updateCourse(extend({
              id: course.id
            }, getServiceData())) : service.createCourse(getServiceData());
            return submitQ.then(function() {
              return allInputs.forEach(function(x) {
                return enable(x);
              });
            })["catch"](function() {
              return allInputs.forEach(function(x) {
                return enable(x);
              });
            });
          }
        });
      };
    }
  });
});


},{"../../../components/restrictedInput/number":15,"../../../singletons/modal":33,"../../../utils":38,"../../../utils/component":34,"../../../utils/dom":36}],51:[function(require,module,exports){
var component, credit, crudPage, multiselect, numberInput, searchBoxStyle, textIsInSearch;

component = require('../../../utils/component');

crudPage = require('../crudPage');

credit = require('./credit');

multiselect = require('./multiselect');

searchBoxStyle = require('../../../components/table/searchBoxStyle');

numberInput = require('../../../components/restrictedInput/number');

textIsInSearch = require('../../../utils').textIsInSearch;

module.exports = component('coursesView', function(arg) {
  var E, courseNumberInput, courses, dom, events, multiselectInstance, nameInput, onEvent, service, setStyle, state, update, view;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  service.getCourses();
  service.getPersons();
  nameInput = E('input', searchBoxStyle.textbox);
  courseNumberInput = E(numberInput, true);
  setStyle(courseNumberInput, searchBoxStyle.textbox);
  view = E(crudPage, {
    entityName: 'درس',
    requiredStates: ['courses', 'professors'],
    extraButtonsBefore: multiselectInstance = E(multiselect, function(callback) {
      return view.setSelectedRows(callback);
    }),
    headers: [
      {
        name: 'نام درس',
        key: 'name',
        searchBox: nameInput
      }, {
        name: 'شماره درس',
        key: 'number',
        searchBox: courseNumberInput
      }
    ],
    onTableUpdate: function(descriptors) {
      return multiselectInstance.setChecked(descriptors);
    },
    credit: E(credit).credit,
    deleteItems: function(courses) {
      return service.deleteCourses(courses.map(function(arg1) {
        var id;
        id = arg1.id;
        return id;
      }));
    }
  });
  courses = [];
  update = function() {
    var filteredCourses, name, number;
    name = nameInput.value();
    number = courseNumberInput.value();
    filteredCourses = courses;
    if (name) {
      filteredCourses = filteredCourses.filter(function(course) {
        return textIsInSearch(course.name, name);
      });
    }
    if (number) {
      filteredCourses = filteredCourses.filter(function(course) {
        return textIsInSearch(course.number, number);
      });
    }
    return view.setData(filteredCourses);
  };
  state.courses.on(function(_courses) {
    courses = _courses;
    return update();
  });
  onEvent([nameInput, courseNumberInput], ['input', 'pInput'], update);
  return view;
});


},{"../../../components/restrictedInput/number":15,"../../../components/table/searchBoxStyle":18,"../../../utils":38,"../../../utils/component":34,"../crudPage":53,"./credit":50,"./multiselect":52}],52:[function(require,module,exports){
var body, component;

component = require('../../../utils/component');

body = require('../../../utils/dom').body;

module.exports = component('offeringsMultiselect', function(arg, setSelectedRows) {
  var E, addClass, button, checkbox, dom, events, group, l0, l1, list, onEvent, removeClass, returnObject, setStyle;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, addClass = dom.addClass, removeClass = dom.removeClass;
  onEvent = events.onEvent;
  group = E({
    "class": 'btn-group',
    marginLeft: 10
  }, button = E({
    "class": 'btn btn-default dropdown-toggle'
  }, E('span', {
    "class": 'caret',
    cursor: 'pointer'
  }), checkbox = E('input', {
    type: 'checkbox',
    marginRight: 10,
    position: 'relative',
    top: 3
  })), list = E('ul', {
    "class": 'dropdown-menu'
  }, l0 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب همه')), l1 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب هیچ'))));
  onEvent(button, 'click', checkbox, function() {
    return addClass(group, 'open');
  });
  onEvent(E(body), 'click', [button, list], function() {
    return removeClass(group, 'open');
  });
  onEvent([l0, l1], 'click', function() {
    return removeClass(group, 'open');
  });
  onEvent(checkbox, 'change', function() {
    return setSelectedRows(function(rows) {
      if (checkbox.checked()) {
        return rows;
      } else {
        return [];
      }
    });
  });
  onEvent(l0, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows;
    });
  });
  onEvent(l1, 'click', function() {
    return setSelectedRows(function(rows) {
      return [];
    });
  });
  returnObject({
    setChecked: function(descriptors) {
      return setStyle(checkbox, {
        checked: descriptors.length && descriptors.every(function(arg1) {
          var selected;
          selected = arg1.selected;
          return selected;
        })
      });
    }
  });
  return group;
});


},{"../../../utils/component":34,"../../../utils/dom":36}],53:[function(require,module,exports){
var Q, component, modal, table;

component = require('../../utils/component');

table = require('../../components/table');

modal = require('../../singletons/modal');

Q = require('../../q');

module.exports = component('crudPage', function(arg, arg1) {
  var E, append, create, credit, deleteButton, deleteButtonVisible, deleteItems, detatch, doCreate, doEdit, dom, entityId, entityName, events, extraButtons, extraButtonsBefore, group, headers, isEqual, loading, noCreating, noData, offDeleteClick, onEvent, onTableUpdate, others, ref, ref1, requiredStates, returnObject, setStyle, tableInstance, view, yesData;
  dom = arg.dom, events = arg.events, others = arg.others, returnObject = arg.returnObject;
  entityName = arg1.entityName, noCreating = arg1.noCreating, headers = arg1.headers, entityId = arg1.entityId, isEqual = arg1.isEqual, onTableUpdate = arg1.onTableUpdate, deleteItems = arg1.deleteItems, credit = arg1.credit, requiredStates = arg1.requiredStates, extraButtons = (ref = arg1.extraButtons) != null ? ref : [], extraButtonsBefore = (ref1 = arg1.extraButtonsBefore) != null ? ref1 : [];
  E = dom.E, append = dom.append, detatch = dom.detatch, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  loading = others.loading;
  doCreate = credit(false);
  doEdit = credit(true);
  deleteButton = E({
    "class": 'btn btn-danger'
  });
  deleteButtonVisible = false;
  offDeleteClick = void 0;
  view = E(null, noData = E(null, 'در حال بارگزاری...'), yesData = [
    E({
      "class": 'row',
      margin: '10px 0'
    }, extraButtonsBefore, group = E({
      "class": 'btn-group'
    }, !noCreating ? create = E({
      "class": 'btn btn-primary'
    }, "ایجاد " + entityName) : void 0), extraButtons, E({
      marginTop: 30
    }, tableInstance = E(table, {
      headers: headers,
      entityId: entityId,
      isEqual: isEqual,
      properties: {
        multiSelect: true
      },
      handlers: {
        select: doEdit,
        update: function(entities) {
          var selectedEntities;
          selectedEntities = entities.filter(function(arg2) {
            var selected;
            selected = arg2.selected;
            return selected;
          });
          if (typeof offClickDelete === "function") {
            offClickDelete();
          }
          if (selectedEntities.length) {
            if (!deleteButtonVisible) {
              append(group, deleteButton);
            }
            deleteButtonVisible = true;
            setStyle(deleteButton, {
              text: "حذف " + selectedEntities.length + " " + entityName + " انتخاب شده"
            });
            if (typeof offDeleteClick === "function") {
              offDeleteClick();
            }
            offDeleteClick = onEvent(deleteButton, 'click', function() {
              return modal.instance.display({
                contents: E('p', null, " آیا از حذف این " + selectedEntities.length + " " + entityName + " اطمینان دارید؟"),
                submitText: 'حذف',
                submitType: 'danger',
                closeText: 'انصراف',
                submit: function() {
                  tableInstance.cover();
                  deleteItems(selectedEntities.map(function(arg2) {
                    var entity;
                    entity = arg2.entity;
                    return entity;
                  })).fin(function() {
                    return tableInstance.uncover();
                  });
                  return modal.instance.hide();
                }
              });
            });
          } else {
            if (deleteButtonVisible) {
              detatch(deleteButton);
            }
            deleteButtonVisible = false;
          }
          return typeof onTableUpdate === "function" ? onTableUpdate(entities) : void 0;
        }
      }
    })))
  ]);
  if (!noCreating) {
    onEvent(create, 'click', doCreate);
  }
  loading(requiredStates, yesData, noData);
  returnObject({
    setData: function(items) {
      return tableInstance.setData(items);
    },
    setSelectedRows: function(callback) {
      return tableInstance.setSelectedRows(callback);
    }
  });
  return view;
});


},{"../../components/table":17,"../../q":28,"../../singletons/modal":33,"../../utils/component":34}],54:[function(require,module,exports){
var component, contentComponents, courses, notTrainedStudents, offerings, paymentStudents, persons, requestForAssistants, staticData, tabNames, tabPermissions,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

component = require('../../utils/component');

staticData = require('./staticData');

persons = require('./persons');

courses = require('./courses');

offerings = require('./offerings');

requestForAssistants = require('./requestForAssistants');

notTrainedStudents = require('./notTrainedStudents');

paymentStudents = require('./paymentStudents');

tabNames = ['اطلاعات پایه', 'اشخاص', 'درس‌ها', 'فراخوان‌ها', 'درخواست‌های دستیاری', 'کارگاه', 'پرداخت'];

contentComponents = [staticData, persons, courses, offerings, requestForAssistants, notTrainedStudents, paymentStudents];

tabPermissions = {};

module.exports = component('adminView', function(arg) {
  var E, addClass, append, changeTabIndex, content, currentTabIndex, destroy, dom, events, goToRequestForAssistants, hide, offeringIds, onEvent, removeClass, show, state, tabs, view;
  dom = arg.dom, events = arg.events, state = arg.state;
  E = dom.E, addClass = dom.addClass, removeClass = dom.removeClass, append = dom.append, destroy = dom.destroy, show = dom.show, hide = dom.hide;
  onEvent = events.onEvent;
  currentTabIndex = 0;
  content = void 0;
  offeringIds = null;
  goToRequestForAssistants = function(_offeringIds) {
    offeringIds = _offeringIds;
    return changeTabIndex(4);
  };
  changeTabIndex = function(index) {
    removeClass(tabs[currentTabIndex], 'active');
    currentTabIndex = index;
    addClass(tabs[currentTabIndex], 'active');
    if (content) {
      destroy(content);
    }
    content = E(contentComponents[currentTabIndex], {
      goToRequestForAssistants: goToRequestForAssistants,
      offeringIds: offeringIds
    });
    return append(view, content);
  };
  view = E(null, E('ul', {
    "class": 'nav nav-tabs',
    marginBottom: 20
  }, tabs = tabNames.map(function(tabName, index) {
    var tab;
    tab = E('li', null, E('a', {
      cursor: 'pointer'
    }, tabName));
    onEvent(tab, 'click', function() {
      offeringIds = null;
      return changeTabIndex(index);
    });
    return tab;
  })));
  changeTabIndex(0);
  state.person.on(function(person) {
    return tabs.forEach(function(tab, index) {
      var permissions;
      permissions = tabPermissions[index];
      if (!permissions || indexOf.call(person.flattenedPermissions, permissions) >= 0) {
        return show(tab);
      } else {
        hide(tab);
        if (currentTabIndex === index) {
          return destroy(content);
        }
      }
    });
  });
  return view;
});


},{"../../utils/component":34,"./courses":51,"./notTrainedStudents":55,"./offerings":57,"./paymentStudents":60,"./persons":62,"./requestForAssistants":66,"./staticData":69}],55:[function(require,module,exports){
var component, crudPage, numberInput, searchBoxStyle, textIsInSearch;

component = require('../../utils/component');

crudPage = require('./crudPage');

searchBoxStyle = require('../../components/table/searchBoxStyle');

numberInput = require('../../components/restrictedInput/number');

textIsInSearch = require('../../utils').textIsInSearch;

module.exports = component('notTrainesdStudents', function(arg) {
  var E, dom, events, fullNameInput, golestanNumberInput, noData, onEvent, service, setStyle, state, students, tableInstance, update, view, yesData;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  service.getPersons();
  service.getOfferings();
  service.getCurrentTerm();
  service.getRequestForAssistants();
  fullNameInput = E('input', searchBoxStyle.textbox);
  golestanNumberInput = E(numberInput, true);
  setStyle(golestanNumberInput, searchBoxStyle.textbox);
  view = E(null, noData = E(null, 'در حال بارگزاری...'), yesData = [
    E({
      "class": 'row',
      margin: '10px 0'
    }, E({
      marginTop: 30
    }, E({
      "class": 'btn btn-success'
    }, 'دریافت فایل اکسل'), tableInstance = E(table, {
      headers: [
        {
          name: 'نام کامل',
          key: 'fullName',
          searchBox: fullNameInput
        }, {
          name: 'شماره دانشجویی',
          key: 'golestanNumber',
          searchBox: golestanNumberInput
        }, {
          name: 'مقطع',
          key: 'degree'
        }
      ]
    })))
  ]);
  students = [];
  update = function() {
    var filteredStudents, fullName, golestanNumber;
    fullName = fullNameInput.value();
    golestanNumber = golestanNumberInput.value();
    filteredStudents = students;
    if (fullName) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.fullName, fullName);
      });
    }
    if (golestanNumber) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.golestanNumber, golestanNumber);
      });
    }
    return tableInstance.setData(filteredStudents);
  };
  state.all(['persons', 'offerings', 'currentTerm', 'requestForAssistants'], function(arg1) {
    var currentTerm, offerings, persons, requestForAssistants;
    persons = arg1[0], offerings = arg1[1], currentTerm = arg1[2], requestForAssistants = arg1[3];
    students = persons.filter(function(student) {
      return requestForAssistants.some(function(requestForAssistant) {
        if (String(requestForAssistant.studentId) === String(student.id) && requestForAssistant.status === 2 && requestForAssistant.isTrained === false) {
          return offerings.some(function(arg2) {
            var id, termId;
            id = arg2.id, termId = arg2.termId;
            return String(id) === String(requestForAssistant.id) && termId === currentTerm;
          });
        }
      });
    });
    return update();
  });
  onEvent([fullNameInput, golestanNumberInput], ['input', 'pInput'], update);
  return view;
});


},{"../../components/restrictedInput/number":15,"../../components/table/searchBoxStyle":18,"../../utils":38,"../../utils/component":34,"./crudPage":53}],56:[function(require,module,exports){
var component, extend, generateId, modal, numberInput, ref, stateSyncedDropdown, toEnglish;

component = require('../../../utils/component');

modal = require('../../../singletons/modal');

stateSyncedDropdown = require('../../../components/dropdown/stateSynced');

numberInput = require('../../../components/restrictedInput/number');

generateId = require('../../../utils/dom').generateId;

ref = require('../../../utils'), extend = ref.extend, toEnglish = ref.toEnglish;

module.exports = component('offeringsCredit', function(arg) {
  var E, allInputs, capacity, contents, course, deputy, disable, dom, enable, events, getId, getServiceData, ids, offState, onEnter, onEvent, professor, returnObject, service, setStyle, state, term;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, enable = dom.enable, disable = dom.disable;
  onEvent = events.onEvent, onEnter = events.onEnter;
  ids = [0, 1, 2, 3, 4].map(generateId);
  getId = function(arg1) {
    var id;
    id = arg1.id;
    return id;
  };
  course = E(stateSyncedDropdown, {
    stateName: 'courses',
    getId: getId,
    getTitle: function(arg1) {
      var name;
      name = arg1.name;
      return name;
    }
  });
  setStyle(course.input, {
    id: ids[0]
  });
  professor = E(stateSyncedDropdown, {
    stateName: 'professors',
    getId: getId,
    getTitle: function(arg1) {
      var fullName;
      fullName = arg1.fullName;
      return fullName;
    }
  });
  setStyle(professor.input, {
    id: ids[1]
  });
  term = E(stateSyncedDropdown, {
    stateName: 'terms',
    selectedIdStateName: 'currentTerm'
  });
  setStyle(term.input, {
    id: ids[2]
  });
  capacity = E(numberInput, true);
  setStyle(capacity, {
    id: ids[3],
    "class": 'form-control'
  });
  deputy = E(stateSyncedDropdown, {
    stateName: 'deputies',
    getId: getId,
    getTitle: function(arg1) {
      var fullName;
      fullName = arg1.fullName;
      return fullName;
    }
  });
  setStyle(deputy.input, {
    id: ids[4]
  });
  deputy.showEmpty(true);
  contents = [
    E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[0]
    }, 'نام درس'), course), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[1]
    }, 'نام استاد'), professor), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[2]
    }, 'ترم'), term), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[3]
    }, 'ظرفیت'), capacity), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[4]
    }, 'نام نماینده استاد (اختیاری)'), deputy)
  ];
  allInputs = [course.input, professor.input, term.input, capacity, deputy.input];
  onEvent([course.input, professor.input, term.input], ['input', 'pInput'], function() {
    return modal.instance.setEnabled(~course.value() && ~professor.value() && ~term.value());
  });
  onEnter(allInputs, function() {
    return modal.instance.submit();
  });
  onEvent(capacity, ['focus', 'input'], function() {
    return capacity.dirty = true;
  });
  getServiceData = function() {
    return {
      courseId: course.value().id,
      professorId: professor.value().id,
      termId: term.value(),
      deputyId: ~deputy.value() ? deputy.value().id : null,
      capacity: capacity.value() ? toEnglish(capacity.value()) : null
    };
  };
  offState = void 0;
  return returnObject({
    credit: function(isEdit) {
      return function(offering) {
        term.revalue();
        capacity.dirty = false;
        if (isEdit) {
          [course, professor].forEach(function(x) {
            return x.showEmpty(false);
          });
          [course, professor, deputy].forEach(function(x) {
            return x.undirty();
          });
          offState = state.offerings.on(function(offerings) {
            offering = (offerings.filter(function(arg1) {
              var id;
              id = arg1.id;
              return id === offering.id;
            }))[0];
            if (!offering) {
              return modal.instance.hide();
            }
            course.setSelectedId(offering.courseId);
            professor.setSelectedId(offering.professorId);
            deputy.setSelectedId(offering.deputyId);
            if (!capacity.dirty) {
              return setStyle(capacity, {
                value: offering.capacity
              });
            }
          });
        } else {
          [course, professor].forEach(function(x) {
            return x.showEmpty(true);
          });
          [course, professor, deputy].forEach(function(x) {
            return x.reset();
          });
          setStyle(capacity, {
            value: ''
          });
        }
        return modal.instance.display({
          enabled: isEdit,
          autoHide: true,
          title: (isEdit ? 'جزئیات/ویرایش' : 'ایجاد') + ' فراخوان',
          submitText: isEdit ? 'ثبت تغییرات' : 'ایجاد',
          closeText: isEdit ? 'لغو تغییرات' : 'لغو',
          contents: contents,
          close: function() {
            if (typeof offState === "function") {
              offState();
            }
            return offState = null;
          },
          submit: function() {
            var submitQ;
            allInputs.forEach(function(x) {
              return disable(x);
            });
            submitQ = isEdit ? service.updateOffering(extend({
              id: offering.id
            }, getServiceData())) : service.createOffering(getServiceData());
            return submitQ.then(function() {
              return allInputs.forEach(function(x) {
                return enable(x);
              });
            })["catch"](function() {
              return allInputs.forEach(function(x) {
                return enable(x);
              });
            });
          }
        });
      };
    }
  });
});


},{"../../../components/dropdown/stateSynced":9,"../../../components/restrictedInput/number":15,"../../../singletons/modal":33,"../../../utils":38,"../../../utils/component":34,"../../../utils/dom":36}],57:[function(require,module,exports){
var component, credit, crudPage, dropdown, extend, multiselect, ref, searchBoxStyle, stateSyncedDropdown, textIsInSearch, viewRequestForAssistants;

component = require('../../../utils/component');

crudPage = require('../crudPage');

credit = require('./credit');

multiselect = require('./multiselect');

viewRequestForAssistants = require('./viewRequestForAssistants');

searchBoxStyle = require('../../../components/table/searchBoxStyle');

dropdown = require('../../../components/dropdown');

stateSyncedDropdown = require('../../../components/dropdown/stateSynced');

ref = require('../../../utils'), extend = ref.extend, textIsInSearch = ref.textIsInSearch;

module.exports = component('offeringsView', function(arg, arg1) {
  var E, courseNameInput, dom, events, goToRequestForAssistants, isClosedDropdown, multiselectInstance, offerings, onEvent, professorNameInput, service, setStyle, state, termDropdown, update, view, viewRequestForAssistantsInstance;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  goToRequestForAssistants = arg1.goToRequestForAssistants;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  service.getOfferings();
  service.getCourses();
  service.getPersons();
  service.getTerms();
  service.getCurrentTerm();
  service.getRequestForAssistants();
  termDropdown = E(stateSyncedDropdown, {
    stateName: 'terms',
    selectedIdStateName: 'currentTerm'
  });
  setStyle(termDropdown, searchBoxStyle.font);
  setStyle(termDropdown.input, searchBoxStyle.input);
  termDropdown.showEmpty(true);
  isClosedDropdown = E(dropdown, {
    getTitle: function(x) {
      switch (x) {
        case 0:
          return 'نهایی نشده';
        case 1:
          return 'نهایی شده';
      }
    }
  });
  setStyle(isClosedDropdown, searchBoxStyle.font);
  setStyle(isClosedDropdown.input, searchBoxStyle.input);
  isClosedDropdown.showEmpty(true);
  isClosedDropdown.update([0, 1]);
  courseNameInput = E('input', searchBoxStyle.textbox);
  professorNameInput = E('input', searchBoxStyle.textbox);
  view = E(crudPage, {
    entityName: 'فراخوان',
    requiredStates: ['offerings', 'courses', 'professors', 'terms', 'currentTerm', 'requestForAssistants'],
    extraButtonsBefore: multiselectInstance = E(multiselect, function(callback) {
      return view.setSelectedRows(callback);
    }),
    extraButtons: viewRequestForAssistantsInstance = E(viewRequestForAssistants, goToRequestForAssistants),
    headers: [
      {
        name: 'نام درس',
        key: 'courseName',
        searchBox: courseNameInput
      }, {
        name: 'نام استاد',
        key: 'professorName',
        searchBox: professorNameInput
      }, {
        name: 'ترم',
        key: 'termId',
        searchBox: termDropdown
      }, {
        name: 'وضعیت',
        searchBox: isClosedDropdown,
        getValue: function(offering) {
          if (offering.isClosed) {
            return 'نهایی شده';
          } else {
            return 'نهایی نشده';
          }
        },
        styleTd: function(offering, td) {
          if (offering.isClosed) {
            return setStyle(td, {
              color: 'green'
            });
          } else {
            return setStyle(td, {
              color: 'red'
            });
          }
        }
      }, {
        name: 'ظرفیت',
        key: 'capacity'
      }, {
        name: 'تعداد درخواست',
        notClickable: true,
        getValue: function(offering) {
          if (offering.requestForAssistantsCount) {
            return "مشاهده " + offering.requestForAssistantsCount + " درخواست";
          } else {
            return 'بدون درخواست';
          }
        },
        styleTd: function(offering, td, offs) {
          if (offering.requestForAssistantsCount) {
            setStyle(td, {
              color: 'blue',
              text: "مشاهده " + offering.requestForAssistantsCount + " درخواست"
            });
            return offs.push(onEvent(td, 'click', function() {
              return goToRequestForAssistants([offering.id]);
            }));
          } else {
            return setStyle(td, {
              color: 'gray',
              text: 'بدون درخواست'
            });
          }
        }
      }
    ],
    onTableUpdate: function(descriptors) {
      multiselectInstance.setChecked(descriptors);
      return viewRequestForAssistantsInstance.update(descriptors);
    },
    credit: E(credit).credit,
    deleteItems: function(offerings) {
      return service.deleteOfferings(offerings.map(function(arg2) {
        var id;
        id = arg2.id;
        return id;
      }));
    }
  });
  offerings = [];
  update = function() {
    var courseName, filteredOfferings, isClosed, professorName, term;
    courseName = courseNameInput.value();
    professorName = professorNameInput.value();
    term = termDropdown.value();
    isClosed = isClosedDropdown.value();
    filteredOfferings = offerings;
    if (courseName) {
      filteredOfferings = filteredOfferings.filter(function(offering) {
        return textIsInSearch(offering.courseName, courseName);
      });
    }
    if (professorName) {
      filteredOfferings = filteredOfferings.filter(function(offering) {
        return textIsInSearch(offering.professorName, professorName);
      });
    }
    if (~term) {
      filteredOfferings = filteredOfferings.filter(function(offering) {
        return textIsInSearch(offering.termId, term);
      });
    }
    if (~isClosed) {
      filteredOfferings = filteredOfferings.filter(function(offering) {
        return offering.isClosed === !!isClosed;
      });
    }
    return view.setData(filteredOfferings);
  };
  state.all(['offerings', 'courses', 'professors', 'requestForAssistants'], function(arg2) {
    var _offerings, courses, professors, requestForAssistants;
    _offerings = arg2[0], courses = arg2[1], professors = arg2[2], requestForAssistants = arg2[3];
    offerings = _offerings.map(function(offering) {
      var ref1, ref2, ref3, ref4;
      return extend({}, offering, {
        courseName: (ref1 = (ref2 = (courses.filter(function(arg3) {
          var id;
          id = arg3.id;
          return String(id) === String(offering.courseId);
        }))[0]) != null ? ref2.name : void 0) != null ? ref1 : '',
        professorName: (ref3 = (ref4 = (professors.filter(function(arg3) {
          var id;
          id = arg3.id;
          return String(id) === String(offering.professorId);
        }))[0]) != null ? ref4.fullName : void 0) != null ? ref3 : '',
        requestForAssistantsCount: (requestForAssistants.filter(function(arg3) {
          var offeringId;
          offeringId = arg3.offeringId;
          return String(offeringId) === String(offering.id);
        })).length
      });
    });
    return update();
  });
  onEvent([courseNameInput, professorNameInput, termDropdown.input, isClosedDropdown.input], ['input', 'pInput'], update);
  return view;
});


},{"../../../components/dropdown":6,"../../../components/dropdown/stateSynced":9,"../../../components/table/searchBoxStyle":18,"../../../utils":38,"../../../utils/component":34,"../crudPage":53,"./credit":56,"./multiselect":58,"./viewRequestForAssistants":59}],58:[function(require,module,exports){
var body, component;

component = require('../../../utils/component');

body = require('../../../utils/dom').body;

module.exports = component('offeringsMultiselect', function(arg, setSelectedRows) {
  var E, addClass, button, checkbox, dom, events, group, l0, l1, l2, l3, list, onEvent, removeClass, returnObject, setStyle;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, addClass = dom.addClass, removeClass = dom.removeClass;
  onEvent = events.onEvent;
  group = E({
    "class": 'btn-group',
    marginLeft: 10
  }, button = E({
    "class": 'btn btn-default dropdown-toggle'
  }, E('span', {
    "class": 'caret',
    cursor: 'pointer'
  }), checkbox = E('input', {
    type: 'checkbox',
    marginRight: 10,
    position: 'relative',
    top: 3
  })), list = E('ul', {
    "class": 'dropdown-menu'
  }, l0 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب همه')), l1 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب هیچ')), E('li', {
    "class": 'divider'
  }), l2 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب فراخوان‌های نهایی شده')), l3 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب فراخوان‌های نهایی نشده'))));
  onEvent(button, 'click', checkbox, function() {
    return addClass(group, 'open');
  });
  onEvent(E(body), 'click', [button, list], function() {
    return removeClass(group, 'open');
  });
  onEvent([l0, l1, l2, l3], 'click', function() {
    return removeClass(group, 'open');
  });
  onEvent(checkbox, 'change', function() {
    return setSelectedRows(function(rows) {
      if (checkbox.checked()) {
        return rows;
      } else {
        return [];
      }
    });
  });
  onEvent(l0, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows;
    });
  });
  onEvent(l1, 'click', function() {
    return setSelectedRows(function(rows) {
      return [];
    });
  });
  onEvent(l2, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.isClosed;
      });
    });
  });
  onEvent(l3, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return !entity.isClosed;
      });
    });
  });
  returnObject({
    setChecked: function(descriptors) {
      return setStyle(checkbox, {
        checked: descriptors.length && descriptors.every(function(arg1) {
          var selected;
          selected = arg1.selected;
          return selected;
        })
      });
    }
  });
  return group;
});


},{"../../../utils/component":34,"../../../utils/dom":36}],59:[function(require,module,exports){
var component;

component = require('../../../utils/component');

module.exports = component('offeringsViewRequestForAssistants', function(arg, goToRequestForAssistants) {
  var E, dom, events, hide, offClick, onEvent, returnObject, setStyle, show, view;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, show = dom.show, hide = dom.hide, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  hide(view = E({
    "class": 'btn btn-default',
    marginRight: 10
  }));
  offClick = void 0;
  returnObject({
    update: function(descriptors) {
      var selectedEntities;
      selectedEntities = descriptors.filter(function(arg1) {
        var selected;
        selected = arg1.selected;
        return selected;
      });
      if (typeof offClick === "function") {
        offClick();
      }
      if (selectedEntities.length) {
        show(view);
        setStyle(view, {
          text: "مشاهده درخواست‌های " + selectedEntities.length + " فراخوان انتخاب شده"
        });
        return offClick = onEvent(view, 'click', function() {
          return goToRequestForAssistants(selectedEntities.map(function(arg1) {
            var entity;
            entity = arg1.entity;
            return entity.id;
          }));
        });
      } else {
        return hide(view);
      }
    }
  });
  return view;
});


},{"../../../utils/component":34}],60:[function(require,module,exports){
var component, crudPage, extend, numberInput, ref, searchBoxStyle, textIsInSearch;

component = require('../../utils/component');

crudPage = require('./crudPage');

searchBoxStyle = require('../../components/table/searchBoxStyle');

numberInput = require('../../components/restrictedInput/number');

ref = require('../../utils'), extend = ref.extend, textIsInSearch = ref.textIsInSearch;

module.exports = component('notTrainesdStudents', function(arg) {
  var E, courseNameInput, courseNumberInput, dom, events, fullNameInput, golestanNumberInput, headers, noData, onEvent, professorFullNameInput, professorGolestanNumberInput, service, setStyle, state, students, tableInstance, update, view, yesData;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  service.getPersons();
  service.getOfferings();
  service.getCourses();
  service.getCurrentTerm();
  service.getRequestForAssistants();
  fullNameInput = E('input', searchBoxStyle.textbox);
  golestanNumberInput = E(numberInput, true);
  setStyle(golestanNumberInput, searchBoxStyle.textbox);
  courseNameInput = E('input', searchBoxStyle.textbox);
  courseNumberInput = E(numberInput, true);
  setStyle(courseNumberInput, searchBoxStyle.textbox);
  professorFullNameInput = E('input', searchBoxStyle.textbox);
  professorGolestanNumberInput = E(numberInput, true);
  setStyle(professorGolestanNumberInput, searchBoxStyle.textbox);
  view = E(null, noData = E(null, 'در حال بارگزاری...'), yesData = [
    E({
      "class": 'row',
      margin: '10px 0'
    }, E({
      marginTop: 30
    }, E({
      "class": 'btn btn-success'
    }, 'دریافت فایل اکسل'), tableInstance = E(table, headers = {
      headers: [
        {
          name: 'نام کامل',
          key: 'fullName',
          searchBox: fullNameInput
        }, {
          name: 'شماره دانشجویی',
          key: 'golestanNumber',
          searchBox: golestanNumberInput
        }, {
          name: 'نام درس',
          key: 'courseName',
          searchBox: courseNameInput
        }, {
          name: 'شماره درس',
          key: 'courseName',
          searchBox: courseNumberInput
        }, {
          name: 'نام کامل استاد',
          key: 'professorFullName',
          searchBox: professorFullNameInput
        }, {
          name: 'شماره پرسنلی استاد',
          key: 'professorGolestanNumber',
          searchBox: professorGolestanNumberInput
        }, {
          name: 'مقطع',
          key: 'degree'
        }, {
          name: 'دستیار اصلی است',
          key: 'isChiefTa'
        }
      ]
    }, {
      sort: {
        header: headers[2],
        direction: 'up'
      }
    })))
  ]);
  students = [];
  update = function() {
    var courseName, courseNumber, filteredStudents, fullName, golestanNumber, professorFullName, professorGolestanNumber;
    fullName = fullNameInput.value();
    golestanNumber = golestanNumberInput.value();
    courseName = courseNameInput.value();
    courseNumber = courseNumberInput.value();
    professorFullName = professorFullNameInput.value();
    professorGolestanNumber = professorGolestanNumberInput.value();
    filteredStudents = students;
    if (fullName) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.fullName, fullName);
      });
    }
    if (golestanNumber) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.golestanNumber, golestanNumber);
      });
    }
    if (courseName) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.courseName, courseName);
      });
    }
    if (courseNumber) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.courseNumber, courseNumber);
      });
    }
    if (professorFullName) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.professorFullName, professorFullName);
      });
    }
    if (professorGolestanNumber) {
      filteredStudents = filteredStudents.filter(function(person) {
        return textIsInSearch(person.professorGolestanNumber, professorGolestanNumber);
      });
    }
    return tablein.setData(filteredStudents);
  };
  state.all(['persons', 'professors', 'offerings', 'currentTerm', 'courses', 'requestForAssistants'], function(arg1) {
    var courses, currentTerm, offerings, persons, professors, requestForAssistants;
    persons = arg1[0], professors = arg1[1], offerings = arg1[2], currentTerm = arg1[3], courses = arg1[4], requestForAssistants = arg1[5];
  }, students = persons.filter(function(student) {
    return requestForAssistants.some(function(requestForAssistant) {
      if (String(requestForAssistant.studentId) === String(student.id) && requestForAssistant.status === 2) {
        return offerings.some(function(offering) {
          var course, professor;
          if (String(offering.id) === String(requestForAssistant.id) && offering.termId === currentTerm) {
            course = courses.filter(function(arg1) {
              var id;
              id = arg1.id;
              return String(id) === String(offering.courseId);
            })[0];
            professor = professors.filter(function(arg1) {
              var id;
              id = arg1.id;
              return String(id) === String(offering.professorId);
            })[0];
            extend(student, {
              courseName: course.name,
              courseNumber: course.number,
              professorFullName: professor.fullName,
              professorGolestanNumber: professor.golestanNumber,
              isChiefTa: requestForAssistant.isChiefTa
            });
            return true;
          }
        });
      }
    });
  }), update());
  onEvent([fullNameInput, golestanNumberInput], ['input', 'pInput'], update);
  return view;
});


},{"../../components/restrictedInput/number":15,"../../components/table/searchBoxStyle":18,"../../utils":38,"../../utils/component":34,"./crudPage":53}],61:[function(require,module,exports){
var component, dropdown, extend, generateId, modal, numberInput, ref, toEnglish;

component = require('../../../utils/component');

modal = require('../../../singletons/modal');

dropdown = require('../../../components/dropdown');

numberInput = require('../../../components/restrictedInput/number');

generateId = require('../../../utils/dom').generateId;

ref = require('../../../utils'), extend = ref.extend, toEnglish = ref.toEnglish;

module.exports = component('personsCredit', function(arg) {
  var E, allInputs, button, buttonGroup, canLoginWithEmail, contents, degree, degreeGroup, disable, dom, email, enable, events, fullName, getServiceData, golestanNumber, hide, ids, offClick, offState, onEnter, onEvent, returnObject, service, setStyle, show, state, text, type, typeGroup;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, text = dom.text, setStyle = dom.setStyle, show = dom.show, hide = dom.hide, enable = dom.enable, disable = dom.disable;
  onEvent = events.onEvent, onEnter = events.onEnter;
  ids = [0, 1, 2, 3, 4].map(function() {
    return generateId();
  });
  type = E(dropdown);
  setStyle(type.input, {
    id: ids[0]
  });
  type.showEmpty(true);
  type.update(['کارشناس آموزش', 'استاد', 'دانشجو', 'نماینده استاد']);
  fullName = E('input', {
    id: ids[1],
    "class": 'form-control'
  });
  golestanNumber = E(numberInput, true);
  setStyle(golestanNumber, {
    id: ids[2],
    "class": 'form-control'
  });
  email = E('input', {
    id: ids[3],
    type: 'email',
    "class": 'form-control'
  });
  canLoginWithEmail = E('input', {
    type: 'checkbox'
  });
  degree = E(dropdown);
  setStyle(degree.input, {
    id: ids[4]
  });
  degree.update(['کارشناسی', 'کارشناسی ارشد', 'دکتری']);
  contents = [
    typeGroup = E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[0]
    }, 'نوع'), type), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[1]
    }, 'نام کامل'), fullName), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[2]
    }, 'شماره دانشجویی / پرسنلی'), golestanNumber), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[3]
    }, 'ایمیل'), email), E({
      "class": 'checkbox'
    }, E('label', null, canLoginWithEmail, text('امکان ورود با ایمیل'))), buttonGroup = E({
      "class": 'form-group'
    }, button = E({
      "class": 'btn btn-default'
    })), degreeGroup = E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[4]
    }, 'مقطع'), degree)
  ];
  allInputs = [type.input, fullName, email, canLoginWithEmail, degree.input];
  onEvent(allInputs, ['input, pInput', 'change'], function() {
    return modal.instance.setEnabled(~type.value() && fullName.value() && (type.value() !== 'دانشجو' || ~degree.value()));
  });
  onEnter(allInputs, function() {
    return modal.instance.submit();
  });
  allInputs.forEach(function(input) {
    return onEvent(input, ['focus', 'input', 'change'], function() {
      return input.dirty = true;
    });
  });
  onEvent(type.input, ['input', 'pInput'], function() {
    if (type.value() === 'دانشجو') {
      return show(degreeGroup);
    } else {
      return hide(degreeGroup);
    }
  });
  getServiceData = function() {
    var person;
    person = {
      fullName: fullName.value(),
      email: email.value(),
      canLoginWithEmail: canLoginWithEmail.checked(),
      golestanNumber: golestanNumber.value() ? toEnglish(golestanNumber.value()) : null
    };
    switch (type.value()) {
      case 'دانشجو':
        extend(person, {
          degree: ~degree.value() ? degree.value() : null
        });
    }
    return person;
  };
  offState = offClick = void 0;
  return returnObject({
    credit: function(isEdit) {
      return function(person) {
        if (typeof offClick === "function") {
          offClick();
        }
        allInputs.forEach(function(input) {
          return input.dirty = false;
        });
        hide(degreeGroup);
        if (isEdit) {
          hide(typeGroup);
          type.setSelectedId(person.type);
          offState = state.persons.on(function(persons) {
            person = (persons.filter(function(arg1) {
              var id;
              id = arg1.id;
              return id === person.id;
            }))[0];
            if (!person) {
              return modal.instance.hide();
            }
            if (person.canLoginWithEmail) {
              show(buttonGroup);
              if (person.hasPassword) {
                setStyle(button, {
                  text: 'ریست کردن رمز عبور'
                });
              } else {
                setStyle(button, {
                  text: 'ارسال مجدد ایمیل ثبت‌نام'
                });
              }
              offClick = onEvent(button, 'click', function() {
                disable(button);
                return service.resetPassword({
                  personId: person.id
                }).fin(function() {
                  return enable(button);
                });
              });
            } else {
              hide(buttonGroup);
            }
            degree.setSelectedId(person.degree);
            if (!fullName.dirty) {
              setStyle(fullName, {
                value: person.fullName
              });
            }
            if (!golestanNumber.dirty) {
              setStyle(golestanNumber, {
                value: person.golestanNumber
              });
            }
            if (!email.dirty) {
              setStyle(email, {
                englishValue: person.email
              });
            }
            if (!canLoginWithEmail.dirty) {
              return setStyle(canLoginWithEmail, {
                checked: person.canLoginWithEmail
              });
            }
          });
        } else {
          show(typeGroup);
          type.reset();
          hide(buttonGroup);
          setStyle(fullName, {
            value: ''
          });
          setStyle(golestanNumber, {
            value: ''
          });
          setStyle(email, {
            value: ''
          });
          setStyle(canLoginWithEmail, {
            value: ''
          });
        }
        return modal.instance.display({
          enabled: isEdit,
          autoHide: true,
          title: (isEdit ? 'جزئیات/ویرایش' : 'ایجاد') + ' ضخص',
          submitText: isEdit ? 'ثبت تغییرات' : 'ایجاد',
          closeText: isEdit ? 'لغو تغییرات' : 'لغو',
          contents: contents,
          close: function() {
            if (typeof offState === "function") {
              offState();
            }
            return offState = null;
          },
          submit: function() {
            var submitQ;
            allInputs.forEach(function(x) {
              return disable(x);
            });
            submitQ = isEdit ? service.updatePerson(extend({
              id: person.id
            }, getServiceData())) : service.createPerson(getServiceData());
            return submitQ.then(function() {
              return allInputs.forEach(function(x) {
                return enable(x);
              });
            })["catch"](function() {
              return allInputs.forEach(function(x) {
                return enable(x);
              });
            });
          }
        });
      };
    }
  });
});


},{"../../../components/dropdown":6,"../../../components/restrictedInput/number":15,"../../../singletons/modal":33,"../../../utils":38,"../../../utils/component":34,"../../../utils/dom":36}],62:[function(require,module,exports){
var component, credit, crudPage, dropdown, multiselect, numberInput, searchBoxStyle, textIsInSearch;

component = require('../../../utils/component');

crudPage = require('../crudPage');

credit = require('./credit');

multiselect = require('./multiselect');

searchBoxStyle = require('../../../components/table/searchBoxStyle');

dropdown = require('../../../components/dropdown');

numberInput = require('../../../components/restrictedInput/number');

textIsInSearch = require('../../../utils').textIsInSearch;

module.exports = component('personsView', function(arg) {
  var E, dom, events, fullNameInput, golestanNumberInput, multiselectInstance, onEvent, persons, service, setStyle, state, typeDropdown, update, view;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  service.getPersons();
  fullNameInput = E('input', searchBoxStyle.textbox);
  typeDropdown = E(dropdown);
  setStyle(typeDropdown, searchBoxStyle.font);
  setStyle(typeDropdown.input, searchBoxStyle.input);
  typeDropdown.showEmpty(true);
  typeDropdown.update(['کارشناس آموزش', 'استاد', 'دانشجو', 'نماینده استاد']);
  golestanNumberInput = E(numberInput, true);
  setStyle(golestanNumberInput, searchBoxStyle.textbox);
  view = E(crudPage, {
    entityName: 'شخص',
    requiredStates: ['persons'],
    extraButtonsBefore: multiselectInstance = E(multiselect, function(callback) {
      return view.setSelectedRows(callback);
    }),
    headers: [
      {
        name: 'نوع',
        key: 'type',
        searchBox: typeDropdown
      }, {
        name: 'نام کامل',
        key: 'fullName',
        searchBox: fullNameInput
      }, {
        name: 'شماره دانشجویی / پرسنلی',
        key: 'golestanNumber',
        searchBox: golestanNumberInput
      }
    ],
    onTableUpdate: function(descriptors) {
      return multiselectInstance.setChecked(descriptors);
    },
    credit: E(credit).credit,
    deleteItems: function(persons) {
      return service.deletePersons(persons.map(function(arg1) {
        var id;
        id = arg1.id;
        return id;
      }));
    }
  });
  persons = [];
  update = function() {
    var filteredPersons, fullName, golestanNumber, type;
    type = typeDropdown.value();
    fullName = fullNameInput.value();
    golestanNumber = golestanNumberInput.value();
    filteredPersons = persons;
    if (~type) {
      filteredPersons = filteredPersons.filter(function(person) {
        return textIsInSearch(person.type, type);
      });
    }
    if (fullName) {
      filteredPersons = filteredPersons.filter(function(person) {
        return textIsInSearch(person.fullName, fullName);
      });
    }
    if (golestanNumber) {
      filteredPersons = filteredPersons.filter(function(person) {
        return textIsInSearch(person.golestanNumber, golestanNumber);
      });
    }
    return view.setData(filteredPersons);
  };
  state.persons.on(function(_persons) {
    persons = _persons;
    return update();
  });
  onEvent([typeDropdown.input, fullNameInput, golestanNumberInput], ['input', 'pInput'], update);
  return view;
});


},{"../../../components/dropdown":6,"../../../components/restrictedInput/number":15,"../../../components/table/searchBoxStyle":18,"../../../utils":38,"../../../utils/component":34,"../crudPage":53,"./credit":61,"./multiselect":63}],63:[function(require,module,exports){
var body, component;

component = require('../../../utils/component');

body = require('../../../utils/dom').body;

module.exports = component('offeringsMultiselect', function(arg, setSelectedRows) {
  var E, addClass, button, checkbox, dom, events, group, l0, l1, l2, l3, l4, l5, list, onEvent, removeClass, returnObject, setStyle;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, addClass = dom.addClass, removeClass = dom.removeClass;
  onEvent = events.onEvent;
  group = E({
    "class": 'btn-group',
    marginLeft: 10
  }, button = E({
    "class": 'btn btn-default dropdown-toggle'
  }, E('span', {
    "class": 'caret',
    cursor: 'pointer'
  }), checkbox = E('input', {
    type: 'checkbox',
    marginRight: 10,
    position: 'relative',
    top: 3
  })), list = E('ul', {
    "class": 'dropdown-menu'
  }, l0 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب همه')), l1 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب هیچ')), E('li', {
    "class": 'divider'
  }), l2 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب کارشناسان آموزش')), l3 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب اساتید')), l4 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب دانشجویان')), l5 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب نمایندگان استاد'))));
  onEvent(button, 'click', checkbox, function() {
    return addClass(group, 'open');
  });
  onEvent(E(body), 'click', [button, list], function() {
    return removeClass(group, 'open');
  });
  onEvent([l0, l1, l2, l3, l4, l5], 'click', function() {
    return removeClass(group, 'open');
  });
  onEvent(checkbox, 'change', function() {
    return setSelectedRows(function(rows) {
      if (checkbox.checked()) {
        return rows;
      } else {
        return [];
      }
    });
  });
  onEvent(l0, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows;
    });
  });
  onEvent(l1, 'click', function() {
    return setSelectedRows(function(rows) {
      return [];
    });
  });
  onEvent(l2, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.type === 'کارشناس آموزش';
      });
    });
  });
  onEvent(l3, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.type === 'استاد';
      });
    });
  });
  onEvent(l4, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.type === 'دانشجو';
      });
    });
  });
  onEvent(l5, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.type === 'نماینده استاد';
      });
    });
  });
  returnObject({
    setChecked: function(descriptors) {
      return setStyle(checkbox, {
        checked: descriptors.length && descriptors.every(function(arg1) {
          var selected;
          selected = arg1.selected;
          return selected;
        })
      });
    }
  });
  return group;
});


},{"../../../utils/component":34,"../../../utils/dom":36}],64:[function(require,module,exports){
var component, extend, generateId, gradeInput, modal, ref, toEnglish;

component = require('../../../utils/component');

modal = require('../../../singletons/modal');

gradeInput = require('../../../components/restrictedInput/grade');

generateId = require('../../../utils/dom').generateId;

ref = require('../../../utils'), extend = ref.extend, toEnglish = ref.toEnglish;

module.exports = component('requestForAssistantsCredit', function(arg) {
  var E, allInputs, append, contents, dom, empty, events, gpa, grades, gradesContainer, ids, isTrained, message, offState, onEnter, onEvent, returnObject, service, setEnabled, setStyle, state, text;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, text = dom.text, setStyle = dom.setStyle, append = dom.append, empty = dom.empty;
  onEvent = events.onEvent, onEnter = events.onEnter;
  ids = [0, 1];
  grades = [];
  gpa = E(gradeInput);
  setStyle(gpa, {
    id: ids[0],
    "class": 'form-control'
  });
  message = E('textarea', {
    id: ids[1],
    "class": 'form-control',
    minHeight: 100,
    minWidth: '100%',
    maxWidth: '100%'
  });
  isTrained = E('input', {
    type: 'checkbox'
  });
  contents = [
    gradesContainer = E(), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[0]
    }, 'معدل کل'), gpa), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[1]
    }, 'پیام برای استاد'), message), E({
      "class": 'checkbox'
    }, E('label', null, isTrained, text('در کارگاه شرکت کرده‌است.')))
  ];
  allInputs = [gpa, message, isTrained];
  setEnabled = function() {
    return modal.instance.setEnabled(gpa.value());
  };
  onEvent([gpa], ['input', 'pInput'], setEnabled);
  onEnter([gpa, isTrained], function() {
    return modal.instance.submit();
  });
  allInputs.forEach(function(input) {
    return onEvent(input, ['focus', 'input', 'change'], function() {
      return input.dirty = true;
    });
  });
  offState = void 0;
  return returnObject({
    credit: function() {
      return function(requestForAssistant) {
        allInputs.forEach(function(input) {
          return input.dirty = false;
        });
        empty(gradesContainer);
        state.all(['offerings', 'courses'], {
          once: true
        }, function(arg1) {
          var courses, offering, offerings;
          offerings = arg1[0], courses = arg1[1];
          offering = (offerings.filter(function(arg2) {
            var id;
            id = arg2.id;
            return String(id) === String(requestForAssistant.offeringId);
          }))[0];
          return grades = offering.requiredCourses.map(function(_id) {
            return (courses.filter(function(arg2) {
              var id;
              id = arg2.id;
              return String(id) === String(_id);
            }))[0];
          }).map(function(course) {
            var g, grade, id, input, ref1;
            grade = (ref1 = (requestForAssistant.grades.filter(function(arg2) {
              var courseId;
              courseId = arg2.courseId;
              return String(courseId) === String(course.id);
            }))[0]) != null ? ref1.grade : void 0;
            append(gradesContainer, g = E({
              "class": 'form-group'
            }, E('label', {
              "for": id = generateId()
            }, "نمره درس " + course.name), input = E('input', {
              id: id,
              "class": 'form-control',
              value: grade
            })));
            onEnter(g, function() {
              return modal.instance.submit();
            });
            return {
              course: course,
              input: input
            };
          });
        });
        offState = state.requestForAssistants.on(function(requestForAssistants) {
          requestForAssistant = (requestForAssistants.filter(function(arg1) {
            var id;
            id = arg1.id;
            return String(id) === String(requestForAssistant.id);
          }))[0];
          if (!requestForAssistant) {
            return modal.instance.hide();
          }
          if (!gpa.dirty) {
            setStyle(gpa, {
              value: requestForAssistant.gpa
            });
          }
          if (!message.dirty) {
            setStyle(message, {
              value: requestForAssistant.message
            });
          }
          if (!isTrained.dirty) {
            return setStyle(isTrained, {
              checked: requestForAssistant.isTrained
            });
          }
        });
        return modal.instance.display({
          enabled: true,
          autoHide: true,
          title: 'جزئیات/ویرایش درخواست',
          submitText: 'ثبت تغییرات',
          closeText: 'لغو تغییرات',
          contents: contents,
          close: function() {
            if (typeof offState === "function") {
              offState();
            }
            return offState = null;
          },
          submit: function() {
            return service.updateRequestForAssistant({
              id: requestForAssistant.id,
              gpa: gpa.value(),
              message: message.value(),
              isTrained: isTrained.checked(),
              grades: grades.map(function(arg1) {
                var course, input;
                course = arg1.course, input = arg1.input;
                return {
                  courseId: course.id,
                  grade: input.value()
                };
              })
            });
          }
        });
      };
    }
  });
});


},{"../../../components/restrictedInput/grade":13,"../../../singletons/modal":33,"../../../utils":38,"../../../utils/component":34,"../../../utils/dom":36}],65:[function(require,module,exports){
var component, sendEmail;

component = require('../../../utils/component');

sendEmail = require('./sendEmail');

module.exports = component('requestForAssistantsExtras', function(arg, arg1) {
  var E, _sendEmail, dom, events, goToRequestForAssistants, hide, offeringIds, onEvent, professors, returnObject, sendEmailToProfessors, sendEmailToStudents, setStyle, show, students, view;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  offeringIds = arg1.offeringIds, goToRequestForAssistants = arg1.goToRequestForAssistants;
  E = dom.E, setStyle = dom.setStyle, show = dom.show, hide = dom.hide;
  onEvent = events.onEvent;
  view = [
    offeringIds ? [
      E('span', {
        marginRight: 10
      }, "شما در حال مشاهده درخواست‌های مربوط به " + offeringIds.length + " فراخوان هستید."), (function() {
        var button;
        button = E({
          "class": 'btn btn-default',
          marginRight: 10
        }, 'مشاهده همه درخواست‌ها');
        onEvent(button, 'click', function() {
          return goToRequestForAssistants();
        });
        return button;
      })()
    ] : void 0, E({
      "class": 'btn-group',
      marginRight: 10
    }, hide(sendEmailToStudents = E({
      "class": 'btn btn-default'
    })), hide(sendEmailToProfessors = E({
      "class": 'btn btn-default'
    })))
  ];
  _sendEmail = E(sendEmail);
  students = professors = void 0;
  onEvent(sendEmailToProfessors, 'click', function() {
    return _sendEmail.show(professors.map(function(arg2) {
      var id;
      id = arg2.id;
      return id;
    }));
  });
  onEvent(sendEmailToStudents, 'click', function() {
    return _sendEmail.show(students.map(function(arg2) {
      var id;
      id = arg2.id;
      return id;
    }));
  });
  returnObject({
    update: function(descriptors) {
      var selectedDescriptors;
      selectedDescriptors = descriptors.filter(function(arg2) {
        var selected;
        selected = arg2.selected;
        return selected;
      });
      if (selectedDescriptors.length) {
        show(sendEmailToStudents);
        show(sendEmailToProfessors);
        students = Object.keys(selectedDescriptors.reduce((function(acc, arg2) {
          var entity;
          entity = arg2.entity;
          acc[entity.studentId] = true;
          return acc;
        }), {}));
        setStyle(sendEmailToStudents, {
          text: "ارسال ایمیل به " + students.length + " دانشجو انتخاب شده"
        });
        professors = Object.keys(selectedDescriptors.reduce((function(acc, arg2) {
          var entity;
          entity = arg2.entity;
          acc[entity.professorId] = true;
          return acc;
        }), {}));
        return setStyle(sendEmailToProfessors, {
          text: "ارسال ایمیل به " + professors.length + " استاد انتخاب شده"
        });
      } else {
        hide(sendEmailToStudents);
        return hide(sendEmailToProfessors);
      }
    }
  });
  return view;
});


},{"../../../utils/component":34,"./sendEmail":68}],66:[function(require,module,exports){
var component, credit, crudPage, dropdown, extend, extras, multiselect, ref, searchBoxStyle, stateSyncedDropdown, textIsInSearch,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

component = require('../../../utils/component');

crudPage = require('../crudPage');

credit = require('./credit');

multiselect = require('./multiselect');

extras = require('./extras');

searchBoxStyle = require('../../../components/table/searchBoxStyle');

dropdown = require('../../../components/dropdown');

stateSyncedDropdown = require('../../../components/dropdown/stateSynced');

ref = require('../../../utils'), extend = ref.extend, textIsInSearch = ref.textIsInSearch;

module.exports = component('requestForAssistantsView', function(arg, arg1) {
  var E, courseNameInput, dom, events, extrasInstance, goToRequestForAssistants, isTrainedDropdown, multiselectInstance, offeringIds, onEvent, professorNameInput, requestForAssistants, service, setStyle, state, statusDropdown, studentNameInput, termDropdown, update, view;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  goToRequestForAssistants = arg1.goToRequestForAssistants, offeringIds = arg1.offeringIds;
  E = dom.E, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  service.getPersons();
  service.getCourses();
  service.getOfferings();
  service.getTerms();
  service.getCurrentTerm();
  service.getRequestForAssistants();
  termDropdown = E(stateSyncedDropdown, {
    stateName: 'terms',
    selectedIdStateName: 'currentTerm'
  });
  setStyle(termDropdown, searchBoxStyle.font);
  setStyle(termDropdown.input, searchBoxStyle.input);
  termDropdown.showEmpty(true);
  isTrainedDropdown = E(dropdown, {
    getTitle: function(x) {
      switch (x) {
        case 0:
          return 'بله';
        case 1:
          return 'خیر';
      }
    }
  });
  setStyle(isTrainedDropdown, searchBoxStyle.font);
  setStyle(isTrainedDropdown.input, searchBoxStyle.input);
  isTrainedDropdown.showEmpty(true);
  isTrainedDropdown.update([0, 1]);
  statusDropdown = E(dropdown);
  setStyle(statusDropdown, searchBoxStyle.font);
  setStyle(statusDropdown.input, searchBoxStyle.input);
  statusDropdown.showEmpty(true);
  statusDropdown.update(['تایید شده', 'رد شده', 'در حال بررسی']);
  professorNameInput = E('input', searchBoxStyle.textbox);
  courseNameInput = E('input', searchBoxStyle.textbox);
  studentNameInput = E('input', searchBoxStyle.textbox);
  view = E(crudPage, {
    entityName: 'درخواست',
    requiredStates: ['offerings', 'courses', 'persons', 'terms', 'currentTerm', 'requestForAssistants'],
    noCreating: true,
    headers: [
      {
        name: 'نام استاد',
        key: 'professorName',
        searchBox: professorNameInput
      }, {
        name: 'نام درس',
        key: 'courseName',
        searchBox: courseNameInput
      }, {
        name: 'نام دانشجو',
        key: 'studentName',
        searchBox: studentNameInput
      }, {
        name: 'ترم',
        key: 'termId',
        searchBox: termDropdown
      }, {
        name: 'در کارگاه شرکت کرده است',
        searchBox: isTrainedDropdown,
        getValue: function(requestForAssistant) {
          if (requestForAssistant.isTrained) {
            return 'بله';
          } else {
            return 'خیر';
          }
        },
        styleTd: function(requestForAssistant, td) {
          if (requestForAssistant.isTrained) {
            return setStyle(td, {
              color: 'green'
            });
          } else {
            return setStyle(td, {
              color: 'red'
            });
          }
        }
      }, {
        name: 'وضعیت',
        key: 'status',
        searchBox: statusDropdown,
        styleTd: function(requestForAssistant, td) {
          switch (requestForAssistant.status) {
            case 'تایید شده':
              return setStyle(td, {
                color: 'green'
              });
            case 'رد شده':
              return setStyle(td, {
                color: 'red'
              });
            default:
              return setStyle(td, {
                color: 'black'
              });
          }
        }
      }
    ],
    extraButtonsBefore: multiselectInstance = E(multiselect, function(callback) {
      return view.setSelectedRows(callback);
    }),
    extraButtons: extrasInstance = E(extras, {
      goToRequestForAssistants: goToRequestForAssistants,
      offeringIds: offeringIds
    }),
    onTableUpdate: function(descriptors) {
      multiselectInstance.setChecked(descriptors);
      return extrasInstance.update(descriptors);
    },
    credit: E(credit).credit,
    deleteItem: function(requestForAssistants) {
      return service.deleteRequestForAssistants(requestForAssistant.map(function(arg2) {
        var id;
        id = arg2.id;
        return id;
      }));
    }
  });
  requestForAssistants = [];
  update = function() {
    var courseName, filteredRequestForAssistants, isTrained, professorName, status, studentName, term;
    professorName = professorNameInput.value();
    courseName = courseNameInput.value();
    studentName = studentNameInput.value();
    term = termDropdown.value();
    isTrained = isTrainedDropdown.value();
    status = statusDropdown.value();
    filteredRequestForAssistants = requestForAssistants;
    if (offeringIds) {
      filteredRequestForAssistants = filteredRequestForAssistants.filter(function(requestForAssistant) {
        var ref1;
        return ref1 = String(requestForAssistant.offeringId), indexOf.call(offeringIds.map(function(offeringId) {
          return String(offeringId);
        }), ref1) >= 0;
      });
    }
    if (professorName) {
      filteredRequestForAssistants = filteredRequestForAssistants.filter(function(requestForAssistant) {
        return textIsInSearch(requestForAssistant.professorName, professorName, true, true);
      });
    }
    if (courseName) {
      filteredRequestForAssistants = filteredRequestForAssistants.filter(function(requestForAssistant) {
        return textIsInSearch(requestForAssistant.courseName, courseName, true, true);
      });
    }
    if (studentName) {
      filteredRequestForAssistants = filteredRequestForAssistants.filter(function(requestForAssistant) {
        return textIsInSearch(requestForAssistant.studentName, studentName, true, true);
      });
    }
    if (~term) {
      filteredRequestForAssistants = filteredRequestForAssistants.filter(function(requestForAssistant) {
        return requestForAssistant.termId === term;
      });
    }
    if (~isTrained) {
      filteredRequestForAssistants = filteredRequestForAssistants.filter(function(requestForAssistant) {
        return requestForAssistant.isTrained === !isTrained;
      });
    }
    if (~status) {
      filteredRequestForAssistants = filteredRequestForAssistants.filter(function(requestForAssistant) {
        return textIsInSearch(requestForAssistant.status, status, true, true);
      });
    }
    return view.setData(filteredRequestForAssistants);
  };
  state.all(['requestForAssistants', 'offerings', 'persons', 'courses'], function(arg2) {
    var _requestForAssistants, courses, offerings, persons;
    _requestForAssistants = arg2[0], offerings = arg2[1], persons = arg2[2], courses = arg2[3];
    requestForAssistants = _requestForAssistants.map(function(requestForAssistant) {
      var offering, ref1, ref2, ref3, ref4, ref5, ref6;
      offering = (offerings.filter(function(arg3) {
        var id;
        id = arg3.id;
        return String(id) === String(requestForAssistant.offeringId);
      }))[0];
      return extend({}, requestForAssistant, {
        studentName: (ref1 = (ref2 = (persons.filter(function(arg3) {
          var id;
          id = arg3.id;
          return String(id) === String(requestForAssistant.studentId);
        }))[0]) != null ? ref2.fullName : void 0) != null ? ref1 : '',
        professorName: (ref3 = (ref4 = (persons.filter(function(arg3) {
          var id;
          id = arg3.id;
          return String(id) === String(offering.professorId);
        }))[0]) != null ? ref4.fullName : void 0) != null ? ref3 : '',
        courseName: (ref5 = (ref6 = (courses.filter(function(arg3) {
          var id;
          id = arg3.id;
          return String(id) === String(offering.courseId);
        }))[0]) != null ? ref6.name : void 0) != null ? ref5 : '',
        professorId: offering.professorId,
        termId: offering.termId
      });
    });
    return update();
  });
  onEvent([professorNameInput, courseNameInput, studentNameInput, termDropdown.input, isTrainedDropdown.input, statusDropdown.input], ['input', 'pInput'], update);
  return view;
});


},{"../../../components/dropdown":6,"../../../components/dropdown/stateSynced":9,"../../../components/table/searchBoxStyle":18,"../../../utils":38,"../../../utils/component":34,"../crudPage":53,"./credit":64,"./extras":65,"./multiselect":67}],67:[function(require,module,exports){
var body, component;

component = require('../../../utils/component');

body = require('../../../utils/dom').body;

module.exports = component('offeringsMultiselect', function(arg, setSelectedRows) {
  var E, addClass, button, checkbox, dom, events, group, l0, l1, l2, l3, l4, l5, l6, list, onEvent, removeClass, returnObject, setStyle;
  dom = arg.dom, events = arg.events, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, addClass = dom.addClass, removeClass = dom.removeClass;
  onEvent = events.onEvent;
  group = E({
    "class": 'btn-group',
    marginLeft: 10
  }, button = E({
    "class": 'btn btn-default dropdown-toggle'
  }, E('span', {
    "class": 'caret',
    cursor: 'pointer'
  }), checkbox = E('input', {
    type: 'checkbox',
    marginRight: 10,
    position: 'relative',
    top: 3
  })), list = E('ul', {
    "class": 'dropdown-menu'
  }, l0 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب همه')), l1 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب هیچ')), E('li', {
    "class": 'divider'
  }), l2 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب درخواست‌های در حال بررسی')), l3 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب درخواست‌های تایید شده')), l4 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب درخواست‌های رد شده')), E('li', {
    "class": 'divider'
  }), l5 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب درخواست‌های کارگاه رفته')), l6 = E('li', null, E('a', {
    cursor: 'pointer'
  }, 'انتخاب درخواست‌های کارگاه نرفته'))));
  onEvent(button, 'click', checkbox, function() {
    return addClass(group, 'open');
  });
  onEvent(E(body), 'click', [button, list], function() {
    return removeClass(group, 'open');
  });
  onEvent([l0, l1, l2, l3, l4, l5, l6], 'click', function() {
    return removeClass(group, 'open');
  });
  onEvent(checkbox, 'change', function() {
    return setSelectedRows(function(rows) {
      if (checkbox.checked()) {
        return rows;
      } else {
        return [];
      }
    });
  });
  onEvent(l0, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows;
    });
  });
  onEvent(l1, 'click', function() {
    return setSelectedRows(function(rows) {
      return [];
    });
  });
  onEvent(l2, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.status === 'در حال بررسی';
      });
    });
  });
  onEvent(l3, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.status === 'تایید شده';
      });
    });
  });
  onEvent(l4, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.status === 'رد شده';
      });
    });
  });
  onEvent(l5, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return entity.isTrained;
      });
    });
  });
  onEvent(l6, 'click', function() {
    return setSelectedRows(function(rows) {
      return rows.filter(function(arg1) {
        var entity;
        entity = arg1.entity;
        return !entity.isTrained;
      });
    });
  });
  returnObject({
    setChecked: function(descriptors) {
      return setStyle(checkbox, {
        checked: descriptors.length && descriptors.every(function(arg1) {
          var selected;
          selected = arg1.selected;
          return selected;
        })
      });
    }
  });
  return group;
});


},{"../../../utils/component":34,"../../../utils/dom":36}],68:[function(require,module,exports){
var component, generateId, modal;

component = require('../../../utils/component');

modal = require('../../../singletons/modal');

generateId = require('../../../utils/dom').generateId;

module.exports = component('requestForAssistantsExtras', function(arg) {
  var E, contents, disable, dom, enable, events, hide, id0, id1, message, onEvent, returnObject, service, setStyle, show, title;
  dom = arg.dom, events = arg.events, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, show = dom.show, hide = dom.hide, enable = dom.enable, disable = dom.disable;
  onEvent = events.onEvent;
  contents = [
    E({
      "class": 'form-group'
    }, E('label', {
      "for": id0 = generateId()
    }, 'موضوع ایمیل'), title = E('input', {
      id: id0,
      "class": 'form-control'
    })), E({
      "class": 'form-group'
    }, E('label', {
      "for": id1 = generateId()
    }, 'متن ایمیل'), message = E('textarea', {
      id: id1,
      "class": 'form-control',
      minHeight: 100,
      minWidth: '100%',
      maxWidth: '100%'
    }))
  ];
  onEvent([title, message], 'input', function() {
    return modal.instance.setEnabled(title.value() && message.value());
  });
  return returnObject({
    show: function(ids) {
      setStyle(title, {
        value: ''
      });
      setStyle(message, {
        value: ''
      });
      return modal.instance.display({
        enabled: false,
        autoHide: true,
        title: 'ارسال ایمیل',
        submitText: 'ارسال',
        closeText: 'لغو',
        contents: contents,
        submit: function() {
          disable([title, message]);
          return service.sendEmail({
            ids: ids,
            title: title.value(),
            message: message.value()
          }).then(function() {
            return enable([title, message]);
          })["catch"](function() {
            return enable([title, message]);
          });
        }
      });
    }
  });
});


},{"../../../singletons/modal":33,"../../../utils/component":34,"../../../utils/dom":36}],69:[function(require,module,exports){
var component, generateId, stateSyncedDropdown, toEnglish;

component = require('../../utils/component');

stateSyncedDropdown = require('../../components/dropdown/stateSynced');

toEnglish = require('../../utils').toEnglish;

generateId = require('../../utils/dom').generateId;

module.exports = component('adminStaticDataView', function(arg) {
  var E, disable, dom, enable, events, id, loading, noData, onEvent, others, service, setStyle, state, submit, terms, view, yesData;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, others = arg.others;
  E = dom.E, setStyle = dom.setStyle, enable = dom.enable, disable = dom.disable, loading = dom.loading;
  onEvent = events.onEvent;
  loading = others.loading;
  service.getTerms();
  service.getCurrentTerm();
  id = generateId();
  terms = E(stateSyncedDropdown, {
    stateName: 'terms',
    selectedIdStateName: 'currentTerm'
  });
  setStyle(terms, {
    id: id
  });
  view = E(null, noData = E(null, 'در حال بارگزاری...'), yesData = E({
    "class": 'form-horizontal',
    marginTop: 40
  }, E({
    "class": 'form-group '
  }, E('label', {
    "for": id,
    "class": 'control-label col-md-2'
  }, 'ترم جاری'), E({
    "class": 'col-md-4'
  }, terms)), submit = E({
    "class": 'btn btn-primary'
  }, 'ثبت تغییرات')));
  onEvent(submit, 'click', function() {
    disable(submit);
    return service.setStaticData([
      {
        key: 'currentTerm',
        value: toEnglish(terms.value())
      }
    ]).fin(function() {
      terms.undirty();
      return enable(submit);
    });
  });
  loading(['terms', 'currentTerm'], yesData, noData);
  return view;
});


},{"../../components/dropdown/stateSynced":9,"../../utils":38,"../../utils/component":34,"../../utils/dom":36}],70:[function(require,module,exports){
var _login, component;

component = require('../utils/component');

_login = require('../sheets/login');

module.exports = component('firstPage', function(arg) {
  var E, dom, email, empty, events, login, onEvent, staff, student, view;
  dom = arg.dom, events = arg.events;
  E = dom.E, empty = dom.empty;
  onEvent = events.onEvent;
  login = E(_login);
  view = E({
    width: (359 + 2 * 5) * 3,
    margin: '200px auto'
  }, email = E('img', {
    cursor: 'pointer',
    margin: 5,
    src: 'assets/loginEmail.jpg'
  }), staff = E('img', {
    cursor: 'pointer',
    margin: 5,
    src: 'assets/loginStaff.jpg'
  }), student = E('img', {
    cursor: 'pointer',
    margin: 5,
    src: 'assets/loginStudent.jpg'
  }));
  onEvent(email, 'click', function() {
    return login.display();
  });
  onEvent([staff, student], 'click', function() {
    while (document.body.children.length) {
      document.body.removeChild(document.body.children[0]);
    }
    return location.href = 'https://auth.ut.ac.ir:8443/cas/login?service=http%3A%2F%2Feceta.ut.ac.ir';
  });
  return view;
});


},{"../sheets/login":30,"../utils/component":34}],71:[function(require,module,exports){
var adminView, component, firstPage, professorView, studentView;

component = require('../utils/component');

firstPage = require('./firstPage');

adminView = require('./adminView');

professorView = require('./professorView');

studentView = require('./studentView');

module.exports = component('views', function(arg) {
  var E, append, dom, empty, previousType, state, wrapper;
  dom = arg.dom, state = arg.state;
  E = dom.E, append = dom.append, empty = dom.empty;
  wrapper = E({
    margin: 30
  });
  previousType = void 0;
  state.person.on({
    allowNull: true
  }, function(person) {
    var ref, type, view;
    type = (ref = person != null ? person.type : void 0) != null ? ref : null;
    if (type === previousType) {
      return;
    }
    previousType = type;
    empty(wrapper);
    switch (type) {
      case 'کارشناس آموزش':
        view = adminView;
        break;
      case 'دانشجو':
        view = studentView;
        break;
      case 'استاد':
      case 'نماینده استاد':
        view = professorView;
        break;
      default:
        view = firstPage;
    }
    if (view) {
      return append(wrapper, E(view));
    }
  });
  return wrapper;
});


},{"../utils/component":34,"./adminView":54,"./firstPage":70,"./professorView":72,"./studentView":78}],72:[function(require,module,exports){
var component, extend, offeringView;

component = require('../../utils/component');

offeringView = require('./offeringView');

extend = require('../../utils').extend;

module.exports = component('profesorView', function(arg) {
  var E, addClass, append, dom, empty, events, handleOfferings, handleSelectedOffering, hide, loading, noData, offState, offeringViewInstance, offerings, offeringsList, onEvent, removeClass, selectedOfferingId, service, show, state, view, yesData;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service;
  E = dom.E, append = dom.append, empty = dom.empty, addClass = dom.addClass, removeClass = dom.removeClass, hide = dom.hide, show = dom.show, loading = dom.loading;
  onEvent = events.onEvent;
  service.getProfessorOfferings();
  service.getCourses();
  service.getChores();
  view = E(null, noData = E(null, 'در حال بارگزاری...'), yesData = E({
    position: 'relative'
  }, E({
    "class": 'col-md-3',
    marginTop: 40
  }, E({
    "class": 'panel panel-default'
  }, E({
    "class": 'panel-heading'
  }, E({
    "class": 'panel-title'
  }, 'لیست درس‌های شما')), offeringsList = E({
    "class": 'list-group'
  }))), hide(offeringViewInstance = E(offeringView))));
  offerings = [];
  selectedOfferingId = void 0;
  handleSelectedOffering = function() {
    if (selectedOfferingId == null) {
      return;
    }
    show(offeringView);
    return offeringViewInstance.update(offerings.filter(function(arg1) {
      var id;
      id = arg1.id;
      return String(id) === String(selectedOfferingId)[0];
    }));
  };
  handleOfferings = function() {
    empty(offeringsList);
    append(offeringsList, offerings.map(function(arg1) {
      var count, courseName, element, id, isClosed, requestForAssistants;
      id = arg1.id, courseName = arg1.courseName, requestForAssistants = arg1.requestForAssistants, isClosed = arg1.isClosed;
      count = requestForAssistants.length;
      element = E('li', {
        cursor: 'pointer',
        "class": 'list-group-item'
      }, E('span', {
        cursor: 'pointer'
      }, courseName), E('span', {
        cursor: 'pointer',
        "class": 'badge',
        color: 'white',
        backgroundColor: (isClosed ? '#008000' : '#ff7878')
      }, isClosed ? 'نهایی شده' : count));
      if (String(id) === String(selectedOfferingId)) {
        addClass(element, 'active');
      } else {
        removeClass(element, 'active');
      }
      onEvent(element, 'click', function() {
        selectedOfferingId = id;
        return handleOfferings();
      });
      return element;
    }));
    return handleSelectedOffering();
  };
  loading(['offerings', 'courses', 'chores'], yesData, noData);
  offState = state.all(['offerings', 'courses'], function(arg1) {
    var _offerings, courses;
    _offerings = arg1[0], courses = arg1[1];
    offerings = _offerings.map(function(offering) {
      return extend({}, offering, {
        courseName: (courses.filter(function(arg2) {
          var id;
          id = arg2.id;
          return String(id) === String(offering.courseId);
        }))[0].name
      });
    });
    if (!offeringViewInstance.isEditing()) {
      return handleOfferings();
    }
  });
  return view;
});


},{"../../utils":38,"../../utils/component":34,"./offeringView":74}],73:[function(require,module,exports){
var component, extend, ref, remove;

component = require('../../../utils/component');

ref = require('../../../utils'), extend = ref.extend, remove = ref.remove;

module.exports = component('professorOfferingsCardView', function(arg, arg1) {
  var E, append, changeRequestForAssistant, chores, courses, dom, empty, events, offering, onEvent, returnObject, setStyle, state, text, update, view;
  dom = arg.dom, events = arg.events, state = arg.state, returnObject = arg.returnObject;
  changeRequestForAssistant = arg1.changeRequestForAssistant;
  E = dom.E, text = dom.text, append = dom.append, empty = dom.empty, setStyle = dom.setStyle;
  onEvent = events.onEvent;
  offering = void 0;
  courses = chores = [];
  view = E();
  update = function() {
    empty(view);
    return append(view, offering.requestForAssistants.map(function(requestForAssistant) {
      var body;
      return E({
        "class": "panel panel-" + (requestForAssistant.status === 'تایید شده' ? 'success' : requestForAssistant.status === 'رد شده' ? 'danger' : 'info')
      }, E({
        "class": 'panel-heading'
      }, E({
        float: 'left'
      }, !requestForAssistant.isClosed ? (E({
        "class": 'btn-group btn-group-xs'
      }, [
        {
          status: 'تایید شده',
          klass: 'success'
        }, {
          status: 'رد شده',
          klass: 'danger'
        }, {
          status: 'در حال بررسی',
          klass: 'info'
        }
      ].map(function(arg2) {
        var button, klass, status;
        status = arg2.status, klass = arg2.klass;
        button = E('button', {
          "class": 'btn btn-' + (status === requestForAssistant.status ? klass : 'default')
        }, status);
        onEvent(button, 'click', function(e) {
          if (status !== 'تایید شده') {
            requestForAssistant.chores = [];
            requestForAssistant.isChiefTA = false;
          }
          extend(requestForAssistant, {
            status: status
          });
          return changeRequestForAssistant(requestForAssistant);
        });
        return button;
      })), E({
        float: 'left',
        marginLeft: 10
      }, 'تغییر وضعیت درخواست:')) : void 0), E('h3', {
        "class": 'panel-title',
        fontWeight: 'bold'
      }, text(fullName + " ("), E('a', {
        cursor: 'pointer',
        fontWeight: 'lighter',
        fontSize: 13,
        target: '_blank',
        href: "mailto:" + requestForAssistant.email
      }, requestForAssistant.email), text(')'))), body = E({
        "class": 'panel-body'
      }, E({
        "class": 'col-md-5'
      }, E('ul', null, offering.requiredCourses.map(function(courseId) {
        var course, grade;
        course = courses.filter(function(arg2) {
          var id;
          id = arg2.id;
          return String(id) === String(courseId);
        })[0];
        grade = requestForAssistant.grades.filter(function(arg2) {
          var courseId;
          courseId = arg2.courseId;
          return String(courseId) === String(course.id);
        })[0];
        return E('li', null, "نمره درس " + course.name + ": " + (grade != null ? grade.grade : '(وارد نشده)'));
      }), E('li', null, E('span', {
        fontWeight: 'bold'
      }, "معدل کل: " + requestForAssistant.gpa)), E('li', null, "مقطع: " + requestForAssistant.degree), E('li', null, text('در کارگاه آموزش دستیاران آموزشی شرکت '), E('span', {
        fontWeight: 'bold',
        color: (requestForAssistant.isTrained ? 'green' : 'red')
      }, requestForAssistant.isTrained ? 'کرده است.' : 'نکرده است.')))), requestForAssistant.message ? (function() {
        var border;
        border = E({
          "class": 'col-md-4',
          borderLeft: '1px dashed #AAA',
          borderRight: '1px dashed #AAA'
        }, [
          E({
            fontWeight: 'bold',
            marginBottom: 10
          }, 'پیام دانشجو: '), E('span', null, requestForAssistant.replace('\n', '<br />'))
        ]);
        setTimeout(function() {
          return setStyle(border, {
            height: body.offsetHeight - 30
          });
        });
        return border;
      })() : void 0, E({
        "class": 'col-md-3'
      }, requestForAssistant.status === 'تایید شده' ? [
        E({
          "class": 'checkbox'
        }, E('label', null, (function() {
          var checkbox;
          checkbox = E('input', {
            type: 'checkbox',
            cursor: 'pointer',
            checked: requestForAssistant.isChiefTA
          });
          onEvent(checkbox, 'change', function() {
            if (requestForAssistant.isClosed) {
              return setStyle(checkbox, {
                checked: !checkbox.checked
              });
            }
            requestForAssistant.isChiefTA = checkbox.checked;
            return changeRequestForAssistant(requestForAssistant);
          });
          return checkbox;
        })(), text('دستیار اصلی است.'))), E('span', {
          fontWeight: 'bold'
        }, 'وظایف:'), E({
          "class": 'well well-sm'
        }, chores.map(function(arg2) {
          var id, persianName;
          id = arg2.id, persianName = arg2.persianName;
          return E({
            "class": 'checkbox'
          }, E('label', null, (function() {
            var checkbox;
            checkbox = E('input', {
              type: 'checkbox',
              cursor: 'pointer',
              checked: requestForAssistant.chores.some(function(choreId) {
                return String(choreId) === String(id);
              })
            });
            onEvent(checkbox, 'change', function() {
              if (requestForAssistant.isClosed) {
                return setStyle(checkbox, {
                  checked: !checkbox.checked
                });
              }
              remove(requestForAssistant.chores, id);
              if (checkbox.checked) {
                requestForAssistant.chores.push(id);
              }
              return changeRequestForAssistant(requestForAssistant);
            });
            return checkbox;
          })(), text(persianName)));
        }))
      ] : void 0)));
    }));
  };
  state.all(['courses', 'chores'], function(arg2) {
    var _chores, _courses;
    _courses = arg2[0], _chores = arg2[1];
    courses = _courses;
    chores = _chores;
    return update();
  });
  returnObject({
    update: function(_offering) {
      offering = _offering;
      return update();
    }
  });
  return view;
});


},{"../../../utils":38,"../../../utils/component":34}],74:[function(require,module,exports){
var Q, cardView, component, requiredCourses, tableView;

component = require('../../../utils/component');

Q = require('../../../q');

requiredCourses = require('./requiredCourses');

cardView = require('./cardView');

tableView = require('./tableView');

module.exports = component('professorOfferingView', function(arg) {
  var E, addClass, cardViewButton, cardViewInstance, changeRequestForAssistant, closeOffering, dom, events, hide, isEditing, lastRequest, noRequestForAssistants, offering, onEvent, removeClass, requiredCoursesInstance, returnObject, service, setStyle, show, state, tableViewButton, tableViewInstance, title, view, yesRequestForAssistants;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, show = dom.show, hide = dom.hide, addClass = dom.addClass, removeClass = dom.removeClass;
  onEvent = events.onEvent;
  isEditing = false;
  lastRequest = Q();
  changeRequestForAssistant = function(requestForAssistant) {
    isEditing = true;
    return lastRequest = lastRequest.then(function() {
      isEditing = true;
      return service.changeRequestForAssistant({
        id: requestForAssistant.id,
        isChiefTA: requestForAssistant.isChiefTA,
        choreIds: requestForAssistant.chores,
        status: requestForAssistant.status
      });
    }).fin(function() {
      return isEditing = false;
    });
  };
  view = E({
    "class": 'col-md-9',
    marginTop: 40
  }, E({
    marginBottom: 100
  }, title = E('h1', {
    float: 'right'
  }), closeOffering = E('button', {
    "class": 'btn btn-success',
    float: 'left',
    marginTop: 20
  }, 'نهایی کردن انتخاب دستیاران...')), requiredCoursesInstance = E(requiredCourses), noRequestForAssistants = E(null, 'هنوز دانشجویی درخواست دستیاری در این درس نکرده است.'), yesRequestForAssistants = [
    E({
      float: 'left'
    }, E({
      "class": 'btn btn-default'
    }, 'ارسال ایمیل به دستیاران'), E({
      "class": 'btn-group'
    }, tableViewButton = E('button', {
      "class": 'btn btn-default'
    }, E({
      "class": 'fa fa-table',
      cursor: 'pointer'
    })), cardViewButton = E('button', {
      "class": 'btn btn-primary'
    }, E({
      "class": 'fa fa-bars',
      cursor: 'pointer'
    })))), E('h4', {
      fontWeight: 'bold',
      marginBottom: 35
    }, 'لیست درخواست‌های دانشجویان'), hide(tableViewInstance = requestsList, E(tableView, {
      changeRequestForAssistant: changeRequestForAssistant
    })), cardViewInstance = requestsList, E(cardView, {
      changeRequestForAssistant: changeRequestForAssistant
    })
  ]);
  onEvent(cardViewButton, 'click', function() {
    removeClass(cardViewButton('btn-default'));
    removeClass(tableViewButton('btn-primary'));
    addClass(cardViewButton, 'btn-primary');
    addClass(tableViewButton, 'btn-default');
    hide(tableViewInstance);
    return show(cardViewInstance);
  });
  onEvent(tableViewButton, 'click', function() {
    removeClass(cardViewButton('btn-primary'));
    removeClass(tableViewButton('btn-default'));
    addClass(cardViewButton, 'btn-default');
    addClass(tableViewButton, 'btn-primary');
    show(tableViewInstance);
    return hide(cardViewInstance);
  });
  offering = void 0;
  onEvent(closeOffering, 'click', function() {
    var accepted, hasPending;
    hasPending = offering.requestForAssistants.filter(function(arg1) {
      var status;
      status = arg1.status;
      return status === 'در حال بررسی';
    }).length;
    accepted = offering.requestForAssistants.filter(function(arg1) {
      var status;
      status = arg1.status;
      return status === 'تایید شده';
    }).map(function(arg1) {
      var fullName;
      fullName = arg1.fullName;
      return fullName;
    });
    return modal.instance.display({
      contents: hasPending ? E('h2', {
        color: 'red'
      }, 'شما هنوز درخواست در حال بررسی دارید. لطفا ابتدا آنها را تایی یا رد کدید.') : [
        E('h2', {
          color: 'red',
          marginBottom: 30
        }, 'آیا از نهایی کردن فهرست دستیاران اطمینان دارید؟'), E({
          fontWeight: 'bold',
          fontSize: 15
        }, E({
          marginBottom: 10
        }, accepted.length ? "دستیاران انتخاب‌شده برای درس «" + offering.courseName + "»:" : 'شما دانشجویی را به عونان دستیار تایید نکرده‌اید.'), accepted.length ? [
          E('ul', null, accepted.map(function(fullName) {
            return E('li', null, fullName);
          })), E({
            marginTop: 20
          }, 'در صورت نهایی کردن، رایانامه‌ای به این دانشجویان مبنی بر پذیرش آنها ارسال خواهد شد.')
        ] : void 0)
      ],
      autoHide: true,
      enabled: !hasPending,
      submitText: hasPending ? null : 'نهایی کردن',
      closeText: hasPending ? 'بستن' : 'انصراف',
      submitType: 'danger',
      submit: function() {
        return service.closeOffering({
          id: offering.id
        });
      }
    });
  });
  return returnObject({
    isEditing: function() {
      return isEditing;
    },
    update: function(_offering) {
      offering = _offering;
      setStyle(title, {
        text: "درس " + offering.courseName
      });
      requiredCoursesInstance.update(offering);
      tableViewInstance.update(offering);
      cardViewInstance.update(offering);
      if (offering.isClosed) {
        hide(closeOffering);
      } else {
        show(closeOffering);
      }
      if (offering.requestForAssistants.length) {
        hide(noRequestForAssistants);
        return show(yesRequestForAssistants);
      } else {
        show(noRequestForAssistants);
        return hide(yesRequestForAssistants);
      }
    }
  });
});


},{"../../../q":28,"../../../utils/component":34,"./cardView":73,"./requiredCourses":75,"./tableView":77}],75:[function(require,module,exports){
var component, style;

component = require('../../../../utils/component');

style = require('./style');

module.exports = component('professorOfferingViewRequiredCourses', function(arg) {
  var E, addCourse, addCourseDropdown, addCourseDropdownId, append, cover, doCover, doUncover, dom, empty, events, hide, offering, onEvent, requiredCoursesList, returnObject, service, setStyle, show, view;
  dom = arg.dom, events = arg.events, service = arg.service, returnObject = arg.returnObject;
  E = dom.E, setStyle = dom.setStyle, empty = dom.empty, append = dom.append, show = dom.show, hide = dom.hide;
  onEvent = events.onEvent;
  view = [
    E('h4', {
      fontWeight: 'bold',
      display: 'inline-block'
    }, 'لیست دروس مرتبط'), E('span', null, ' (درس‌هایی که دانشجو موظف است نمره خود را در آنها اعلام کند)'), E({
      margin: '10px 0 60px',
      position: 'relative'
    }, requiredCoursesList = E(), addCourse = E(style.addCourse), E('span', style.courseAdorner, '+ '), E('span', {
      cursor: 'pointer'
    }, 'افزودن درس'), cover = E({
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background: 'white',
      transition: '0.5s'
    }))
  ];
  doCover = function() {
    return setStyle(cover, {
      opacity: 0.5,
      visibility: 'visible'
    });
  };
  (doUncover = function() {
    return setStyle(cover, {
      opacity: 0,
      visibility: 'hidden'
    });
  })();
  addCourseDropdown = dropdown({
    getId: function(course) {
      return String(course.id);
    },
    getTitle: function(course) {
      return course.name;
    }
  });
  addCourseDropdown.showEmpty(true);
  addCourseDropdownId = generateId();
  setStyle(addCourseDropdown.input, {
    id: addCourseDropdownId
  });
  onEvent(addCourseDropdown.input, ['input', 'pInput'], function() {
    return modal.instance.setEnabled(~addCourseDropdown.value());
  });
  offering = void 0;
  onEvent(addCourse, 'click', function() {
    var id;
    return modal.instance.display({
      autoHide: true,
      title: 'افزودن درس',
      submitText: 'افزودن',
      contents: E({
        "class": 'form-group'
      }, E('label', {
        "for": id = addCourseDropdownId
      }, 'شماره دانشجویی / پرسنلی'), addCourseDropdown),
      submit: function() {
        return service.addRequiredCourse({
          courseId: addCourseDropdown.element.value,
          offeringId: offering.id
        });
      }
    });
  });
  returnObject({
    update: function(_offering) {
      offering = _offering;
      empty(requiredCoursesList);
      append(requiredCoursesList, offering.requiredCourses.map(function(courseId) {
        var course, name, x;
        name = getCourse(courseId).name;
        course = E(style.course, !offerin.isClosed ? x = E('span', style.courseX, '× ') : void 0, E('span', null, name));
        onEvent(x, 'click', function() {
          doCover();
          return service.removeRequiredCourse({
            courseId: courseId,
            offeringId: offering.id
          }).fin(doUncover);
        });
        return course;
      }));
      if (offering.isClosed) {
        return hide(addCourse);
      } else {
        return show(addCourse);
      }
    }
  });
  return view;
});


},{"../../../../utils/component":34,"./style":76}],76:[function(require,module,exports){
var addCourse, course, courseAdorner, courseX, extend;

extend = require('../../../../utils').extend;

course = {
  borderRadius: 3,
  display: 'inline-block',
  fontWeight: 'bold',
  marginLeft: 4,
  padding: '2px 6px',
  height: 25,
  lineHeight: 21,
  color: '#31708f',
  backgroundColor: '#d9edf7',
  border: '1px solid #bce8f1'
};

addCourse = extend({}, course, {
  color: '#3c763d',
  backgroundColor: '#dff0d8',
  borderColor: '#d6e9c6',
  cursor: 'pointer'
});

courseAdorner = {
  fontWeight: 'bold',
  cursor: 'pointer',
  cursor: 'pointer'
};

courseX = extend({}, courseAdorner, {
  color: '#d43f3a'
});


},{"../../../../utils":38}],77:[function(require,module,exports){
var body, component, document, ref, table;

component = require('../../../utils/component');

table = require('../../../components/table');

ref = require('../../../utils/dom'), document = ref.document, body = ref.body;

module.exports = component('professorOfferingsTableView', function(arg, arg1) {
  var E, append, changeRequestForAssistant, chores, courses, dom, empty, events, hidePopovers, offering, onEvent, popoverOpen, returnObject, setStyle, state, tableInstance, text, update, view;
  dom = arg.dom, events = arg.events, state = arg.state, returnObject = arg.returnObject;
  changeRequestForAssistant = arg1.changeRequestForAssistant;
  E = dom.E, text = dom.text, setStyle = dom.setStyle, append = dom.append, empty = dom.empty;
  onEvent = events.onEvent;
  offering = tableInstance = void 0;
  courses = chores = hidePopovers = [];
  popoverOpen = false;
  view = E('span');
  update = function() {
    hidePopovers.forEach(function(x) {
      return x();
    });
    empty(view);
    append(view, tableInstance = table({
      properties: {
        notStriped: true
      },
      headers: [
        {
          name: 'نام',
          key: 'fullName'
        }
      ].concat(offering.requiredCourses.map(function(courseId) {
        return {
          name: "نمره درس " + (getCourse(courseId).name),
          getValue: function(requestForAssistant) {
            var course, grade;
            course = courses.filter(function(arg2) {
              var id;
              id = arg2.id;
              return String(id) === String(courseId);
            })[0];
            grade = requestForAssistant.grades.filter(function(arg2) {
              var courseId;
              courseId = arg2.courseId;
              return String(courseId) === String(course.id);
            })[0];
            if (grade != null) {
              return grade.grade;
            } else {
              return -1;
            }
          }
        };
      })).concat([
        {
          name: 'معدل کل',
          key: 'gpa'
        }, {
          name: 'مطقع',
          key: 'degree'
        }, {
          name: 'در کارگاه آموزش دستیاران آموزشی شرکت کرده است',
          key: 'isTrained',
          styleTd: function(requestForAssistant, td, offs) {
            var checkbox;
            setStyle(td, {
              textAlign: 'center',
              text: ''
            });
            append(td, checkbox = E('input', {
              type: 'checkbox',
              checked: requestForAssistant.isTrained
            }));
            return offs.push(onEvent(checkbox, 'change', function() {
              return setStyle(checkbox, {
                checked: !checkbox.checked
              });
            }));
          }
        }, {
          name: 'پیام دانشجو',
          styleTd: function(requestForAssistant, td, offs) {
            var messageIcon, visible;
            setStyle(td, {
              textAlign: 'center'
            });
            if (message) {
              append(td, messageIcon = E({
                "class": 'fa fa-envelope'
              }));
              $(messageIcon).tooltip({
                html: true,
                placement: 'right',
                trigger: 'manual',
                template: '<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner" style="font-size: 15px"></div></div>',
                title: requestForAssistant.message.replace('\n', '<br />')
              });
              visible = false;
              offs.push(onEvent(E(body), 'mousemove', function(e) {
                var element;
                element = e.target;
                while (element !== E(body).fn.element && element !== td.fn.element) {
                  element = element.parentNode;
                }
                if (element === td.fn.element && !visible) {
                  $(messageIcon).tooltip('show');
                  visible = true;
                }
                if (element(isbt(td.fn.element && visible))) {
                  $(messageIcon).tooltip('hide');
                  return visible = false;
                }
              }));
              return offs.push(onMouseOut(null, function() {
                if (visible) {
                  $(messageIcon).tooltip('hide');
                }
                return visible = false;
              }));
            }
          }
        }
      ]).concat((offering.isClosed ? [] : [
        {
          name: 'تایید / رد',
          key: 'status',
          styleTd: function(requestForAssistant, td, offs) {
            var changeStatus;
            changeStatus = td;
            setStyle(changeStatus, {
              cursor: 'pointer'
            }, append(changeStatus, E({
              "class": 'btn btn-default',
              cursor: 'pointer'
            }, 'تایید / رد')));
            $(changeStatus).popover({
              title: 'تایید / رد',
              trigger: 'manual',
              html: true,
              container: 'body',
              content: (function() {
                var extras, showHideExtras;
                showHideExtras = function() {
                  if (requestForAssistant.status === 'تایید شده') {
                    return show(extras);
                  } else {
                    return hide(extras);
                  }
                };
                E({
                  "class": 'btn-group btn-group-xs'
                }, [
                  {
                    status: 'تایید شده',
                    klass: 'success'
                  }, {
                    status: 'رد شده',
                    klass: 'danger'
                  }, {
                    status: 'در حال بررسی',
                    klass: 'info'
                  }
                ].map(function(arg2) {
                  var button, klass, status;
                  status = arg2.status, klass = arg2.klass;
                  button = E('button', {
                    "class": 'btn btn-' + (status === requestForAssistant.status ? klass : 'default')
                  }, status);
                  onEvent(button, 'click', function(e) {
                    if (status !== 'تایید شده') {
                      requestForAssistant.chores = [];
                      requestForAssistant.isChiefTA = false;
                    }
                    extend(requestForAssistant, {
                      status: status
                    });
                    changeRequestForAssistant(requestForAssistant);
                    setStyle(td, {
                      text: status
                    });
                    return showHideExtras();
                  });
                  return button;
                }));
                return extras = [
                  E({
                    "class": 'checkbox'
                  }, E('label', null, (function() {
                    var checkbox;
                    checkbox = E('input', {
                      type: 'checkbox',
                      cursor: 'pointer',
                      checked: requestForAssistant.isChiefTA
                    });
                    onEvent(checkbox, 'change', function() {
                      if (requestForAssistant.isClosed) {
                        return setStyle(checkbox, {
                          checked: !checkbox.checked
                        });
                      }
                      requestForAssistant.isChiefTA = checkbox.checked;
                      return changeRequestForAssistant(requestForAssistant);
                    });
                    return checkbox;
                  })(), text('دستیار اصلی است.'))), E('span', {
                    fontWeight: 'bold'
                  }, 'وظایف:'), E({
                    "class": 'well well-sm'
                  }, chores.map(function(arg2) {
                    var id, persianName;
                    id = arg2.id, persianName = arg2.persianName;
                    return E({
                      "class": 'checkbox'
                    }, E('label', null, (function() {
                      var checkbox;
                      checkbox = E('input', {
                        type: 'checkbox',
                        cursor: 'pointer',
                        checked: requestForAssistant.chores.some(function(choreId) {
                          return String(choreId) === String(id);
                        })
                      });
                      onEvent(checkbox, 'change', function() {
                        if (requestForAssistant.isClosed) {
                          return setStyle(checkbox, {
                            checked: !checkbox.checked
                          });
                        }
                        remove(requestForAssistant.chores, id);
                        if (checkbox.checked) {
                          requestForAssistant.chores.push(id);
                        }
                        return changeRequestForAssistant(requestForAssistant);
                      });
                      return checkbox;
                    })(), text(persianName)));
                  }))
                ];
              })()
            });
            hidePopovers.push(function() {
              return $(changeStatus).popover('hide');
            });
            offs.push(onEvent(changeStatus, 'click', function() {
              return $(changeStatus).popover('show');
            }));
            return offs.push(onEvent(E(document), 'click', function(e) {
              var element;
              element = e.target;
              while (element !== null && element !== document.body) {
                if (element === changeStatus || ~((typeof element.getAttribute === "function" ? element.getAttribute('class') : void 0) || '').indexOf('popover')) {
                  return;
                }
                element = element.parentNode;
              }
              return $(changeStatus).popover('hide');
            }));
          }
        }
      ]))
    }));
    return tableInstance.setData(offering.requestForAssistants);
  };
  state.all(['courses', 'chores'], function(arg2) {
    var _chores, _courses;
    _courses = arg2[0], _chores = arg2[1];
    courses = _courses;
    chores = _chores;
    return update();
  });
  returnObject({
    update: function(_offering) {
      if (_offering.id === offering.id && JSON.stringify(_offering.requiredCourses) === JSON.stringify(offering.requiredCourses) && _offering.isClosed === offering.isClosed) {
        if (!popoverOpen) {
          tableInstance.setData(offering.requestForAssistants);
        }
        return;
      }
      offering = _offering;
      return update();
    }
  });
  return view;
});


},{"../../../components/table":17,"../../../utils/component":34,"../../../utils/dom":36}],78:[function(require,module,exports){
var compare, component, extend, modal, ref, requestForAssistant, searchBoxStyle, stateSyncedDropdown, table, textIsInSearch;

component = require('../../utils/component');

requestForAssistant = require('./requestForAssistant');

modal = require('../../singletons/modal');

table = require('../../components/table');

stateSyncedDropdown = require('../../components/dropdown/stateSynced');

searchBoxStyle = require('../../components/table/searchBoxStyle');

ref = require('../../utils'), extend = ref.extend, textIsInSearch = ref.textIsInSearch, compare = ref.compare;

module.exports = component('studentView', function(arg) {
  var E, courseNameInput, dom, events, hide, loading, noData, offeringsTable, onEvent, others, requestForAssistantPage, service, setStyle, setntTable, show, state, termDropdown, view, yesData, yourRequests;
  dom = arg.dom, events = arg.events, state = arg.state, service = arg.service, others = arg.others;
  E = dom.E, setStyle = dom.setStyle, show = dom.show, hide = dom.hide;
  onEvent = events.onEvent;
  loading = others.loading;
  service.getTerms();
  service.getOfferings();
  service.getCourses();
  service.getProfessors();
  service.getStudentRequestForAssistants();
  requestForAssistantPage = E(requestForAssistant);
  termDropdown = E(stateSyncedDropdown, {
    stateName: 'terms',
    selectedIdStateName: 'currentTerm'
  });
  termDropdown.showEmpty(true);
  setStyle(termDropdown, searchBoxStyle.font);
  setStyle(termDropdown.input, searchBoxStyle.input);
  courseNameInput = E('input', searchBoxStyle.textbox);
  courseNameInput = E('input', searchBoxStyle.textbox);
  view = [
    noData = E(null, 'در حال بارگزاری...'), yesData = E(null, E({
      marginTop: 30
    }, yourRequests = E({
      "class": 'panel panel-success'
    }, E({
      "class": 'panel-heading'
    }, E('h3', {
      "class": 'panel-title'
    }, 'درخواست‌های ارسال شده توسط شما در این ترم')), setntTable = table({
      headers: [
        {
          name: 'نام درس',
          key: 'courseName'
        }, {
          name: 'نام استاد',
          key: 'professorName'
        }
      ],
      hanlders: {
        select: function(offering) {
          return requestForAssistantPage.edit(offering);
        }
      }
    }))), E({
      "class": 'panel panel-info'
    }, E({
      "class": 'panel-heading'
    }, E('h3', {
      "class": 'panel-title'
    }, 'لیست فراخوان‌ها')), offeringsTable = table({
      headers: [
        {
          name: 'نام درس',
          key: 'courseName',
          searchBox: courseNameInput
        }, {
          name: 'نام استاد',
          key: 'professorName',
          searchBox: professorNameInput
        }, {
          name: 'ترم',
          key: 'termId',
          searchBox: searchBox,
          termDropdown: termDropdown
        }, {
          name: 'حذف',
          styleTd: function(offering, td, offs) {
            setStyle(td, {
              color: 'red',
              width: 100
            });
            return offs.push(onEvent(td, 'click', function() {
              return modal.instance.display({
                contents: E('p', null, " آیا از حذف این " + selectedEntities.length + " درخواست اطمینان دارید؟"),
                submitText: 'حذف',
                submitType: 'danger',
                closeText: 'انصراف',
                submit: function() {
                  tableInstance.cover();
                  service.deleteRequestForAssistants([offering.id]).fin(function() {
                    return tableInstance.uncover();
                  });
                  return modal.instance.hide();
                }
              });
            }));
          }
        }
      ],
      hanlders: {
        select: function(offering) {
          return requestForAssistantPage.send(offering);
        }
      }
    })))
  ];
  loading(['terms', 'offerings', 'courses', 'professors', 'requestForAssistants'], yesData, noData);
  state.all(['offerings', 'courses', 'professors', 'requestForAssistants'], function(arg1) {
    var courseName, courses, filteredOfferings, offerings, professorName, professors, requestForAssistants, sent, term;
    offerings = arg1[0], courses = arg1[1], professors = arg1[2], requestForAssistants = arg1[3];
    offerings = offerings.map(function(offering) {
      var ref1, ref2, ref3, ref4;
      return extend({}, offering, {
        courseName: (ref1 = (ref2 = (courses.filter(function(arg2) {
          var id;
          id = arg2.id;
          return String(id) === String(offering.courseId);
        }))[0]) != null ? ref2.name : void 0) != null ? ref1 : '',
        professorName: (ref3 = (ref4 = (professors.filter(function(arg2) {
          var id;
          id = arg2.id;
          return String(id) === String(offering.professorId);
        }))[0]) != null ? ref4.fullName : void 0) != null ? ref3 : '',
        requestForAssistant: (requestForAssistants.filter(function(arg2) {
          var offeringId;
          offeringId = arg2.offeringId;
          return String(offeringId) === String(offering.id);
        }))[0],
        requiredCourses: offering.requiredCourses.map(function(courseId) {
          var ref5, ref6;
          return {
            id: courseId,
            name: (ref5 = (ref6 = (courses.filter(function(arg2) {
              var id;
              id = arg2.id;
              return String(id) === String(courseId);
            }))[0]) != null ? ref6.name : void 0) != null ? ref5 : ''
          };
        })
      });
    });
    courseName = courseNameInput.value();
    professorName = professorNameInput.value();
    term = termDropdown.value();
    filteredOfferings = offerings.filter(function(arg2) {
      var isClosed, requestForAssistant;
      isClosed = arg2.isClosed, requestForAssistant = arg2.requestForAssistant;
      return !isClosed && !requestForAssistant;
    });
    if (courseName) {
      filteredOfferings = filteredOfferings.filter(function(offering) {
        return textIsInSearch(offering.courseName, courseName);
      });
    }
    if (professorName) {
      filteredOfferings = filteredOfferings.filter(function(offering) {
        return textIsInSearch(offering.professorName, professorName);
      });
    }
    if (~term) {
      filteredOfferings = filteredOfferings.filter(function(offering) {
        return textIsInSearch(offering.termId, term);
      });
    }
    offeringsTable.setData(filteredOfferings);
    setntTable.setData(sent = offerings.filter(function(arg2) {
      var requestForAssistant;
      requestForAssistant = arg2.requestForAssistant;
      return requestForAssistant;
    }));
    if (sent.length) {
      return show(yourRequests);
    } else {
      return hide(yourRequests);
    }
  });
  return view;
});


},{"../../components/dropdown/stateSynced":9,"../../components/table":17,"../../components/table/searchBoxStyle":18,"../../singletons/modal":33,"../../utils":38,"../../utils/component":34,"./requestForAssistant":79}],79:[function(require,module,exports){
var component, generateId, gradeInput, modal, toEnglish;

component = require('../../utils/component');

modal = require('../../singletons/modal');

gradeInput = require('../../components/restrictedInput/grade');

generateId = require('../../utils/dom').generateId;

toEnglish = require('../../utils').toEnglish;

module.exports = component('studentRequestForAssistant', function(arg) {
  var E, contents, display, dom, empty, gpa, gradeInputsPlaceholder, grades, ids, isTrained, message, ref, returnObject, service, setEnabled, setStyle, state, text;
  dom = arg.dom, state = arg.state, service = arg.service, returnObject = arg.returnObject;
  ref = require(dom), E = ref.E, text = ref.text, setStyle = ref.setStyle, empty = ref.empty;
  ids = [0, 1, 2].map(function() {
    return generateId();
  });
  gpa = E(gradeInput);
  setStyle(gpa, {
    id: ids[0],
    "class": 'form-control'
  });
  message = E('textarea', {
    id: ids[1],
    "class": 'form-control',
    minHeight: 100,
    minWidth: '100%',
    maxWidth: '100%'
  });
  isTrained = E('input', {
    id: ids[2],
    type: 'checkbox'
  });
  contents = [
    gradeInputsPlaceholder = E('span'), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[0]
    }, 'معدل کل'), gpa), E({
      "class": 'form-group'
    }, E('label', {
      "for": ids[1]
    }, 'پیام برای استاد (اختیاری)'), message), E({
      "class": 'checkbox'
    }, E('label', null, isTrained, text('در کارگاه آموزش دستیاران شرکت کرده‌ام')))
  ];
  grades = [];
  onEvent(gpa, ['input', 'pInput'], setEnabled = function() {
    return modal.instance.setEnabled(grades.concat([gpa]).every(function(x) {
      return x.value() && x.value().charAt(x.value.length - 1) !== '.';
    }));
  });
  onEnter([gpa, isTrained], function() {
    return modal.instance.submit();
  });
  display = function(isEdit) {
    return function(offering) {
      return state.all({
        allowNull: true,
        once: true
      }, ['grades', 'gpa', 'isTrained'], function(arg1) {
        var gpaValue, gradeValues, isTrainedValue, ref1, ref2, ref3, ref4;
        gradeValues = (ref1 = arg1[0]) != null ? ref1 : {}, gpaValue = arg1[1], isTrainedValue = arg1[2];
        grades = offering.requiredCourses.map(function(arg2) {
          var id, input, name;
          id = arg2.id, name = arg2.name;
          input = E(gradeInput);
          id = generateId();
          setStyle(input, {
            "class": 'form-control',
            value: offering.requestForAssistant ? (offering.requestForAssistant.grades.filter(function(arg3) {
              var courseId;
              courseId = arg3.courseId;
              return String(courseId) === String(id);
            }))[0].grade : gradeValues[id]
          });
          onEvent(input, ['input', 'pInput'], setEnabled);
          append(gradeInputsPlaceholder, E({
            "class": 'form-group'
          }, E('label', {
            "for": id
          }, "نمره درس " + name), input));
          return input;
        });
        setStyle(gpa, {
          value: ((ref2 = offering.requestForAssistant) != null ? ref2.gpa : void 0) || gpaValue
        });
        setStyle(message, {
          value: (ref3 = offering.requestForAssistant) != null ? ref3.message : void 0
        });
        setStyle(isTrained, {
          checked: ((ref4 = offering.requestForAssistant) != null ? ref4.isTrained : void 0) || isTrainedValue
        });
        return modal.instance.display({
          autoHide: true,
          title: "ثبت درخواست دستیاری برای درس " + offering.courseName,
          submitText: isEdit ? 'ویرایش درخواست' : 'ثبت',
          contents: contents,
          submit: function() {
            offering.requiredCourses.forEach(function(arg2, i) {
              var id;
              id = arg2.id;
              return gradeValues[id] = grades[i].value;
            });
            state.grades.set(gradeValues);
            state.gpa.set(gpa.value);
            state.isTrained.set(isTrained.checked);
            return service.sendRequestForAssistant({
              offeringId: offering.id,
              gpa: +toEnglish(gpa.value),
              grades: grades.map(function(grade, i) {
                return {
                  grade: +toEnglish(grade.value),
                  courseId: +offering.requiredCourses[i].id
                };
              }),
              isTrained: isTrained.checked,
              message: message.value
            });
          }
        });
      });
    };
  };
  return returnObject({
    send: display(false),
    edit: display(true)
  });
});


},{"../../components/restrictedInput/grade":13,"../../singletons/modal":33,"../../utils":38,"../../utils/component":34,"../../utils/dom":36}],80:[function(require,module,exports){
var Q, alertMessages, autoLoginQ, chooseGolestanNumber, includes, page, params, register, service, startQ, ticket;

Q = require('./q');

service = require('./utils/service');

page = require('./page');

includes = require('./includes');

alertMessages = require('./alertMessages');

register = require('./sheets/register');

chooseGolestanNumber = require('./sheets/chooseGolestanNumber');

Q.longStackSupport = true;

document.title = 'سامانه مدیریت دستیاران آموزشی';

params = location.href.split('?');

includes["do"]();

alertMessages["do"]();

autoLoginQ = params.length > 1 && params[1].indexOf('ticket=') === 0 ? (ticket = params[1].substr('ticket='.length), service.cas({
  ticket: ticket
}).then(function(golestanNumbers) {
  if (Array.isArray(golestanNumbers) && golestanNumbers.length) {
    if (golestanNumbers.length > 1) {
      return $(function() {
        return setTimeout(function() {
          return setTimeout(function() {
            return setTimeout(function() {
              return setTimeout(function() {
                return setTimeout(function() {
                  return chooseGolestanNumber.display(golestanNumbers);
                });
              });
            });
          });
        });
      });
    } else {
      return service.casLogin({
        golestanNumber: golestanNumbers[0]
      });
    }
  }
})) : void 0;

startQ = autoLoginQ ? autoLoginQ["catch"]((function() {})) : void 0;

Q(startQ).then(function() {
  service.autoPing();
  return service.getPerson();
}).then(function() {
  page();
  if (params.length > 1 && params[1].indexOf('email=') === 0) {
    params = params[1].split('&');
    if (params.length > 1 && (params[0].indexOf('email=') === 0) && (params[1].indexOf('verificationCode=') === 0)) {
      return $(function() {
        return setTimeout(function() {
          return setTimeout(function() {
            return setTimeout(function() {
              return setTimeout(function() {
                return setTimeout(function() {
                  return register.display();
                });
              });
            });
          });
        });
      });
    }
  }
}).done();


},{"./alertMessages":2,"./includes":20,"./page":27,"./q":28,"./sheets/chooseGolestanNumber":29,"./sheets/register":31,"./utils/service":44}]},{},[80]);
