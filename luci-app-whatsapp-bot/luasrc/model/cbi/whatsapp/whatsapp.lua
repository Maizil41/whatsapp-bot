local map = Map("whatsapp-bot", "")

local status_section = map:section(SimpleSection, "Status", "")
local status_value = status_section:option(DummyValue, "status", "")
status_value.rawhtml = true

-- Ambil status dari bot WhatsApp
local status_output = io.popen("pgrep -f 'node index.js'"):read("*a")

-- Cek apakah ada output dari pgrep
if status_output ~= "" then
    status_value.value = '<p><strong><span style="color:green;"><i>WhatsApp Bot RUNNING</i></span></strong></p>'
else
    status_value.value = '<p><strong><span style="color:red;"><i>WhatsApp Bot NOT RUNNING</i></span></strong></p>'
end

local sec = map:section(TypedSection, "whatsapp_bot", "Settings")
sec.addremove = false
sec.anonymous = true

local enabled = sec:option(Flag, "enabled", "Enabled")
enabled.default = 0
enabled.optional = false

local admin_number = sec:option(Value, "admin_number", "Nomor WhatsApp")
admin_number.default = ""
admin_number.description = "Ini adalah nomor Admin, (Bukan nomor Bot)"
admin_number.placeholder = "Enter your WhatsApp number (e.g. +6285372687484)"

local login_button = sec:option(DummyValue, "open_link", "Login WhatsApp")
login_button.rawhtml = true
login_button.value = [[<a href="http://192.168.1.1:3000/login" target="_blank" style="display: inline-block; padding: 8px 15px; background-color: #9a0e0e; color: white; text-decoration: none; border-radius: 4px;">Login</a>]]
login_button.description = "Klik untuk login ke whatsapp."

local send_message_button = sec:option(DummyValue, "open_link_send", "Kirim Pesan")
send_message_button.rawhtml = true
send_message_button.value = [[<a href="http://192.168.1.1:3000" target="_blank" style="display: inline-block; padding: 8px 15px; background-color: #0e9a17; color: white; text-decoration: none; border-radius: 4px;">Open</a>]]
send_message_button.description = "Klik untuk kirim pesan."

local apply = luci.http.formvalue("cbi.apply")
if apply then
    os.execute("/etc/init.d/whatsapp-bot restart >/dev/null 2>&1 &")
end

return map
