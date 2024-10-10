local map = Map("whatsapp-bot", "")

local status_section = map:section(SimpleSection, "Status", "")
local status_value = status_section:option(DummyValue, "status", "")
status_value.rawhtml = true

local status_output = io.popen("pgrep -f 'node index.js'"):read("*a")

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

local admin_number = sec:option(Value, "admin_number", "Nomor Admin")
admin_number.default = ""
admin_number.description = "Ini adalah nomor Admin, (Bukan nomor Bot)"

local login_button = sec:option(DummyValue, "open_link", "Action")
login_button.rawhtml = true

login_button.value = [[
    <div style="display: flex; gap: 10px;">
        <a id="login-link" href="#" target="_blank" style="display: inline-block; padding: 8px 15px; background-color: #9a0e0e; color: white; text-decoration: none; border-radius: 4px;">Login</a>
        <a id="message-link" href="#" target="_blank" style="display: inline-block; padding: 8px 15px; background-color: #0e9a17; color: white; text-decoration: none; border-radius: 4px;">Kirim Pesan</a>
        <button onclick="reloadWhatsapp()" style="padding: 8px 15px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">Restart Bot</button>
        <button onclick="resetNumber()" style="padding: 8px 15px; background-color: #f0ad4e; color: white; border: none; border-radius: 4px; cursor: pointer;">Reset Nomor Bot</button>
    </div>

    <script type="text/javascript">
        document.getElementById('login-link').href = 'http://' + window.location.hostname + ':3000/login';
        document.getElementById('message-link').href = 'http://' + window.location.hostname + ':3000';

        function reloadWhatsapp() {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", window.location.href, true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onload = function() {
                if (xhr.status === 200) {
                    location.reload();
                }
            };
            xhr.send("cbi.action=1");
        }
        function resetNumber() {
            var confirmation = confirm("Tindakan ini akan menghapus dan mereset nomor bot, Apakah anda yakin?");
            if (confirmation) {
                var xhr = new XMLHttpRequest();
                xhr.open("POST", window.location.href, true);
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                xhr.onload = function() {
                    if (xhr.status === 200) {
                        location.reload();
                    }
                };
                xhr.send("cbi.reset=1");
            } else {
                console.log("Reset dibatalkan");
            }
        }
    </script>
]]
login_button.description = ""

local action = luci.http.formvalue("cbi.action")
if action then
    os.execute("/etc/init.d/whatsapp-bot restart >/dev/null 2>&1 &")
end

local reset = luci.http.formvalue("cbi.reset")
if reset then
    os.execute("rm -rf /root/whatsapp-bot/auth_info >/dev/null 2>&1 &")
end

local apply = luci.http.formvalue("cbi.apply")
if apply then
    os.execute("/etc/init.d/whatsapp-bot reload >/dev/null 2>&1 &")
end

return map
