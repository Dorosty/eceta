{addPageCSS, addPageStyle} = require './utils/dom'

exports.do = ->
  addPageCSS 'font-awesome/css/font-awesome.css'
  addPageCSS 'bootstrap.css'
  addPageCSS 'bootstrap-rtl.css'
  addPageStyle "
    @font-face {
      font-family: 'yekan';
      src: url('assets/yekan/yekan.ttf'),
           url('assets/yekan/yekan.woff'),
           url('assets/yekan/yekan.eot');
    }
    * {
      direction: rtl;
      -webkit-user-select: none; /* Chrome/Safari */        
      -moz-user-select: none; /* Firefox */
      -ms-user-select: none; /* IE10+ */
      -o-user-select: none;
      user-select: none;
      cursor: default;
    }
    input, textarea {
      cursor: text;
    }
    input[type='checkbox'] {
      cursor: pointer;
    }
    body {
      font-family: 'yekan', tahoma;
      height: 100%;
      overflow-x: hidden;
    }
    .hidden {
      display: 'none';
    }
    .alert {
      padding: 0;
      margin-bottom: 0;
      height: 0;
      transition: all .15s linear
    }
    .alert.in {
      padding: 15px;
      margin-bottom: 20px;
      height: auto;
    }
  "