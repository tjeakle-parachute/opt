#!/usr/bin/env python3

import iterm2
import AppKit

# Launch the app
AppKit.NSWorkspace.sharedWorkspace().launchApplication_("iTerm2")

async def main(connection):
    app = await iterm2.async_get_app(connection)

    # Foreground the app
    await app.async_activate()

    profiles = ["app-workflow-start-docker", "app-workflow-start-yarn", "app-workflow-start-rails-server"]

    myterm = await iterm2.Window.async_create(connection, profile= profiles[0])

    for profile in profiles:
        if profile == profiles[0]:
            continue
        await myterm.async_create_tab(profile= profile)

    await myterm.async_activate()

# Passing True for the second parameter means keep trying to
# connect until the app launches.
iterm2.run_until_complete(main, True)