#!/usr/bin/env node

'use strict';

const repl = require('repl');
const util = require('util');
const fs = require('fs');
const path = require('path');

const program = require('commander');

const CDP = require('../');

function display(object) {
    return util.inspect(object, {
        'colors': process.stdout.isTTY,
        'depth': null
    });
}

function toJSON(object) {
    return JSON.stringify(object, null, 4);
}

function inheritProperties(from, to) {
    Object.keys(from).forEach(function (property) {
        to[property] = from[property];
    });
}

///

function inspect(target, args, options) {
    options.remote = args.remote;
    // otherwise the active target
    if (target) {
        if (args.webSocket) {
            // by WebSocket URL
            options.target = target;
        } else {
            // by target id
            options.target = function (targets) {
                return targets.findIndex(function (target) {
                    return target.id === target;
                });
            };
        }
    }

    if (args.protocol) {
        options.protocol = JSON.parse(fs.readFileSync(args.protocol));
    }

    CDP(options, function (client) {
        // keep track of registered events
        const registeredEvents = {};

        const cdpRepl = repl.start({
            'prompt': '\x1b[32m>>>\x1b[0m ',
            'ignoreUndefined': true,
            'writer': display
        });

        const homePath = process.env.HOME || process.env.USERPROFILE;
        const historyFile = path.join(homePath, '.cri_history');
        const historySize = 10000;

        function loadHistory() {
            // attempt to open the history file
            let fd;
            try {
                fd = fs.openSync(historyFile, 'r');
            } catch (err) {
                return; // no history file present
            }
            // populate the REPL history
            fs.readFileSync(fd, 'utf8')
                .split('\n')
                .filter(function (entry) {
                    return entry.trim();
                })
                .reverse() // to be compatible with repl.history files
                .forEach(function (entry) {
                    cdpRepl.history.push(entry);
                });
        }

        function saveHistory() {
            // only store the last chunk
            const entries = cdpRepl.history.slice(0, historySize).reverse().join('\n');
            fs.writeFileSync(historyFile, entries + '\n');
        }

        function overridePrompt(string) {
            // hack to get rid of the prompt (clean line and reposition cursor)
            console.log('\x1b[2K\x1b[G%s', string);
            cdpRepl.displayPrompt(true);
        }

        function overrideCommand(command) {
            // hard code a callback to display the result
            const override = function (params) {
                command(params, function (error, response) {
                    const repr = {};
                    repr[error ? 'error' : 'result'] = response;
                    overridePrompt(display(repr));
                });
            };
            // inherit the doc decorations
            inheritProperties(command, override);
            return override;
        }

        function overrideEvent(client, domainName, itemName) {
            const event = client[domainName][itemName];
            const eventName = domainName + '.' + itemName;
            // hard code a callback to display the event data
            const override = function (filter) {
                // remove all the listeners (just one actually) anyway
                client.removeAllListeners(eventName);
                const status = {};
                // a filter will always enable/update the listener
                if (!filter && registeredEvents[eventName]) {
                    delete registeredEvents[eventName];
                    status[eventName] = false;
                } else {
                    // use the filter (or true) as a status token
                    const statusToken = (filter ? filter.toString() : true);
                    status[eventName] = registeredEvents[eventName] = statusToken;
                    event(function (params) {
                        const repr = {};
                        if (filter) {
                            params = filter(params);
                        }
                        repr[eventName] = params;
                        overridePrompt(display(repr));
                    });
                }
                // show the registration status to the user
                return status;
            };
            // inherit the doc decorations
            inheritProperties(event, override);
            return override;
        }

        // enable history
        loadHistory();

        // disconnect on exit
        cdpRepl.on('exit', function () {
            console.log();
            client.close();
            saveHistory();
        });

        // exit on disconnection
        client.on('disconnect', function () {
            console.error('Disconnected.');
            saveHistory();
            process.exit(1);
        });

        // add protocol API
        client.protocol.domains.forEach(function (domainObject) {
            // walk the domain names
            const domainName = domainObject.domain;
            cdpRepl.context[domainName] = {};
            Object.keys(client[domainName]).forEach(function (itemName) {
                // walk the items in the domain and override commands and events
                let item = client[domainName][itemName];
                switch (item.category) {
                case 'command':
                    item = overrideCommand(item);
                    break;
                case 'event':
                    item = overrideEvent(client, domainName, itemName);
                    break;
                }
                cdpRepl.context[domainName][itemName] = item;
            });
        });
    }).on('error', function (err) {
        console.error('Cannot connect to remote endpoint:', err.toString());
    });
}

function list(options) {
    CDP.List(options, function (err, targets) {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
        console.log(toJSON(targets));
    });
}

function _new(url, options) {
    options.url = url;
    CDP.New(options, function (err, target) {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
        console.log(toJSON(target));
    });
}

function activate(args, options) {
    options.id = args;
    CDP.Activate(options, function (err) {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
    });
}

function close(args, options) {
    options.id = args;
    CDP.Close(options, function (err) {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
    });
}

function version(options) {
    CDP.Version(options, function (err, info) {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
        console.log(toJSON(info));
    });
}

function protocol(args, options) {
    options.remote = args.remote;
    CDP.Protocol(options, function (err, protocol) {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
        console.log(toJSON(protocol));
    });
}

///

let action;

program
    .option('-t, --host <host>', 'HTTP frontend host')
    .option('-p, --port <port>', 'HTTP frontend port')
    .option('-s, --secure', 'HTTPS/WSS frontend');

program
    .command('inspect [<target>]')
    .description('inspect a target (defaults to the first available target)')
    .option('-w, --web-socket', 'interpret <target> as a WebSocket URL instead of a target id')
    .option('-j, --protocol <file.json>', 'Chrome Debugging Protocol descriptor (overrides `--remote`)')
    .option('-r, --remote', 'Attempt to fetch the protocol descriptor remotely')
    .action(function (target, args) {
        action = inspect.bind(null, target, args);
    });

program
    .command('list')
    .description('list all the available targets/tabs')
    .action(function () {
        action = list;
    });

program
    .command('new [<url>]')
    .description('create a new target/tab')
    .action(function (url) {
        action = _new.bind(null, url);
    });

program
    .command('activate <id>')
    .description('activate a target/tab by id')
    .action(function (id) {
        action = activate.bind(null, id);
    });

program
    .command('close <id>')
    .description('close a target/tab by id')
    .action(function (id) {
        action = close.bind(null, id);
    });

program
    .command('version')
    .description('show the browser version')
    .action(function () {
        action = version;
    });

program
    .command('protocol')
    .description('show the currently available protocol descriptor')
    .option('-r, --remote', 'Attempt to fetch the protocol descriptor remotely')
    .action(function (args) {
        action = protocol.bind(null, args);
    });

program.parse(process.argv);

// common options
const options = {
    'host': program.host,
    'port': program.port,
    'secure': program.secure
};

if (action) {
    action(options);
} else {
    program.outputHelp();
    process.exit(1);
}
