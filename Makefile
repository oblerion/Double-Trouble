LUAWEB = dep/lua-5.4.2/lua_web
RAYLIBWEB = dep/raylib-5.0_webassembly
CCWEB = emcc

all:
	cd src && make
clean:
	cd src && make clean 	
web: *.ow
	$(shell cp dep/index.html .)
	$(CCWEB) -o index.js *.o -Os -Wall $(RAYLIBWEB)/lib/libraylib.a $(LUAWEB)/lib/liblua.a -I. -s USE_GLFW=3 -s ASYNCIFY -DPLATFORM_WEB --preload-file asset/*;
*.ow: 
	$(CCWEB) -c src/*.c -I$(RAYLIBWEB)/include -I$(LUAWEB)/include -I.
