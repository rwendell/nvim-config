-- Restore the original init.lua but fix plugin loading
require("config.lazy")
require("config.autocmds")
require("config.keymaps")
require("config.options")