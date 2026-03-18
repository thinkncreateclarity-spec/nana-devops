const fs = require('fs');
const chalk = require('chalk');
const args = process.argv.slice(2);
const cmd = args[0];

const todoFile = process.env.HOME + '/todos.json';

if(cmd === 'add') {
  const task = args.slice(1).join(' ');
  const todos = fs.existsSync(todoFile) ? JSON.parse(fs.readFileSync(todoFile)) : [];
  todos.push({task, done: false});
  fs.writeFileSync(todoFile, JSON.stringify(todos, null, 2));
  console.log(chalk.green('Added: ' + task));
} else if(cmd === 'list') {
  const todos = fs.existsSync(todoFile) ? JSON.parse(fs.readFileSync(todoFile)) : [];
  if(todos.length === 0) {
    console.log(chalk.yellow('No todos'));
  } else {
    todos.forEach((t, i) => {
      console.log((i+1) + '. ' + (t.done ? '[x]' : '[ ]') + ' ' + t.task);
    });
  }
} else {
  console.log('TODO-LIST-CLI');
  console.log('todo-list add "Buy milk" | list');
}
