import std.net.curl;

import til.nodes;


struct ret
{
    HTTP http;
    Context context;
}


auto getHttp(Context context)
{
    auto http = HTTP();

    // Headers:
    while (context.size > context.inputSize)
    {
        // (header value)
        auto pair = context.pop!SimpleList();
        auto returnedContext = pair.evaluate(context, true);
        pair = returnedContext.pop!SimpleList();

        if (pair.items.length != 2)
        {
            return ret(http, context.error(
                "Headers arguments should be pairs of key / value",
                ErrorCode.InvalidSyntax,
                "http"
            ));
        }
        auto key = pair.items[0].toString();
        auto value = pair.items[1].toString();
        http.addRequestHeader(key, value);
    }

    // Body:
    if (context.inputSize)
    {
        http.setPostData(context.pop!string(), "application/json");
    }
    else
    {
        http.setPostData(null, "application/json");
    }

    return ret(http, context);
}


extern (C) CommandsMap getCommands(Escopo escopo)
{
    CommandsMap commands;

    commands["get"] = new Command((string path, Context context)
    {
        string address = context.pop!string();
        ret r = getHttp(context);
        if (r.context.exitCode == ExitCode.Failure)
        {
            return context;
        }

        auto content = get(address, r.http);
        return r.context.push(to!string(content));
    });
    commands["post"] = new Command((string path, Context context)
    {
        // http.post $url "header:value" [dict (json values) (goes here)]
        // (And form-encoded will work, eventually, but now today.)
        string address = context.pop!string();

        ret r = getHttp(context);
        if (r.context.exitCode == ExitCode.Failure)
        {
            return context;
        }

        auto content = post(address, [], r.http);
        auto s = to!string(content);

        return r.context.push(s);
    });

    return commands;
}
