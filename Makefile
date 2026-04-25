SCHEME := AirSense
PROJECT := AirSense.xcodeproj
DESTINATION := platform=macOS
INSTALL_DEST := /Applications/AirSense.app

.PHONY: setup generate build test lint clean archive release dmg install

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
		CODE_SIGNING_ALLOWED=NO | xcbeautify || xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DESTINATION)' \
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
		CODE_SIGN_IDENTITY=- \
		CODE_SIGN_STYLE=Manual \
		DEVELOPMENT_TEAM="" \
		build
	mkdir -p build/Release
	cp -R build/DerivedData/Build/Products/Release/$(SCHEME).app build/Release/AirSense.app
	@echo "Built build/Release/AirSense.app"

dmg: archive
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

release: archive
	@VERSION=$$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' build/Release/AirSense.app/Contents/Info.plist); \
	cd build/Release && ditto -c -k --sequesterRsrc --keepParent AirSense.app AirSense-$$VERSION.zip && \
	echo "Packaged build/Release/AirSense-$$VERSION.zip"
