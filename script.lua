local API_URL = "https://script.google.com/macros/s/AKfycbxo8V6upSRXkJQpAwx5J32Ty15kYRSayr5yP7Aqo0FXJDtHw7tIiI1exx4Bnr9ktdsM/exec"

get("message").set_content("Default Text Test")

function sendPostRequest(method)
    local res = fetch({
		url = API_URL,
		method = method,
		headers = { ["Content-Type"] = "application/json" },
	})

    return res
end

get("message").set_content(sendPostRequest("GET"))
get("message").set_content("non default text")