#!/usr/bin/env node

'use strict';

const repl = require('repl');
const util = require('util');
const fs = require('fs');
const path = require('path');

const program = require('commander');

const CDP = require('../');
const packageInfo = require('../package.json');

function display(object) {
    return util.inspect(object, {
        colors: process.stdout.isTTY,
        depth: null
    });
}

function toJSON(object) {
    return JSON.stringify(object, null, 4);
}

///

function inspect(target, args, options) {
    options.local = args.local;
    // otherwise the active target
    if (target) {
        if (args.webSocket) {
            // by WebSocket URL
            options.target = target;
        } else {
            // by target id
            options.target = (targets) => {
                return targets.findIndex((_target) => {
                    return _target.id === target;
                });
            };
        }
    }

    if (args.protocol) {
        options.protocol = JSON.parse(fs.readFileSync(args.protocol));
    }

    CDP(options, (client) => {
        const cdpRepl = repl.start({
            prompt: process.stdin.isTTY ? '\x1b[32m>>>\x1b[0m ' : '',
            ignoreUndefined: true,
            writer: display
        });

        // XXX always await promises on the REPL
        const defaultEval = cdpRepl.eval;
        cdpRepl.eval = (cmd, context, filename, callback) => {
            defaultEval(cmd, context, filename, async (err, result) => {
                if (err) {
                    // propagate errors from the eval
                    callback(err);
                } else {
                    // awaits the promise and either return result or error
                    try {
                        callback(null, await Promise.resolve(result));
                    } catch (err) {
                        callback(err);
                    }
                }
            });
        };

        const homePath = process.env.HOME || process.env.USERPROFILE;
        const historyFile = path.join(homePath, '.cri_history');
        const historySize = 10000;

        function loadHistory() {
            // only if run from a terminal
            if (!process.stdin.isTTY) {
                return;
            }
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
                .filter((entry) => {
                    return entry.trim();
                })
                .reverse() // to be compatible with repl.history files
                .forEach((entry) => {
                    cdpRepl.history.push(entry);
                });
        }

        function saveHistory() {
            // only if run from a terminal
            if (!process.stdin.isTTY) {
                return;
            }
            // only store the last chunk
            const entries = cdpRepl.history.slice(0, historySize).reverse().join('\n');
            fs.writeFileSync(historyFile, entries + '\n');
        }

        // utility custom command
        cdpRepl.defineCommand('target', {
            help: 'Display the current target',
            action: () => {
                console.log(client.webSocketUrl);
                cdpRepl.displayPrompt();
            }
        });

        // utility to purge all the event handlers
        cdpRepl.defineCommand('reset', {
            help: 'Remove all the registered event handlers',
            action: () => {
                client.removeAllListeners();
                cdpRepl.displayPrompt();
            }
        });

        // enable history
        loadHistory();

        // disconnect on exit
        cdpRepl.on('exit', () => {
            if (process.stdin.isTTY) {
                console.log();
            }
            client.close();
            saveHistory();
        });

        // exit on disconnection
        client.on('disconnect', () => {
            console.error('Disconnected.');
            saveHistory();
            process.exit(1);
        });

        // add protocol API
        for (const domainObject of client.protocol.domains) {
            // walk the domain names
            const domainName = domainObject.domain;
            cdpRepl.context[domainName] = {};
            // walk the items in the domain
            for (const itemName in client[domainName]) {
                // add CDP object to the REPL context
                const cdpObject = client[domainName][itemName];
                cdpRepl.context[domainName][itemName] = cdpObject;
            }
        }
    }).on('error', (err) => {
        console.error('Cannot connect to remote endpoint:', err.toString());
    });
}

function list(options) {
    CDP.List(options, (err, targets) => {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
        console.log(toJSON(targets));
    });
}

function _new(url, options) {
    options.url = url;
    CDP.New(options, (err, target) => {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
        console.log(toJSON(target));
    });
}

function activate(args, options) {
    options.id = args;
    CDP.Activate(options, (err) => {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
    });
}

function close(args, options) {
    options.id = args;
    CDP.Close(options, (err) => {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
    });
}

function version(options) {
    CDP.Version(options, (err, info) => {
        if (err) {
            console.error(err.toString());
            process.exit(1);
        }
        console.log(toJSON(info));
    });
}

function protocol(args, options) {
    options.local = args.local;
    CDP.Protocol(options, (err, protocol) => {
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
    .option('-v, --v', 'Show this module version')
    .option('-t, --host <host>', 'HTTP frontend host')
    .option('-p, --port <port>', 'HTTP frontend port')
    .option('-s, --secure', 'HTTPS/WSS frontend')
    .option('-n, --use-host-name', 'Do not perform a DNS lookup of the host');

program
    .command('inspect [<target>]')
    .description('inspect a target (defaults to the first available target)')
    .option('-w, --web-socket', 'interpret <target> as a WebSocket URL instead of a target id')
    .option('-j, --protocol <file.json>', 'Chrome Debugging Protocol descriptor (overrides `--local`)')
    .option('-l, --local', 'Use the local protocol descriptor')
    .action((target, args) => {
        action = inspect.bind(null, target, args);
    });

program
    .command('list')
    .description('list all the available targets/tabs')
    .action(() => {
        action = list;
    });

program
    .command('new [<url>]')
    .description('create a new target/tab')
    .action((url) => {
        action = _new.bind(null, url);
    });

program
    .command('activate <id>')
    .description('activate a target/tab by id')
    .action((id) => {
        action = activate.bind(null, id);
    });

program
    .command('close <id>')
    .description('close a target/tab by id')
    .action((id) => {
        action = close.bind(null, id);
    });

program
    .command('version')
    .description('show the browser version')
    .action(() => {
        action = version;
    });

program
    .command('protocol')
    .description('show the currently available protocol descriptor')
    .option('-l, --local', 'Return the local protocol descriptor')
    .action((args) => {
        action = protocol.bind(null, args);
    });

program.parse(process.argv);

// common options
const options = {
    host: program.host,
    port: program.port,
    secure: program.secure,
    useHostName: program.useHostName
};

if (action) {
    action(options);
} else {
    if (program.v) {
        console.log(packageInfo.version);
    } else {
        program.outputHelp();
        process.exit(1);
    }
}
