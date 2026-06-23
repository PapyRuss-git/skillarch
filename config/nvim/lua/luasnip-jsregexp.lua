local config_dir = vim.fn.stdpath("config")
local jsregexp_core_path = config_dir .. "/.deps/luasnip-jsregexp.so"
local jsregexp_lua_path = vim.fn.stdpath("data") .. "/lazy/LuaSnip/deps/jsregexp/jsregexp.lua"

local load_core = package.loadlib(jsregexp_core_path, "luaopen_jsregexp_core")
if not load_core then
  error("Unable to load jsregexp core from " .. jsregexp_core_path)
end

local previous_preload = package.preload["jsregexp.core"]
package.preload["jsregexp.core"] = load_core

local chunk, err = loadfile(jsregexp_lua_path)
if not chunk then
  package.preload["jsregexp.core"] = previous_preload
  error(err)
end

local ok, jsregexp = pcall(chunk)
package.preload["jsregexp.core"] = previous_preload

if not ok then
  error(jsregexp)
end

return jsregexp
