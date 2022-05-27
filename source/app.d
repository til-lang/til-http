import std.net.curl;

import til.nodes;


extern (C) CommandsMap getCommands(Escopo escopo)
{
    CommandsMap commands;

    commands["get"] = new Command((string path, Context context)
    {
        string address = context.pop!string();
        auto content = get(address);
        return context.push(to!string(content));
    });
    commands["post"] = new Command((string path, Context context)
    {
        // http.post $url "header:value" [dict (json values) (goes here)]
        // (And form-encoded will work, eventually, but now today.)
        string address = context.pop!string();
        auto http = HTTP();

        while (context.size > context.inputSize)
        {
            // (header value)
            auto pair = context.pop!SimpleList();
            if (pair.items.length != 2)
            {
                return context.error(
                    "Headers arguments should be pairs of key / value",
                    ErrorCode.InvalidSyntax,
                    "http"
                );
            }
            auto key = pair.items[0].toString();
            auto value = pair.items[1].toString();
            http.addRequestHeader(key, value);
        }

        if (context.inputSize)
        {
            http.setPostData(context.pop!string(), "application/json");
        }

        auto content = post(address, [], http);
        return context.push(to!string(content));
    });

    return commands;
}
