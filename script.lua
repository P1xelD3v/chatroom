-- file://C:/Users/bramw/OneDrive/Desktop/chat.it

local API_URL = "https://script.google.com/macros/s/AKfycbwx8f1GZlZYbhLcAWyQT8Lk7_Y4WNZzUXD-MEn75NuxCZk48cCf8doK2A-3S1ABo50o/exec"
local MAX_MESSAGES = 10

local messages = {}
local username = "l boz"

local latestMessageRecievedTimestamp = "2024-05-19T12:41:46.165Z" --"none"

function PULL(params)
    local request = fetch({
		url = API_URL..params,
		method = "GET",
		headers = { ["Content-Type"] = "application/json" }
	})

	latestMessageRecievedTimestamp = request[1][3]

    return request
end

function POST(body)
	coroutine.wrap(function()
    	local request = fetch({
			url = API_URL,
			method = "POST",
			headers = { ["Content-Type"] = "application/json" },
        	body = body
		})
	end)()
end

function refresh_messages(messages)
	for i, message in ipairs(messages) do
		get("username".. tostring(MAX_MESSAGES - (i - 1))).set_content(messages[#messages-(i-1)][1])
		get("message_text".. tostring(MAX_MESSAGES - (i - 1))).set_content(messages[#messages-(i-1)][2])
	end
end

function sendMessage()
	local message = get("message_input").get_content()
	if message ~= "" then
		get("message_input").set_content("")

		POST('{"user": "'..username..'", "text": "'..message..'"}')

		table.insert(messages, {username, message, ""})
		refresh_messages(messages)
	end
end

get("send_btn").on_click(function()
	sendMessage()
end)

get("message_input").on_submit(function()
	sendMessage()
end)

get("refresh_btn").on_click(function()
	local newMessages = PULL("?type=messages&latestMessageRecievedTimestamp="..latestMessageRecievedTimestamp.."&username="..username)

	for i, message in ipairs(newMessages) do
		table.insert(messages, 1, message)
	end

	refresh_messages(messages)
end)

get("login_btn").on_click(function()
	local user = get("username_input").get_content()
	local pass = get("password_input").get_content()

    POST('{"user": "'..user:lower()..'", "pass": "'..pass..'"}')
end)

get("register_btn").on_click(function()
	local username = get("username_input").get_content()
	local password = get("password_input").get_content()

	local request = PULL("?type=accountInfo&username="..username)
	get("password_input").set_content(request[2])
end)