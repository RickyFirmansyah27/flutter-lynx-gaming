# Makefile for Flutter project

APP_NAME = LynxGaming
APP_VERSION = 1.0.0
PLATFORMS = android-arm64

.PHONY: run clean test build-release build-debug help

install:
	flutter pub get

clean:
	flutter clean

run:
	flutter run --enable-software-rendering

test:
	flutter run --debug

release:
	flutter build apk --release --target-platform=$(PLATFORMS)


## Tampilkan bantuan
help:
	@echo "🛠  Makefile Commands untuk ${APP_NAME}:"
	@echo ""
	@echo "  make run           - Jalankan aplikasi Flutter"
	@echo "  make clean         - Hapus semua file build"
	@echo "  make test          - Jalankan semua test"
	@echo "  make build-release - Build APK Release (ARM & ARM64)"
	@echo "  make build-debug   - Build APK Debug (ARM & ARM64)"
	@echo "  make help          - Tampilkan menu bantuan"
