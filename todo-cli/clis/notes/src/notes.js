const fs = require('fs');
const chalk = require('chalk');
const args = process.argv.slice(2);
const cmd = args[0];
const notesFile = process.env.HOME + '/notes.txt';

if(cmd === 'add' || cmd === 'a') {const note = args.slice(1).join('');
fs.appendFileSync(notesFile,note);
console.log('Note added');
} else if(cmd === 'list' || cmd === 'l') {if(fs.existsSync(notesFile, 'utf8'));
} else {console.log('NOTES-CLI: notes add "text" | list');
}
