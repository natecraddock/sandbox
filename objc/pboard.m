#import <Cocoa/Cocoa.h>

#include <lua/lua.h>
#include <lua/lauxlib.h>

int set(lua_State *L) {
    const char *str = luaL_checkstring(L, 1);

    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard clearContents];
    [pboard setString:[NSString stringWithCString:str encoding:NSUTF8StringEncoding]
            forType:NSPasteboardTypeString];

    return 0;
}

const luaL_Reg fns[] = {
    { "set", set },
    { NULL, NULL },
};

int luaopen_pboard(lua_State *L) {
    luaL_newlib(L, fns);
    return 1;
}
