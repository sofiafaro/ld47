NAME=mouseherd
SRC=$(NAME).love
LOVE=dist/$(NAME).love

$(LOVE): $(SRC)/* $(SRC)/img/*
	cd $(SRC) && zip -9 -r ../$(LOVE) .

build-all: dist/$(NAME)-win64.zip dist/$(NAME)-win32.zip dist/$(NAME)-macos.zip

dist/$(NAME)-win64.zip: dist/$(NAME).love dist/love-win64
	rm -rf dist/$(NAME)-win64
	mkdir dist/$(NAME)-win64
	cp dist/love-win64/*.dll dist/$(NAME)-win64
	cp dist/love-win64/license.txt dist/$(NAME)-win64
	cat dist/love-win64/love.exe dist/$(NAME).love > dist/$(NAME)-win64/$(NAME).exe
	cd dist && zip -9 -r $(NAME)-win64.zip $(NAME)-win64
	rm -rf dist/$(NAME)-win64

dist/$(NAME)-win32.zip: dist/$(NAME).love dist/love-win32
	rm -rf dist/$(NAME)-win32
	mkdir dist/$(NAME)-win32
	cp dist/love-win32/*.dll dist/$(NAME)-win32
	cp dist/love-win32/license.txt dist/$(NAME)-win32
	cat dist/love-win32/love.exe dist/$(NAME).love > dist/$(NAME)-win32/$(NAME).exe
	cd dist && zip -9 -r $(NAME)-win32.zip $(NAME)-win32
	rm -rf dist/$(NAME)-win32

dist/$(NAME)-macos.zip: dist/$(NAME).love dist/love.app dist/icon.icns dist/Info.plist
	rm -rf dist/$(NAME).app
	cp -r dist/love.app dist/$(NAME).app
	cp dist/$(NAME).love dist/$(NAME).app/Contents/Resources/
	cp dist/icon.icns dist/$(NAME).app/Contents/Resources/"OS X AppIcon.icns"
	cp dist/Info.plist dist/$(NAME).app/Contents/
	cd dist && zip -9 -y -r $(NAME)-macos.zip $(NAME).app
