SCHEME := AirSense
PROJECT := AirSense.xcodeproj
DESTINATION := platform=macOS
INSTALL_DEST := /Applications/AirSense.app
SPARKLE_FEED_URL ?= https://akitory4.github.io/air-quality-widget-macos/appcast.xml
SPARKLE_PUBLIC_ED_KEY ?= 3tPOq5PVRyS7omJcqKzCxNiIvFRg81NPUZsTLvJ9j7c=

.PHONY: setup generate build test lint clean archive resign-release package-dmg package-zip appcast release release-with-appcast dmg install

setup:
	@command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
	@command -v swiftlint >/dev/null 2>&1 || brew install swiftlint
	$(MAKE) generate

generate:
	xcodegen generate

build:
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		SPARKLE_FEED_URL='$(SPARKLE_FEED_URL)' \
		SPARKLE_PUBLIC_ED_KEY='$(SPARKLE_PUBLIC_ED_KEY)' \
		CODE_SIGNING_ALLOWED=NO | xcbeautify || xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		SPARKLE_FEED_URL='$(SPARKLE_FEED_URL)' \
		SPARKLE_PUBLIC_ED_KEY='$(SPARKLE_PUBLIC_ED_KEY)' \
		CODE_SIGNING_ALLOWED=NO

test:
	xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
		CODE_SIGNING_ALLOWED=NO

lint:
	swiftlint --strict

clean:
	rm -rf build DerivedData $(PROJECT)

archive:
	rm -rf build/Release
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		-destination '$(DESTINATION)' \
		-derivedDataPath build/DerivedData \
		SPARKLE_FEED_URL='$(SPARKLE_FEED_URL)' \
		SPARKLE_PUBLIC_ED_KEY='$(SPARKLE_PUBLIC_ED_KEY)' \
		CODE_SIGN_IDENTITY=- \
		CODE_SIGN_STYLE=Manual \
		DEVELOPMENT_TEAM="" \
		build
	mkdir -p build/Release
	cp -R build/DerivedData/Build/Products/Release/$(SCHEME).app build/Release/AirSense.app
	$(MAKE) resign-release
	@echo "Built build/Release/AirSense.app"

resign-release:
	@test -d build/Release/AirSense.app || { echo "build/Release/AirSense.app not found. Run: make archive"; exit 1; }
	@mkdir -p build/Release/Signing
	@sed 's/$$(PRODUCT_BUNDLE_IDENTIFIER)/local.airqualitywidget/g' AirSense/Resources/AirSense.entitlements > build/Release/Signing/AirSense.entitlements
	@if [ -d build/Release/AirSense.app/Contents/Frameworks/Sparkle.framework ]; then \
		codesign --force --deep --sign - --options runtime --preserve-metadata=entitlements \
			build/Release/AirSense.app/Contents/Frameworks/Sparkle.framework; \
	fi
	@if [ -d build/Release/AirSense.app/Contents/PlugIns/AirSenseWidget.appex ]; then \
		codesign --force --sign - --options runtime \
			--entitlements AirSenseWidget/AirSenseWidget.entitlements \
			build/Release/AirSense.app/Contents/PlugIns/AirSenseWidget.appex; \
	fi
	codesign --force --sign - --options runtime \
		--entitlements build/Release/Signing/AirSense.entitlements \
		build/Release/AirSense.app
	codesign --verify --deep --strict --verbose=4 build/Release/AirSense.app

package-dmg:
	@test -d build/Release/AirSense.app || { echo "build/Release/AirSense.app not found. Run: make archive"; exit 1; }
	@command -v create-dmg >/dev/null 2>&1 || { echo "create-dmg not installed. Run: brew install create-dmg"; exit 1; }
	@VERSION=$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' build/Release/AirSense.app/Contents/Info.plist); \
	OUT=build/Release/AirSense-$$VERSION.dmg; \
	rm -f "$$OUT"; \
	create-dmg \
		--volname "AirSense $$VERSION" \
		--window-size 540 360 \
		--icon-size 96 \
		--icon "AirSense.app" 140 180 \
		--app-drop-link 400 180 \
		--hide-extension "AirSense.app" \
		--no-internet-enable \
		"$$OUT" \
		build/Release/AirSense.app && \
	echo "Packaged $$OUT"

dmg: archive package-dmg

install: archive
	@echo "-- stopping running instance"
	@pkill -x AirSense 2>/dev/null || true
	@pkill -x AirQualityWidget 2>/dev/null || true
	@pkill -x AirSenseWidget 2>/dev/null || true
	@sleep 1
	@echo "-- swapping $(INSTALL_DEST)"
	@rm -rf "$(INSTALL_DEST)"
	@cp -R build/Release/AirSense.app "$(INSTALL_DEST)"
	@codesign --verify --deep --strict "$(INSTALL_DEST)" || \
		{ echo "!! codesign verify failed — bundle is broken"; exit 1; }
	@echo "-- re-registering with LaunchServices"
	@/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
		-f "$(INSTALL_DEST)" >/dev/null 2>&1 || true
	@echo "-- refreshing chronod + SystemUIServer"
	@killall chronod 2>/dev/null || true
	@killall SystemUIServer 2>/dev/null || true
	@sleep 1
	@echo "-- launching"
	@open "$(INSTALL_DEST)"
	@sleep 2
	@echo "-- done. Open Notification Center → Edit Widgets to see the widget."

package-zip:
	@test -d build/Release/AirSense.app || { echo "build/Release/AirSense.app not found. Run: make archive"; exit 1; }
	@VERSION=$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' build/Release/AirSense.app/Contents/Info.plist); \
	cd build/Release && ditto -c -k --sequesterRsrc --keepParent AirSense.app AirSense-$$VERSION.zip && \
	echo "Packaged build/Release/AirSense-$$VERSION.zip"

appcast: package-zip
	scripts/generate_appcast.sh

release: archive package-zip

release-with-appcast:
	@test -n "$(SPARKLE_PUBLIC_ED_KEY)" || { echo "SPARKLE_PUBLIC_ED_KEY is required for auto-update release builds."; exit 1; }
	$(MAKE) release SPARKLE_FEED_URL='$(SPARKLE_FEED_URL)' SPARKLE_PUBLIC_ED_KEY='$(SPARKLE_PUBLIC_ED_KEY)'
	scripts/generate_appcast.sh
