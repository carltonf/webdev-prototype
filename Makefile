VENDOR_MODULES := jquery underscore

bundle: bundle-vendor bundle-app

bundle-vendor: bundle/vendor.js
bundle/vendor.js: ${VENDOR_MODULES:%=node_modules/%}
	@echo "** Bundling all vendor modules..."
	@browserify ${VENDOR_MODULES:%=-r %} -o $@

# TODO optionally we have app modules?

APP_SRCS := src/*.js

bundle-app: bundle/app.js
bundle/app.js: ${APP_SRCS}
	@echo "** Bundling all app scripts..."
	@browserify $^ ${VENDOR_MODULES:%=-x %} -o $@

WATCH_BUNDLE_ROOT = $(shell pwd)

# NOTE: broserify may change the atime of the file (if it's changed since last
# browerifying) so watchman may run twice the command.
define WATCH_BUNDLE_TRIGGER
["trigger", "${WATCH_BUNDLE_ROOT}", {
    "name": "make bundle",
    "expression": ["allof", [ "dirname", "src" ], ["pcre", "^[^.].+js$$"]], 
    "command": [ "make", "bundle" ],
    "append_files": false
}]
endef
export WATCH_BUNDLE_TRIGGER
watch:
	@watchman watch $(shell pwd)
	@echo "$${WATCH_BUNDLE_TRIGGER}" | watchman -j

unwatch:
	watchman watch-del ${WATCH_BUNDLE_ROOT}

RM := rm -rfv
clean:
	@${RM} bundle/*