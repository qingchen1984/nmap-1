description = [[
Check if an XAMP or XAMPP FTP server uses a default username and password.

XAMP is an Apache distribution designed for easy installation and
administration.
]]

---
-- @output
-- 21/tcp  open   ftp
-- |_ xampp-default-auth: Login success with u/p: nobody/xampp

author = "Diman Todorov <diman.todorov@gmail.com>"

license = "Same as Nmap--See http://nmap.org/book/man-legal.html"

categories = {"auth", "vuln"}

require "shortport"

portrule = shortport.port_or_service(21, "ftp")

login = function(socket, user, pass)
	local status, err
	local res = ""
	status, err = socket:send("USER " .. user .. "\n")
	status, err = socket:send("PASS " .. pass .. "\n")

	-- consume the banner and stuff
	while true do
		status, res = socket:receive_lines(1)
		if 
			not string.match(res, "^220") 
			and not string.match(res, "^331 ") 
		then
			break
		end
	end

	-- are we logged in?
	if string.match(res, "^230") then
		return "Login success with u/p: " .. user .. "/" .. pass
	end
end

action = function(host, port)
	local res
	local socket = nmap.new_socket()

	socket:connect(host.ip, port.number)
	res = login(socket, "nobody", "e0e0e0e0")
	socket:close()

	socket:connect(host.ip, port.number)
	res = login(socket, "nobody", "xampp")
	socket:close()
	
	return  res
end
