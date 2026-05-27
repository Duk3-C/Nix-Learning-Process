Nix and NixOS use a functional programming language called Nix to specify how to build and install software, and how to configure system, user, and project-specific environments.
Nix is the name of the packet manager and the language it uses.

Paths are a special data type in Nix. They may be absolute or relative, and are not enclosed in quotation marks; they are not strings.
Enclosing a path in angle brackets <> causes the directories listed in the environment variable *NIX_PATH* to be searched for the given file or directory name. The are called ***lookup paths***.

List elements are enclosed in square brackets [] and separated by spaces instead of commas.

***Attribute sets*** associate keys with values. They are enclosed in curly brackets, and the associations are terminated by semi-colons.
The key of an attribute set must be strings.

***Derivations*** can be treated like any other data type in Nix.

Nix REPL *(Read-Eval-Print-Loop)*
type :? to see a list of available commands

```bash
$ nix repl 
Welcome to Nix 2.18.1. Type :? for help. 
nix-repl> :? 
The following commands are available: 

	<expr> Evaluate and print expression 
	<x> = <expr> Bind expression to variable 
	:a, :add <expr> Add attributes from resulting set to scope 
	:b <expr> Build a derivation 
	:bl <expr> Build a derivation, creating GC roots in the working directory
	 
	:e, :edit <expr> Open package or function in $EDITOR 
	:i <expr> Build derivation, then install result into current profile
	 
	:l, :load <path> Load Nix expression and add it to scope 
	:lf, :load-flake <ref> Load Nix flake and add it to scope 
	:p, :print <expr> Evaluate and print expression recursively 
	:q, :quit Exit nix-repl 
	:r, :reload Reload all files
	:sh <expr> Build dependencies of derivation, then start nix-shell
	 
	:t <expr> Describe result of evaluation 
	:u <expr> Build derivation, then start nix-shell 
	:doc <expr> Show documentation of a builtin function 
	:log <expr> Show logs for a derivation 
	:te, :trace-enable [bool] Enable, disable or toggle showing traces for errors
	 
	:?, :help Brings up this help menu
```

In Nix, values are immutable; once you assign a value to a variable, you cannot change it. You can, however, create a new variable with the same name, but in a different scope.

You cannot mix number and strings. 
built-in functions for strings:
	builtins.stringlength - returns size of string
	builtins.substring - given a starting position and a length, extract a substring. First character of a string has index 0.
	builtins.toString - convert an expression to a string

boolean operations are basically the same as in C++.

You can specify the current directory as ./. 
To refer to a file or directory relative to the current directory, prefix it with ./.

A path can be concatenated with a string to produce a new path
Example:
```nix
nix-repl> /home/dir + "/file.txt"
/home/dir/file.txt
```

You can also concatenate a string with a path, but if the path exists, it is copied to the Nix store. So, the result is a string, not a path.

Check if path exists built-in functions:
```nix
nix-repl> builtins.pathExists ./file.txt
```

Get a list of the files in a directory, along with the type of each file:
```nix
nix-repl> builtins.readDir ./.
```

Read the contents of a file into a string:
```nix
nix-repl> bultins.readFile ./.file.txt
"some output"
```

Lists can also be concatenated using the ++ operator.

