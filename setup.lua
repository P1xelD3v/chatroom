local function installLuarocks()
    print("LuaSocket not found. Attempting to install via LuaRocks...")

    local install_cmd = 'luarocks install luasocket'
    local result = os.execute(install_cmd)

    if result == 0 then
        print("LuaSocket installed successfully.")
    else
        print("Failed to install LuaSocket. Please install it manually.")
        os.exit(1)
    end
end

local function checkAndInstallLuaSocket()
    local status, socket = pcall(require, "socket")
    if not status then
        installLuarocks()
        socket = require("socket")
    end
    return socket
end

return checkAndInstallLuaSocket()