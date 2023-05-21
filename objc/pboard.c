#include <objc/NSObjCRuntime.h>
#include <objc/objc-runtime.h>

#include <lua/lua.h>
#include <lua/lauxlib.h>

extern id const NSPasteboardTypeString;

int set(lua_State *L) {
    const char *str = luaL_checkstring(L, 1);

    Class NSPasteboard = objc_getClass("NSPasteboard");
    id pboard = ((id (*)(Class, SEL))objc_msgSend)(NSPasteboard, sel_registerName("generalPasteboard"));

    ((void (*)(id, SEL))objc_msgSend)(pboard, sel_registerName("clearContents"));

    Class NSString = objc_getClass("NSString");
    id nsStr = ((id (*)(Class, SEL, const char *))objc_msgSend)(NSString, sel_registerName("stringWithUTF8String:"), str);

    ((bool (*)(id, SEL, id, id))objc_msgSend)(pboard, sel_registerName("setString:forType:"), nsStr, NSPasteboardTypeString);

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
