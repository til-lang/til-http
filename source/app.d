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

    return commands;
}
