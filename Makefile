GEMS=sass
NODE_PACKAGES=express socket.io underscore crypto redis nodemon uglify-js
SASS_FILES=sass/combined.scss sass/main.scss sass/monokai.scss
PUBLIC_DIR=server/public
BUILD_DIR=build
SANDBOX_USERNAME=sandbox

#  !! order is important in the client libs !!
LIBS=client/lib/underscore-min.js client/lib/jquery.min.js client/lib/jquery.cookie.js client/lib/moment.min.js
CLIENT_JS=client/lib/codemirror-3.11/lib/codemirror.js client/lib/codemirror-3.11/mode/javascript/javascript.js client/client.js client/regex.js client/ui.js


.PHONY: server install_packages assets clean

all: client

server: server/main.js
	nodemon server/main.js

install_packages:
	npm install $(NODE_PACKAGES) && gem install $(GEMS)


.libs: $(LIBS)
	mkdir -p $(BUILD_DIR)
	cat $(LIBS) > $(BUILD_DIR)/libs.js
	uglifyjs $(BUILD_DIR)/libs.js > $(BUILD_DIR)/libs.min.js
	cp $(BUILD_DIR)/libs.min.js $(PUBLIC_DIR)/libs.min.js
	touch .libs

.js: $(CLIENT_JS)
	mkdir -p $(BUILD_DIR)
	cat $(CLIENT_JS) > $(BUILD_DIR)/yasioc.js
	uglifyjs $(BUILD_DIR)/yasioc.js > $(BUILD_DIR)/yasioc.min.js
	cp $(BUILD_DIR)/yasioc.min.js $(PUBLIC_DIR)/yasioc.min.js
	touch .js

.css: $(SASS_FILES)
	mkdir -p $(PUBLIC_DIR)/css 
	sass --style compressed sass/combined.scss:$(PUBLIC_DIR)/css/main.css
	touch .css

client: .libs .js .css

dangerzone:
	echo 'Creating a new user account with disabled login named ' $(SANDBOX_USERNAME)
	sudo adduser --disable-login --gecos 'Sandbox' $(SANDBOX_USERNAME)
	mkdir -p $(PUBLIC_DIR)/sandbox
	echo 'Allowing $(SANDBOX_USERNAME) user access to ' $(PUBLIC_DIR)/sandbox
	chown -R :sandbox $(PUBLIC_DIR)/sandbox
	chmod -R g+rw $(PUBLIC_DIR)/sandbox
	echo 'If you want to run phantomjs-screenshotter, you must now run sudo make server.'

clean:
	rm .libs
	rm .js
	rm .css
	rm $(PUBLIC_DIR)/css/*.css
	rm -rf $(BUILD_DIR)