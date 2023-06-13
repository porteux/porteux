#!/usr/bin/python

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, Gio
import os
from os import getenv, getuid, path
from os.path import exists
import subprocess
import signal
import json
from urllib.request import urlopen
from datetime import datetime, timezone
from pathlib import Path

if os.geteuid() != 0:
    this_script = path.abspath(__file__)
    subprocess.run(['psu', this_script])
    quit()

REPO_FOLDER_PATH = "https://raw.githubusercontent.com/porteux/porteux/main/porteux-scripts/porteux-app-store/"
GTK_DIALOG_SCRIPT = "/opt/porteux-scripts/gtkdialog.py"
GTK_PROGRESS_SCRIPT = "/opt/porteux-scripts/gtkprogress.py"
APP_STORE_PATH = "/opt/porteux-scripts/porteux-app-store/"
APPS_FOLDER = APP_STORE_PATH + 'applications/'
REPO_APPS_FOLDER = REPO_FOLDER_PATH + 'applications/'
ICONS_FOLDER = '/usr/share/pixmaps/'
REPO_ICONS_FOLDER = REPO_FOLDER_PATH + 'icons/'
MAX_AGE_HOURS=6

class AppWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        with open(APP_STORE_PATH + 'porteux-app-store-db.json') as db:
            self.applications = json.load(db)
        
        self.set_has_tooltip(True)
        
        self.box_main = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)
        self.box_applications = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)
        self.box_action_buttons = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.HORIZONTAL)

        self.scrolled_window_applications = Gtk.ScrolledWindow(hscrollbar_policy=Gtk.PolicyType.NEVER, vscrollbar_policy=Gtk.PolicyType.AUTOMATIC)

        self.label_main = Gtk.Label()
        self.label_main.set_markup("<span size=\"x-large\" weight=\"bold\">Choose an application</span>")
        self.box_main.pack_start(self.label_main, False, False, 5)

        self.box_main.pack_start(Gtk.Separator(), False, False, 5)

        for section, apps in self.applications.items(): 
            section = self.create_section_applications(section, apps)
            self.box_applications.pack_start(section, False, False, 5)

        self.scrolled_window_applications.add(self.box_applications)
        self.box_main.pack_start(self.scrolled_window_applications, True, True, 5)

        self.box_main.pack_start(Gtk.Separator(), False, False, 5)

        self.check_button_module = Gtk.CheckButton(label="Activate application module")
        self.check_button_module.set_active(True)
        self.check_button_module.set_tooltip_text("Activate application module after download")

        self.button_close = Gtk.Button(label="Close")
        self.button_close.connect("clicked", self.on_main_close_clicked)

        self.box_action_buttons.pack_end(self.button_close, False, False, 5)
        self.box_action_buttons.pack_end(self.check_button_module, False, False, 5)

        self.box_main.pack_start(self.box_action_buttons, False, False, 5)

        self.button_close.grab_focus()

        self.add(self.box_main)

    def create_button_application(self, label_name, tooltip):
        icon_name = label_name.lower().split(" ")[0]

        icon = Gio.ThemedIcon(name=icon_name)
        image = Gtk.Image.new_from_gicon(icon, Gtk.IconSize.DIALOG)
        label = Gtk.Label(label=label_name)
        
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        box.pack_start(image, True, True, 0)
        box.pack_start(label, True, True, 0)
        
        button = Gtk.Button(relief=Gtk.ReliefStyle.NONE)
        button.set_can_focus(False)
        button.set_tooltip_text(tooltip)
        
        button.add(box)
        
        return button

    def create_section_applications(self, section_name, apps):
        box = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)

        flowbox = Gtk.FlowBox(max_children_per_line = 5, row_spacing = 25, homogeneous = True)

        for button_name in apps:
            if "tooltip" in apps[button_name]:
                tt = apps[button_name]["tooltip"]
            else:
                tt = button_name

            button = self.create_button_application(button_name, tt)
            button.connect("clicked", lambda _, name=button_name: self.on_section_button_clicked(section_name, name))
            flowbox.add(button)


        label = Gtk.Label()
        label.set_markup("<span size=\"small\" weight=\"bold\">   " + section_name + ":</span>")
        label.set_halign(Gtk.Align.START)
        box.pack_start(label, False, False, 5)
        box.pack_start(flowbox, False, False, 5)
            
        box.pack_start(Gtk.Separator(), False, False, 5)

        return box

    def show_dialog_options(self, applicationName, app):
        dialog = Gtk.Dialog(title="Select Options", parent=self, modal=True)
        dialog.set_default_size(250, 220)
        dialog.set_resizable(False)
        
        combobox_channel = Gtk.ComboBoxText()
        combobox_language = Gtk.ComboBoxText()

        if "locales" in app:
            index = -1
            for locale in app["locales"]:
                combobox_language.append_text(locale)
                index += 1
                if "en-US" in locale:
                    combobox_language.set_active(index)
        else:
            combobox_language.append_text("en-US")
            combobox_language.set_active(0)

        for channel in app["channels"]:
            combobox_channel.append_text(channel)
        
        combobox_channel.set_active(0)

        label_application=Gtk.Label(label=applicationName)
        dialog.vbox.pack_start(label_application, False, False, 5)
        
        dialog.vbox.pack_start(Gtk.Separator(), False, False, 5)
        
        label_channel=Gtk.Label(label="Channel:")
        label_channel.set_halign(Gtk.Align.START)
        dialog.vbox.pack_start(label_channel, False, False, 5)
        dialog.vbox.add(combobox_channel)

        language_label=Gtk.Label(label="Language:")
        language_label.set_halign(Gtk.Align.START)
        dialog.vbox.pack_start(language_label, False, False, 5)
        dialog.vbox.add(combobox_language)

        button_download = Gtk.Button(label="Download")
        button_close = Gtk.Button(label="Close")

        box_buttons = Gtk.Box(spacing=6, orientation=Gtk.Orientation.HORIZONTAL)
        box_buttons.pack_start(button_download, True, True, 0)
        box_buttons.pack_start(button_close, True, True, 0)

        dialog.get_content_area().pack_end(box_buttons, False, True, 0)
        button_download.grab_focus()

        combobox_channel.connect("changed", self.on_dialog_combobox_channel_changed, combobox_language)
        combobox_language.connect("changed", self.on_dialog_combobox_language_changed, button_download)
        button_download.connect("clicked", self.on_dialog_button_download_clicked, app, combobox_channel, combobox_language, dialog)
        button_close.connect("clicked", self.on_dialog_button_close_clicked, dialog)

        dialog.show_all()

    def show_dialog_porteux(self, input):
        subprocess.call([GTK_DIALOG_SCRIPT, "-p", input])
        
    def execute_external_script(self, script_command):
        hasInternet = subprocess.call(["/bin/bash", "-c", "ping -q -c1 1.1.1.1 > /dev/null 2>&1"])
        if hasInternet != 0:
            subprocess.call([GTK_DIALOG_SCRIPT, "-p", "No internet connection"])
            return

        with open('/dev/null', 'w') as devnull:
            progress_dialog = subprocess.Popen(
                [GTK_PROGRESS_SCRIPT, "-w", "Download and Generate Module", "-m", "Application module is being processed...", "-t", " "],
                stderr=devnull
            )

        activate_parameter = self.on_main_get_activate_module_paramater(self.check_button_module)
        result = subprocess.run(["/bin/bash", "-c", script_command + " " + activate_parameter], stdout=subprocess.PIPE)
        output = result.stdout.decode("utf-8")

        if output:
            self.show_dialog_porteux(output.splitlines()[-1])
        else:
            self.show_dialog_porteux("Error creating module.")

        progress_dialog.send_signal(signal.SIGINT)

    def on_main_key_down(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()

    def on_main_get_activate_module_paramater(self, check_button_module):
        if check_button_module.get_active():
            return "--activate-module"
        else:
            return ""

    def on_main_close_clicked(self, button):
        self.destroy()

    def on_section_button_clicked(self, section_name, applicationName):
        app = self.applications[section_name][applicationName]

        if "infoDialog" in app:
            subprocess.call([ GTK_DIALOG_SCRIPT, "-p", app["infoDialog"]])

        if "channels" in app:
            self.show_dialog_options(applicationName, app)
        elif "askInstallationPath" in app:
            appFolderDialog = GtkFolder(self, applicationName)
            response = appFolderDialog.run()
            if response == Gtk.ResponseType.OK:
                self.execute_external_script(APP_STORE_PATH + "applications/" + app["script"] + ".sh " + appFolderDialog.get_result())
            appFolderDialog.destroy() 
        else:
            self.execute_external_script(APP_STORE_PATH + "applications/" + app["script"] + ".sh")

    def on_dialog_combobox_channel_changed(self, combobox, combobox_language):
        combobox_language.set_sensitive(True)

    def on_dialog_combobox_language_changed(self, combobox, button_download):
        button_download.set_sensitive(True)

    def on_dialog_button_download_clicked(self, button, app, combobox_channel, combobox_language, dialog):
        channel = combobox_channel.get_active_text()
        language = combobox_language.get_active_text()
        self.execute_external_script(APP_STORE_PATH + "applications/" + app["script"] + ".sh {0} {1}".format(channel, language))
        dialog.destroy()

    def on_dialog_button_close_clicked(self, button, dialog):
        dialog.destroy()

class GtkFolder(Gtk.Dialog):
    def __init__(self, parent, applicationName):
        Gtk.Dialog.__init__(self, applicationName + " Installation Path", parent, 0, border_width = 10, height_request = 200, width_request = 460)
        self.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OK, Gtk.ResponseType.OK)

        self.result = ""
        self.connect("response", self.on_response)
        self.vb = self.get_content_area()

        self.text = Gtk.Label()
        self.text.set_markup("Choose a folder to install " + applicationName)
        self.vb.add(self.text)

        self.vb.pack_start(Gtk.Separator(), False, False, 10)

        self.grid = Gtk.Grid(column_spacing = 20)
        self.label = Gtk.Label(xalign = 0.0)
        self.label.set_markup("Folder:")
        self.grid.attach(self.label, 10, 0, 1, 1)
        self.entry = Gtk.Entry()
        self.grid.attach(self.entry, 11, 0, 19, 1)
        self.add_folder_button = Gtk.Button.new_from_icon_name("folder-open-symbolic", Gtk.IconSize.BUTTON)
        self.add_folder_button.connect("clicked", self.on_add_folder_button_clicked, applicationName)
        self.grid.attach(self.add_folder_button, 30, 0, 1, 1)
        self.vb.add(self.grid)
        self.show_all()

    def on_add_folder_button_clicked(self, button, applicationName):
        dir_dialog = Gtk.FileChooserDialog(title = "Choose Folder", parent = self, action = Gtk.FileChooserAction.SELECT_FOLDER)
        dir_dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, "Select", Gtk.ResponseType.OK)
        dir_dialog.set_default_size(400, 280)
        response = dir_dialog.run()

        if Gtk.ResponseType.OK == response:
            self.src_dir = dir_dialog.get_filename() + "/" + applicationName.replace(" ", "-").lower()
            self.entry.set_text(self.src_dir)

        dir_dialog.destroy()

    def on_response(self, widget, response_id):
        self.result = self.entry.get_text()

    def get_result(self):
        return self.result

class Application(Gtk.Application):
    def __init__(self, *args, **kwargs):
        self.update_changed_files()
        super().__init__(*args, application_id="org.porteux_app_store", **kwargs)
        self.window = None

    def do_activate(self):
        if not self.window:
            self.window = AppWindow(application=self, title="PorteuX App Store")
            self.window.set_default_size(640, 480)
            self.window.set_resizable(False)
            self.window.set_position(Gtk.WindowPosition.CENTER)
            self.window.set_icon_name("browser")
            self.window.connect("key-press-event", self.window.on_main_key_down)

        self.window.show_all()
        self.window.present()
    
    def update_changed_files(self):
        if exists(APP_STORE_PATH + 'porteux-app-store-db.json'):
            fileStat = Path(APP_STORE_PATH + 'porteux-app-store-db.json').stat()
            fileDateTime = datetime.fromtimestamp(fileStat.st_mtime, tz=None)
            if (datetime.today() - fileDateTime).seconds <= 3600 * MAX_AGE_HOURS:
                return
        
        with open('/dev/null', 'w') as devnull:
            progress_dialog = subprocess.Popen(
                [GTK_PROGRESS_SCRIPT, "-w", "PorteuX App Store", "-m", "Updating application list...", "-t", " "],
                stderr=devnull
            )
        
        with urlopen(REPO_FOLDER_PATH + 'porteux-app-store-db.json') as ndb:
            if ndb.status != 200:
                return

            db_decoded = ndb.read().decode('utf-8')
            DB = json.loads(db_decoded)

            with open(APP_STORE_PATH + 'porteux-app-store-db.json', 'w') as db_file:
                db_file.write(db_decoded)
                
        files = [ 'porteux-app-store-live.sh', 'appimage-builder.sh', 'module-builder.sh' ]

        for filename in files:
            with open(APP_STORE_PATH + filename, 'wb') as file, urlopen(REPO_FOLDER_PATH + filename) as nfile:
                file.write(nfile.read())
                os.chmod(APP_STORE_PATH + filename, 0o755)

        os.makedirs(APPS_FOLDER, exist_ok=True)
        os.makedirs(ICONS_FOLDER, exist_ok=True)
        
        for _, apps in DB.items():
            for _, app in apps.items():
                if "script" in app:
                    with open(APPS_FOLDER + app['script'] + '.sh', 'w') as script, urlopen(REPO_APPS_FOLDER + app['script'] + '.sh') as nscript:
                        script.write(nscript.read().decode('utf-8'))
                    os.chmod(APPS_FOLDER + app['script'] + '.sh', 0o755)
                if "icon" in app:
                    if not exists(ICONS_FOLDER + app['icon']):
                        with open(ICONS_FOLDER + app['icon'], 'wb') as icon, urlopen(REPO_ICONS_FOLDER + app['icon']) as nicon:
                            icon.write(nicon.read())
                        os.chmod(ICONS_FOLDER + app['icon'], 0o644)
        
        progress_dialog.send_signal(signal.SIGINT)

if __name__ == "__main__":
    app = Application()
    app.run(None)
