# opt
Optional things I created to make my life easier!

Meant to be checked out and used in /Users/tj.eakle

script is just random things I use to start services or quick shortcuts.

iTerm is my iterm profiles and scripts.

Note: Scripts on my setup is a symbolic link to $HOME/opt/iTerm/Scripts

```
cd /Users/tj.eakle/Library/Application Support/iTerm2
mv Scripts Scripts.old
ln -s /Users/tj.eakle/opt/iTerm2/Scripts Scripts
```
Currently only running app-worker is particularly useful.

.zshrc is symbolically linked in my home directory so i can back it up and control it here.
uses asdf, oh-my-zsh

```
cd ~
mv .zshrc .zshrc.old
ln -s opt/.zshrc .zshrc
```

I will most likely forget to update the readme for future me but this is how it started!
