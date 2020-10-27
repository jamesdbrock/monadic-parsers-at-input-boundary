presentation.html: index.html | node_modules/.bin/inliner
	node_modules/.bin/inliner --nocompress index.html > presentation.html

node_modules/.bin/inliner:
	npm install -u inliner

.PHONY: start
start: | node_modules
	npm start

node_modules:
	npm install

