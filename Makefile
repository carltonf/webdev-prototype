VENDOR_MODULES :=
NODE_INTERNAL_MODULES :=
EXT_MODULES := ${VENDOR_MODULES} ${NODE_INTERNAL_MODULES}
PORT ?= 3000
APP_ENTRY := src/main.js
APP_SRCS := $(wildcard src/*.js)
TEST_SCRIPT := node_modules/node-skewer/public/skewer.js
APP_STYLE_ENTRY := src/main.scss
APP_STYLE_SRCS := $(wildcard src/*.css src/*.scss)

DIST_SRCS := index.html bundle/

.DELETE_ON_ERROR:

DIR_GUARD = @mkdir -pv $(@D)


CSS_BUNDLE_CMD := sassc
JS_BUNDLE_CMD := browserify
JS_COMPRESS_CMD :=

# * Dist flags setup
ifneq ($(MAKECMDGOALS),dist)
APP_ENTRY := ${APP_ENTRY} ${TEST_SCRIPT}
CSS_BUNDLE_CMD := ${CSS_BUNDLE_CMD} --sourcemap
JS_BUNDLE_CMD := ${JS_BUNDLE_CMD}  --debug
# dist flags
else
CSS_BUNDLE_CMD := ${CSS_BUNDLE_CMD} --style compressed
JS_COMPRESS_CMD := | uglifyjs - --compress
endif

.DEFAULT_GOAL := bundle

# * Build
bundle: bundle-vendor bundle-app

bundle-vendor: bundle/vendor.js
# list the node_module directories to rebuild the vendor bundle when these get
# updated.
bundle/vendor.js: ${VENDOR_MODULES:%=node_modules/%}
	@echo "** Bundling all vendor modules..."
	${DIR_GUARD}
	@${JS_BUNDLE_CMD} ${EXT_MODULES:%=-r %} ${JS_COMPRESS_CMD} > $@

# TODO optionally we have app modules?

bundle-app: bundle/app.js bundle/app.css
bundle/app.js: ${APP_SRCS}
	@echo "** Bundling all app scripts..."
	${DIR_GUARD}
	@${JS_BUNDLE_CMD} ${APP_ENTRY} ${EXT_MODULES:%=-x %} ${JS_COMPRESS_CMD} > $@
bundle/app.css: ${APP_STYLE_SRCS}
	@echo "** Bundling all app styles..."
	@${DIR_GUARD}
	@${CSS_BUNDLE_CMD} ${APP_STYLE_ENTRY} $@

# * Test
# reload to make sure the page is clear; sleep to make sure the SSE is established.
# TODO The time to wait feels hacky
test: reload test-bundle
	@sleep 1;
	@curl --silent --show-error						\
	  "${SSE_URL}/notify?cmd=loadScript&data=tools/test/init.js"


test-bundle: test-bundle-css test-bundle-js

test-bundle-css: bundle/test.css
test-bundle-js: bundle/test.js

TEST_PAGE_CSS_SRCS := tools/test/*.*css
bundle/test.css: ${TEST_PAGE_CSS_SRCS}
	@echo "** Bundling test page stylesheets..."
	${DIR_GUARD}
	@${CSS_BUNDLE_CMD} $< $@

TEST_PAGE_JS_SRCS := test/*.js
bundle/test.js: ${TEST_PAGE_JS_SRCS}
	@echo "** Bundling all test scripts..."
	${DIR_GUARD}
	@${JS_BUNDLE_CMD} $^ -o $@

# * Watch
WATCH_BUNDLE_ROOT = $(shell pwd)

# TODO broserify may change the atime of the source file (if it's changed since
# last browerifying) so watchman may run twice the command (which leads to some
# failure log....).
#
# NOTE: pass all necessary env to watchman as it would not copy current env.
define WATCH_BUNDLE_TRIGGER
["trigger", "${WATCH_BUNDLE_ROOT}", {
    "name": "make reload",
    "expression": ["anyof",
      ["match", "*.html"],
      ["match", "src/**/*.js", "wholename"],
      ["match", "src/**/*.*css", "wholename"]
    ],
    "command": [ "make", "reload", "PORT=${PORT}" ],
    "append_files": false
}]
endef
export WATCH_BUNDLE_TRIGGER
# TODO migrate watch to watch-project
# TODO currently I only know to visit the log file for log, a little inconvenient.
watch:
	@watchman watch $(shell pwd)
	@echo "$${WATCH_BUNDLE_TRIGGER}" | watchman -j

unwatch:
	watchman watch-del ${WATCH_BUNDLE_ROOT}

SSE_URL := http://localhost:${PORT}/node-skewer
reload: bundle
	@echo "** Reloading..."
	@curl --silent --show-error "${SSE_URL}/notify?cmd=reload"
# * Distribution
dist: clean bundle
	@echo "Build distribution package..."
	@mkdir -pv dist/
	@cp -rv ${DIST_SRCS} dist/

tarball: dist
	@echo "Bundling up tarbar..., currently nothing!"

# * Clean
RM := rm -rfv
clean:
	@${RM} bundle/*
	@${RM} dist/*
