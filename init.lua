wifi.setmode(wifi.STATION)
wifi.sta.config("*******","******")
print(wifi.sta.getip())
wifi.sta.sethostname("dadstatus")
print("Current hostname is: \""..wifi.sta.gethostname().."\"")
led1 = 8
led2 = 7
busyStatus = ""
freeStatus = ""
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        local _on,_off = "",""
        if(_GET.status == "Busy")then
              gpio.write(led1, gpio.HIGH);
              gpio.write(led2, gpio.LOW);
              currentStatus = "Busy"
        elseif(_GET.status == "Free")then
              gpio.write(led1, gpio.LOW);
              gpio.write(led2, gpio.HIGH);
              currentStatus = "Available"
        end
        buf = buf.."<!DOCTYPE html>"
        buf = buf.."<head> <title>Dad Status Control Panel</title></head>"
        buf = buf.."<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>"
        buf = buf.."<link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css' integrity='sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh' crossorigin='anonymous'>"
        buf = buf.."<body><div class='container'>"
        buf = buf.."<center><h2>Dad Status Control Panel</h2></center>"
        buf = buf.."<center>Update the Dad Status frame by toggling the below lights on/off</center>"
        buf = buf.."<br></br><form><center>"
        buf = buf.."Set your Dad Status:<br></br>"
        buf = buf.."<button class='btn btn-danger' name='status' value='Busy' type='submit'>Busy</button><br><br>"
        buf = buf.."<button class='btn btn-success' name='status' value='Free' type='submit'>Available</button><br></br>"
        buf = buf.."Current Status:<br></br>"
        buf = buf..""..currentStatus..""
        client:send(buf);
        client:close();
        collectgarbage();
    end)
    conn:on("sent", function(sck) sck:close() end)
end)
