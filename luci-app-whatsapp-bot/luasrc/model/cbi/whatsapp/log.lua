local map = Map("whatsapp-bot", "")

local status_section = map:section(SimpleSection, "Logs", "")
local status_value = status_section:option(DummyValue, "log_output", "")
status_value.rawhtml = true

local reset_button = status_section:option(DummyValue, "open_link", "")
reset_button.rawhtml = true

reset_button.value = [[
    <div style="display: flex; gap: 10px;">
        <button onclick="resetLog()" style="padding: 8px 15px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">Hapus Log</button>
    </div>

    <script type="text/javascript">
        function resetLog() {
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
    </script>
]]

local action = luci.http.formvalue("cbi.action")
if action then
    os.execute("echo -n > /tmp/log/whatsapp.log")
end

local log_file = "/tmp/log/whatsapp.log"
local handle = io.open(log_file, "r")
local log_output = handle and handle:read("*all") or ""
if handle then
    handle:close()
end

status_value.value = [[
    <style>
        .log-output {
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid #ccc;
            padding: 10px;
            background-color: #f9f9f9;
            white-space: pre-wrap;
        }
    </style>
    <div class="log-output">]] .. (log_output or "") .. [[</div>
]]

return map
