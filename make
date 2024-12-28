#!/bin/bash
BIN="double-trouble"
DSRC="src/"
LUA=0
LINUXSTAT=1 # 1 static build, 0 not
LUALINUX="dep/lua-5.4.2/lua_linux"
LUAWIN="dep/lua-5.4.2/lua_win"
LUAWEB="dep/lua-5.4.2/lua_web"
RAYLIBLIN="dep/raylib-5.5_linux_amd64"
RAYLIBWIN="dep/raylib-5.5_win32_mingw-w64"
RAYLIBWEB="dep/raylib-5.0_webassembly"
if [ $LINUXSTAT -eq 1 ];then
	RAYLIBLIN="dep/raylib-5.5_linux_amd64_stat"
fi
CC=gcc
if [ -f "src/main.cpp" ];then
	CC=g++
fi
CFLAGS="-g -Wall -L${RAYLIBLIN}/lib -lraylib -lGL -lm -lpthread -ldl -lrt -lX11"
if [ $LUA == 1 ];then
	CFLAGS="${CFLAGS} -L${LUALINUX}/lib -llua"
fi
INC="-I../${RAYLIBLIN}/include"
if [ $LUA == 1 ];then
	INC="$INC -I../${LUALINUX}/include"
fi
EXEC=$BIN
DOBJ="build/linux64/"


CC2=i686-w64-mingw32-gcc
CFLAGS2="-g -Wall -lm -L${RAYLIBWIN}/lib -lraylib -lopengl32 -lgdi32 -lwinmm -mwindows -static-libgcc" 
if [ $LUA == 1 ];then
	CFLAGS2="${CFLAGS2} -L${LUAWIN}/lib -llua"
fi
if [ -f "src/main.cpp" ];then
	CC2=i686-w64-mingw32-g++
	CFLAGS2="-g -Wall -lm -L${LUAWIN}/lib -llua -L${RAYLIBWIN}/lib -lraylib -lopengl32 -lgdi32 -lwinmm -mwindows -static-libgcc -static-libstdc++" 
fi
#-static-libstdc++ -static-libgcc"
INC2="-I../${RAYLIBWIN}/include"
if [ $LUA == 1 ];then
	INC2="$INC2 -I../${LUAWIN}/include"
fi
# -I/usr/i696-w64-mingw32/include"
EXEC2="$BIN.exe"
DOBJ2="build/win86/"

TCC="";
TCFLAGS="";
TINC="";
TEXEC="";
TLINK=" ";
TDOBJ=" ";

function init()
{
	TCC="$1";#compilo
	TINC="$2";#inlcude dir
	TCFLAGS="$3";#flag/ lib dir
	TEXEC="$4";#out exec
	TDOBJ="$5";#obj dir 
}
function comp(){
	local out;

	if [ -f "src/main.c" ];then
		cd $DSRC
		for i in *.c ;do
			out="$TDOBJ${i:0:-2}.o"
			rm -f $out;
			echo rm -f $out;
			command $TCC -c $i $TINC -g -Wall -o ../$out;
			echo $TCC -c $i $TINC -o ../$out;
			TLINK="$TLINK $out";
		done
	elif [ -f "src/main.cpp" ];then
		cd $DSRC
		for i in *.c ;do
			out="$TDOBJ${i:0:-2}.o"
			rm -f $out;
			echo rm -f $out;
			command $TCC -c $i $TINC -g -Wall -o ../$out;
			echo $TCC -c $i $TINC -o ../$out;
			TLINK="$TLINK $out";
		done
		for i in *.cpp ;do
			out="$TDOBJ${i:0:-4}.o"
			rm -f $out;
			echo rm -f $out;
			command $TCC -c $i $TINC -g -Wall -o ../$out;
			echo $TCC -c $i $TINC -o ../$out;
			TLINK="$TLINK $out";
		done
	fi
	cd ..
}
function link(){
	if [ -f $TEXEC ];then
		rm $TEXEC
	fi
	command $TCC $TLINK $TCFLAGS "-o" $TEXEC; 
	echo $TCC $TLINK $TCFLAGS "-o" $TEXEC; 
	if [ -f $EXEC ];then
		command ./$TEXEC;
	else 
		echo " "
		echo "[[ compile error ]]"
	fi;
}

OS="`uname`";
if [ $# -eq 0 ];then 
	if [ $OS == "Linux" ];then
	# default linux ./make
		rm -f $TEXEC;
		init "$CC" "$INC" "$CFLAGS" "$EXEC" "$DOBJ";
		comp;
		link;
	fi
	if [ $OS == "Windows" ];then
	# default window ./make
		rm -f $EXEC2;
		init "$CC" "$INC2" "$CFLAGS2" "$EXEC2" "$DOBJ2";
		comp;
		link;
	fi
elif [ "$1" == "w" ];then
# linux to window ./make w
	init "$CC2" "$INC2" "$CFLAGS2" "$EXEC2" "$DOBJ2";
	comp;
	link;
elif [ "$1" == "web" ];then
	DEXEC="build/web"
	for n in $DEXEC/* ;do
		if [ $n != "$DEXEC/favicon.ico" ] && [ $n != "$DEXEC/index.html" ];then
			rm -f $n
		fi
	done
# can craft with void ./asset dir
	if [ -f "src/main.cpp" ];then
		cd src;
		for i in "*.cpp" ;do
			em++ -c $i -I$RAYLIBWEB/include -Isrc;
			#echo $TCC -c $i -I../include;
		done;
		cd ..;
		em++ -o build/web/index.js src/*.o -Os -Wall $RAYLIBWEB/lib/libraylib.a -I. -Iinclude -L. -Llib -s USE_GLFW=3 -s ASYNCIFY -DPLATFORM_WEB --preload-file ./asset;
		# echo "$TCC -o build/web/index.js src/*.o -Os -Wall $RAYLIBWEB/lib/libraylib.a -I. -Iinclude -L. -Llib -s USE_GLFW=3 -s ASYNCIFY -DPLATFORM_WEB --preload-file ./asset"
	elif [ -f "src/main.c" ];then
		cd src;
		for i in "*.c" ;do
			emcc -c $i -I../$RAYLIBWEB/include -I../$LUAWEB/include -Isrc;
			#echo $TCC -c $i -I../include;
		done;
		cd ..;
		emcc -o build/web/index.js src/*.o -Os -Wall $RAYLIBWEB/lib/libraylib.a $LUAWEB/lib/liblua.a -I. -Iinclude -L. -Llib -s USE_GLFW=3 -s ASYNCIFY -DPLATFORM_WEB --preload-file ./asset;
		echo "emcc -o build/web/index.js src/*.o -Os -Wall $RAYLIBWEB/lib/raylib.a -I. -Iinclude -L. -Llib -s USE_GLFW=3 -s ASYNCIFY -DPLATFORM_WEB --preload-file ./asset";
	fi

	if [ "$2" = "z" ]; then
		cd build/web;
		zip -o ../index.zip *
	fi
fi
