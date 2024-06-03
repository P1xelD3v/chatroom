-- file://C:/Users/bramw/OneDrive/Desktop/chat.it

local BLACKLIST = {"fuck", "f*ck", "frick", "porn", "p*rn", "pussy", "loser", "h*tler", "hitler", "ni**er", "niger", "nigger", "nig*er", "ni*ger", "gay", "rape", "fucking", "f*cking", "fricking", "fuckin", "f*ckin", "raping", "r*pe", "r*ping", "hate", "penis", "nigga", "n*gga", "ni**a", "ni*ga", "nig*a", "niga", "n*ga"}

local VERIFIED_USERS = {"pixelfacts"}

local API_URL = "https://script.google.com/macros/s/AKfycbzRpETjssJQPY1bL96zgoiIUxw78n5yMOfk31ntpOv56cpAcaF_uh6J2uPRmhDb91M0/exec"
local MAX_MESSAGES = 7

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

function error(msg)
	get("success").set_content("")
	get("error").set_content(msg)
end

function success(msg)
	get("success").set_content(msg)
	get("error").set_content("")
end

local function formatTimestamp(ts)
    local year, month, day, hour, min, sec = ts:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    
    local formattedDate = string.format("%02d-%02d-%04d", day, month, year)
    local formattedTime = string.format("%02d:%02d:%02d", hour, min, sec)
    
    return formattedDate .. " " .. formattedTime
end

function refresh_messages(messages)
	for i, message in ipairs(messages) do
		local verified = false
		local username = messages[#messages-(i-1)][1]

		for index, verified_username in ipairs(VERIFIED_USERS) do
			if verified_username == username then
				verified = true
				break
			end
		end

		if verified then
			get("username".. tostring(MAX_MESSAGES - (i - 1))).set_content(username.. ' ✅')
		else
			get("username".. tostring(MAX_MESSAGES - (i - 1))).set_content(username)
		end

		get("message_text".. tostring(MAX_MESSAGES - (i - 1))).set_content(messages[#messages-(i-1)][2])
		
		local timestamp = messages[#messages-(i-1)][3]
		if timestamp ~= "" then
			get("timestamp".. tostring(MAX_MESSAGES - (i - 1))).set_content(formatTimestamp(timestamp))
		else
			get("timestamp".. tostring(MAX_MESSAGES - (i - 1))).set_content("")
		end
	end
end

function sendMessage()
	if account_username == "" then
		error("Please log in before sending a message!")
		return
	end
	local message = get("message_input").get_content()
	if message ~= "" then
		for index, word in ipairs(BLACKLIST) do
			if string.find(message, word) then
				error("Your message contain inappropriate language!")
				return
			end
		end

		success("Sent message.")

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
	success("Refreshed messages")
	update()
end)

function is_alphanumeric(str)
    return str:match("^%w+$") == str
end

get("register_btn").on_click(function()
	local username = get("username_input").get_content():lower()
	local password = get("password_input").get_content()

	if #username < MIN_USERNAME_LENGTH then
		error("The minimum username length is ".. tostring(MIN_USERNAME_LENGTH))
		return
	end
	if #username > MAX_USERNAME_LENGTH then
		error("The maximum username length is ".. tostring(MAX_USERNAME_LENGTH))
		return
	end

	if not is_alphanumeric(username) then
		error("Usernames can only contain letters and numbers!")
		return
	end


	if #password < MIN_PASSWORD_LENGTH then
		error("The minimum username length is ".. tostring(MIN_PASSWORD_LENGTH))
		return
	end
	if #password > MAX_PASSWORD_LENGTH then
		error("The maximum username length is ".. tostring(MAX_PASSWORD_LENGTH))
		return
	end

	if not is_alphanumeric(password) then
		error("Passwords can only contain letters and numbers!")
		return
	end


	if PULL("?type=doesUserExist&username="..username)[1] then
		error("Username '".. username .."' is taken!")
	else
		success("Account created.")
		POST('{"user": "'..username..'", "pass": "'..password..'"}')
		account_username = username
		get("current_account").set_content("Account: "..username)
	end
end)

get("login_btn").on_click(function()
	local username = get("username_input").get_content():lower()
	local password = get("password_input").get_content()

	if PULL("?type=isUserInfoCorrect&username="..username.."&password="..password)[1] then
		success("Logged into ".. username)
		account_username = username
		get("current_account").set_content("Account: "..username)
	else
		error("Username or Password is incorrect!")
	end
end)

update()