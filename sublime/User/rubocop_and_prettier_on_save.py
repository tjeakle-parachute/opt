import sublime
import sublime_plugin
import os
import subprocess

# class RubocopOnSave(sublime_plugin.EventListener):
#     def on_post_save_async(self, view):
#         filename = view.file_name()
#         if view.match_selector(0, "source.ruby"):
#             subprocess.call(['bundle exec rubocop', '-a', filename], cwd=os.path.dirname(filename))

class LintersOnSave(sublime_plugin.EventListener):
    def on_post_save_async(self, view):
        filename = view.file_name()
        filetype = os.path.splitext(filename)
        filetype = filetype[len(filetype) - 1]
        npx_filetypes = [".tsx", ".ts", ".js", ".jsx", ".mjs"]
        if view.match_selector(0, "source.ruby"):
            view.window().run_command('exec', {
                'cmd': ['rubocop', '-a', filename],
                'working_dir': os.path.dirname(filename),
            })
        elif filetype in npx_filetypes:
            view.window().run_command('exec', {
                'cmd': ['/Users/tj.eakle/.nvm/versions/node/v16.14.0/bin/npx', 'prettier', '--write', filename],
                'working_dir': os.path.dirname(filename)
            })
        # else:
        #     view.window().run_command('exec', {
        #         'cmd': ['/Users/tj.eakle/.nvm/versions/node/v16.14.0/bin/npx', 'prettier', '--write', filename],
        #         'working_dir': os.path.dirname(filename)
        #     })
# npx prettier --write
