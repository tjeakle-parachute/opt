#!/usr/bin/env python3

import iterm2
import AppKit

# Launch the app
AppKit.NSWorkspace.sharedWorkspace().launchApplication_("iTerm2")

async def main(connection):
    app = await iterm2.async_get_app(connection)

    # Foreground the app
    await app.async_activate()

    profile = "app-workflow"
    start_docker = "./script/app-workflow-start-docker.sh"
    start_yarn = "./script/app-workflow-start-yarn.sh"
    start_rails_server = "./script/app-workflow-start-rails-server.sh"
    commands = [start_docker, start_yarn, start_rails_server]

    myterm = await iterm2.Window.async_create(connection, profile= profile, command= commands[0])

    #for i in range(1, profiles.length - 1):
    for command in commands:
        if command == commands[0]:
            continue
        await myterm.async_create_tab(profile= profile, command= command)

    await myterm.async_activate()

# Passing True for the second parameter means keep trying to
# connect until the app launches.
iterm2.run_until_complete(main, True)