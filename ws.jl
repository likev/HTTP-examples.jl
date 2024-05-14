using HTTP
using HTTP.WebSockets

function new_add(ws)
    i = 0
    
    return function(timer)
        i += 1
        println(i)
        send(ws, i)
    end
end

#=
WebSockets.listen!("0.0.0.0", 8080) do ws
        t = Timer(new_add(ws), 1, interval=5)
end
=#

# Define the WebSocket handler
function websocket_handler(ws)
    println("WebSocket connection established")
    try
        t = Timer(new_add(ws), 1, interval=1)
        sleep(10)
        close(t)
    catch e
        println("WebSocket connection error: $e")
    finally
        println("WebSocket connection closed")
    end
end

# Define the static file handler
function static_file_handler(request)
    println(request.target)
    try
        # Assuming the static files are located in the "static" directory
        # Adjust the path according to your directory structure
        return HTTP.Response(200, read("static$(request.target)", String))
    catch e
        # return HTTP.Response(404, "File not found")

        return HTTP.Response(200, ["Content-Type" => "text/html"], read("index.html", String))
    end
end

# Start the server
HTTP.listen() do http::HTTP.Stream
    if HTTP.WebSockets.isupgrade(http.message)
        # Upgrade to WebSocket if the request is for the WebSocket endpoint
        return WebSockets.upgrade(websocket_handler, http)
    else
        # Serve static files for all other requests
        return HTTP.streamhandler(static_file_handler)(http)
    end
end