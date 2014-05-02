project-pal.vim
===============

IMPORTANT: This project is still in an Alpha stage, and is likely to undergo significant API changes.

# Overview
Project-Pal.vim is a *lightweight* project management system for the Vim editor. Heavy-weigth IDEs like Eclipse or Visual Studio rely on verbose files to manage settings such as code paths and compiler options. While project settings can be useful, there are several major headaches that can arise when dealing with these files. Specifically, it can be challenging to share project files acrooss different computers.  In the worst case, if the file is lost, or becomes corrupted (say from a merge conflict) you may not even be able to open your project anymore.

Vim has no innate concept of projects, so the purpose of Project-Pal.vim is simply to run a custom script when a particular project loads. A project definition is simply a folder with a .vim file that is run when the project is loaded.  Beyond that, other "meta" information about the project may be included as you see fit (e.g.: tags, 

In the spirit of Vim, Project-Pal.vim does not force you into into a paricular workflow. It's goal is to give you the basic tools so you can set up your projects however you want them.

# Features
Project-Pal.vim currently 
* Initializes a project by changing the current directory and running other customs commands in a settings.vim file
* Builds a project by running a custom build command
* Generates tags for a project
These tasks are performed asynchronously, and the status bar is updated when they complete.

# Setup 
I use [Vundle](https://github.com/gmarik/Vundle.vim) to manage my VIM plugins. Put this line in your .vimrc:
````
Bundle  'adampasz/project-pal.vim'
````
Project.Pal.vim also has a dependency on the indispensible [AsyncCommand](https://github.com/vim-scripts/AsyncCommand) plugin.
````
Bundle 'AsyncCommand'
````

Start VIM, and then run:
````
BundleInstall
````

In your .vimrc, you should define a global variable that points to your "project settings" folder. e.g.:
````
let g:proj='~/.vim/proj/'
````

For now, you need to manually create a sub-folder for each project, and provide a settings.vim file. e.g.:
````
~/.vim/proj/myProject1/settings.vim
~/.vim/proj/myProject2/settings.vim
etc.
````

The settings.vim file should define the project root. You may also want to specify a command to build the project.
````
let g:proot=fnameescape('/Users/adampasz/path/to/my/project/')
let g:buildProjectCommand = 'run_build.sh'
````

If you want to use tags, include an array of relative paths in settings.vim, as follows:
````
let g:ptags = [
\	'path/to/js/src/',
\	'path/to/coffeescript/src/',
\	'path/to/some/other/code/'
\]
````

# Usage
:InitProject - Enter the name of project (i.e. the name of the proejct sub-folder) to run the settings.vim script.
:GenerateTags - Runs ctags on paths specified in g:ptags. Note, this replaces all previous tags for your Vim session.
:call BuildProject(...) - Calls your custom build command, with optional arguments 
