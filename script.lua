-- file://C:/Users/bramw/OneDrive/Desktop/chat.it

local API_URL = "https://script.google.com/macros/s/AKfycby2Z4kKFwqvduQaeV49gTr6_ACtvHPqaBQQ-WrreRW-MSM70gHpYmB2tcCSZWH3kPh5/exec"
local MAX_MESSAGES = 10

local MIN_USERNAME_LENGTH = 4
local MAX_USERNAME_LENGTH = 16

local MIN_PASSWORD_LENGTH = 4
local MAX_PASSWORD_LENGTH = 32

local messages = {}
local account_username = ""

local latestMessageRecievedTimestamp = "none"

function PULL(params)
    local request = fetch({
		url = API_URL..params,
		method = "GET",
		headers = { ["Content-Type"] = "application/json" }
	})

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
	if account_username == "" then
		return
	end
	local message = get("message_input").get_content()
	if message ~= "" then
		get("message_input").set_content("")

		POST('{"user": "'..account_username..'", "text": "'..message..'"}')

		table.insert(messages, {account_username, message, ""})
		refresh_messages(messages)
	end
end

get("send_btn").on_click(function()
	sendMessage()
end)

get("message_input").on_submit(function()
	sendMessage()
end)

function update()
	local newMessages = PULL("?type=messages&latestMessageRecievedTimestamp="..latestMessageRecievedTimestamp.."&username="..account_username)

	latestMessageRecievedTimestamp = newMessages[1][3]

	for i, message in ipairs(newMessages) do
		table.insert(messages, newMessages[#newMessages-(i-1)])
	end

	refresh_messages(messages)
end

get("refresh_btn").on_click(function()
	update()
end)

function account_error_msg(msg)
	get("account_success").set_content("")
	get("account_error").set_content(msg)
end

function account_success_msg(msg)
	get("account_success").set_content(msg)
	get("account_error").set_content("")
end

function is_alphanumeric(str)
    return str:match("^%w+$") == str
end

get("register_btn").on_click(function()
	local username = get("username_input").get_content():lower()
	local password = get("password_input").get_content()

	if #username < MIN_USERNAME_LENGTH then
		account_error_msg("The minimum username length is ".. tostring(MIN_USERNAME_LENGTH))
		return
	end
	if #username > MAX_USERNAME_LENGTH then
		account_error_msg("The maximum username length is ".. tostring(MAX_USERNAME_LENGTH))
		return
	end

	if not is_alphanumeric(username) then
		account_error_msg("Usernames can only contain letters and numbers!")
		return
	end


	if #password < MIN_PASSWORD_LENGTH then
		account_error_msg("The minimum username length is ".. tostring(MIN_PASSWORD_LENGTH))
		return
	end
	if #password > MAX_PASSWORD_LENGTH then
		account_error_msg("The maximum username length is ".. tostring(MAX_PASSWORD_LENGTH))
		return
	end

	if not is_alphanumeric(password) then
		account_error_msg("Passwords can only contain letters and numbers!")
		return
	end


	if PULL("?type=doesUserExist&username="..username)[1] then
		account_error_msg("Username '".. username .."' is taken!")
	else
		account_success_msg("Account created.")
		POST('{"user": "'..username..'", "pass": "'..password..'"}')
		account_username = username
		get("current_account").set_content("Account: "..username)
	end
end)

get("login_btn").on_click(function()
	local username = get("username_input").get_content()
	local password = get("password_input").get_content()

	if PULL("?type=isUserInfoCorrect&username="..username:lower().."&password="..password)[1] then
		account_success_msg("Logged into ".. username)
		account_username = username
		get("current_account").set_content("Account: "..username)
	else
		account_error_msg("Username or Password is incorrect!")
	end
end)

update()