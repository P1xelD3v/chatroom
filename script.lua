get("message").set_content("test_")

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

local socket = checkAndInstallLuaSocket()

get("message").set_content("test1")

local function startServer(port)
    local server = assert(socket.bind("*", port))
    local ip, port = server:getsockname()
    print("Server started on port " .. port)
    
    local clients = {}

    server:settimeout(0)

    while true do
        local client = server:accept()
        if client then
            client:settimeout(0)
            table.insert(clients, client)
        end

        for i, c in ipairs(clients) do
            local message, err = c:receive()
            if message then
                print("Received: " .. message)
                for j, cc in ipairs(clients) do
                    if i ~= j then
                        cc:send(message .. "\n")
                    end
                end
            elseif err == "closed" then
                table.remove(clients, i)
            end
        end

        socket.sleep(0.1)
    end
end

get("message").set_content("test2")

local function startClient(ip, port)
    local client = assert(socket.connect(ip, port))
    client:settimeout(0)
    print("Connected to server at " .. ip .. ":" .. port)

    local function receiveMessages()
        while true do
            local message, err = client:receive()
            if message then
                print("Received: " .. message)
            elseif err == "closed" then
                print("Connection closed")
                break
            end
            socket.sleep(0.1)
        end
    end

    local function sendMessages()
        while true do
            local input = io.read()
            if input then
                client:send(input .. "\n")
            end
        end
    end

    local co_receive = coroutine.create(receiveMessages)
    local co_send = coroutine.create(sendMessages)

    while coroutine.status(co_receive) ~= "dead" and coroutine.status(co_send) ~= "dead" do
        coroutine.resume(co_receive)
        coroutine.resume(co_send)
        socket.sleep(0.1)
    end
end

get("message").set_content("test3")

local port = 12345
local ip = "127.0.0.1"
local serverAvailable = true

local testClient = socket.tcp()
testClient:settimeout(2)
local result, err = testClient:connect(ip, port)
testClient:close()

get("message").set_content("test4")

if result == nil then
    get("message").set_content("No server found, starting as server...")
    print("No server found, starting as server...")
    serverAvailable = false
else
    get("message").set_content("Server found, connecting as client...")
    print("Server found, connecting as client...")
end

get("message").set_content("test5")

if serverAvailable then
    startClient(ip, port)
else
    startServer(port)
end

get("message").set_content("test6")