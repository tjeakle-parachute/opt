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

    myterm = app.current_terminal_window

    # Create a new tab or window
    #open_new_window = myterm is None
    open_new_window = True

    if open_new_window == True:
        myterm = await iterm2.Window.async_create(connection, profile= profiles[0])
    else:
        await myterm.async_create_tab(profile= profiles[0])


    #await myterm.async_create_tab(profile= profiles[1])
    #await myterm.async_create_tab(profile= profiles[2])


    #for i in range(1, profiles.length - 1):
    for profile in profiles:
        if profile == profiles[0]:
            continue
        await myterm.async_create_tab(profile= profile)

    await myterm.async_activate()

    #await new_session_1.async_send_text(text= session_1_command, suppress_broadcast= False)
    update = iterm2.LocalWriteOnlyProfile()
    update.set_allow_title_setting(False)
    update.set_name("This is my customized session name")

# Passing True for the second parameter means keep trying to
# connect until the app launches.
iterm2.run_until_complete(main, True)