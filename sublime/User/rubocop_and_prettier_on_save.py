import sublime
import sublime_plugin
import os
import subprocess

# class RubocopOnSave(sublime_plugin.EventListener):
#     def on_post_save_async(self, view):
#         filename = view.file_name()
#         if view.match_selector(0, "source.ruby"):
#             subprocess.call(['bundle exec rubocop', '-a', filename], cwd=os.path.dirname(filename))

# TODO: remove whitespace at end of lines regardless of file type
# WTF is up with haml?
class LintersOnSave(sublime_plugin.EventListener):
    def on_post_save_async(self, view):
        filename = view.file_name()
        filetype = os.path.splitext(filename)
        filetype = filetype[len(filetype) - 1]
        npx_filetypes = [".tsx", ".ts", ".js", ".jsx", ".mjs", ".yml", ".md"]
        haml_filetypes = [".haml"]
        if view.match_selector(0, "source.ruby"): # or filetype in ruby_filetypes:
            view.window().run_command('exec', {
                'cmd': ['rubocop', '-a', filename],
                'working_dir': os.path.dirname(filename),
            })
        elif filetype in npx_filetypes:
            view.window().run_command('exec', {
                'cmd': ['/Users/tj.eakle/.nvm/versions/node/v16.14.0/bin/npx', 'prettier', '--write', filename],
                'working_dir': os.path.dirname(filename)
            })
        # TODO make haml lint work
        # elif filetype in haml_filetypes:
        #     view.window().run_command('exec', {
        #         'cmd': ['haml-lint', '', filename],
        #         'working_dir': os.path.dirname(filename),
        #     })
        # else:
        #     view.window().run_command('exec', {
        #         'cmd': ['/Users/tj.eakle/.nvm/versions/node/v16.14.0/bin/npx', 'prettier', '--write', filename],
        #         'working_dir': os.path.dirname(filename)
        #     })
# npx prettier --write
