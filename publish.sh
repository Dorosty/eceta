#!/bin/bash
browserify -t coffeeify --extension=".coffee" ./client > ./client/assets/scripts.js
uglifyjs ./client/assets/scripts.js -o ./client/assets/scripts.js
coffee -c ./server/*.coffee
cd server
sudo forever stopall
sudo forever start index.js
