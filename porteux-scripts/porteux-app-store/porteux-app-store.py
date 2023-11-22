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

DB_JSON_FILE = 'porteux-app-store-db.json'
MAX_AGE_HOURS = 6

REPO_APPSTORE_URL = "https://raw.githubusercontent.com/porteux/porteux/main/porteux-scripts/porteux-app-store/"
REPO_APPS_URL = REPO_APPSTORE_URL + 'applications/'
REPO_ICONS_URL = REPO_APPSTORE_URL + 'icons/'

LOCAL_APPSTORE_PATH = "/opt/porteux-scripts/porteux-app-store/"
LOCAL_APPS_PATH = LOCAL_APPSTORE_PATH + 'applications/'
LOCAL_DB_JSON_PATH = LOCAL_APPSTORE_PATH + DB_JSON_FILE
LOCAL_ICONS_PATH = '/usr/share/pixmaps/'

GTK_DIALOG_SCRIPT = "/opt/porteux-scripts/gtkdialog.py"
GTK_PROGRESS_SCRIPT = "/opt/porteux-scripts/gtkprogress.py"

def is_recently_updated(file_path, hours = MAX_AGE_HOURS):
    if not exists(file_path):
        return False

    file_stat = Path(file_path).stat()
    file_date_time = datetime.fromtimestamp(file_stat.st_mtime, tz=None)
    return (datetime.today() - file_date_time).total_seconds() <= 3600 * hours

class AppWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        with open(LOCAL_APPSTORE_PATH + DB_JSON_FILE) as local_db_json_file:
            self.db_json = json.load(local_db_json_file)

        self.set_has_tooltip(True)

        self.box_main = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)
        self.box_applications = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)
        self.box_action_buttons = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.HORIZONTAL)

        self.scrolled_window_applications = Gtk.ScrolledWindow(hscrollbar_policy=Gtk.PolicyType.NEVER, vscrollbar_policy=Gtk.PolicyType.AUTOMATIC)

        self.label_main = Gtk.Label()
        self.label_main.set_markup("<span size=\"x-large\" weight=\"bold\">Choose an application</span>")
        self.box_main.pack_start(self.label_main, False, False, 5)

        self.box_main.pack_start(Gtk.Separator(), False, False, 5)

        for section, applications in self.db_json.items():
            section = self.create_section_applications(section, applications)
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

    def create_button_application(self, label_name, tooltip, applications):
        icon_name = os.path.splitext(applications[label_name]["icon"])[0]

        icon = Gio.ThemedIcon(name=icon_name)
        image = Gtk.Image.new_from_gicon(icon, Gtk.IconSize.DIALOG)
        label = Gtk.Label(label=label_name)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        box.pack_start(image, True, True, 0)
        box.pack_start(label, True, True, 0)

        button = Gtk.Button(relief=Gtk.ReliefStyle.NONE)
        button.set_can_focus(False)
        button.set_tooltip_text(tooltip)
        button.set_size_request(100, 100)

        button.add(box)

        return button

    def create_section_applications(self, section_name, applications):
        box = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)

        flowbox = Gtk.FlowBox(row_spacing = 5, homogeneous = False)

        for button_name in applications:
            if "tooltip" in applications[button_name]:
                tooltip = applications[button_name]["tooltip"]
            else:
                tooltip = button_name

            button = self.create_button_application(button_name, tooltip, applications)
            button.connect("clicked", lambda _, name=button_name: self.on_section_button_clicked(section_name, name))
            flowbox.add(button)


        label = Gtk.Label()
        label.set_markup("<span size=\"small\" weight=\"bold\">   " + section_name + ":</span>")
        label.set_halign(Gtk.Align.START)
        box.pack_start(label, False, False, 5)
        box.pack_start(flowbox, False, False, 5)

        box.pack_start(Gtk.Separator(), False, False, 5)

        return box

    def show_dialog_options(self, application_name, application):
        dialog = Gtk.Dialog(title="Select Options", parent=self, modal=True)
        dialog.set_default_size(250, 220)
        dialog.set_resizable(False)

        combobox_channel = Gtk.ComboBoxText()
        combobox_language = Gtk.ComboBoxText()

        if "locales" in application:
            index = -1
            for locale in application["locales"]:
                combobox_language.append_text(locale)
                index += 1
                if "en-US" in locale:
                    combobox_language.set_active(index)
        else:
            combobox_language.append_text("en-US")
            combobox_language.set_active(0)

        for channel in application["channels"]:
            combobox_channel.append_text(channel)

        combobox_channel.set_active(0)

        label_application=Gtk.Label(label=application_name)
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
        button_download.connect("clicked", self.on_dialog_button_download_clicked, application, combobox_channel, combobox_language, dialog)
        button_close.connect("clicked", self.on_dialog_button_close_clicked, dialog)

        dialog.show_all()

    def show_dialog_porteux(self, input):
        subprocess.call([GTK_DIALOG_SCRIPT, "-p", input])

    def has_internet(self):
        has_Internet = subprocess.call(["/bin/bash", "-c", "ping -q -c1 1.1.1.1 > /dev/null 2>&1"])
        if has_Internet != 0:
            has_Internet = subprocess.call(["/bin/bash", "-c", "ping -q -c1 8.8.8.8 > /dev/null 2>&1"])
            if has_Internet != 0:
                subprocess.call([GTK_DIALOG_SCRIPT, "-p", "No internet connection"])
                return False
        return True

    def execute_external_script(self, script_name, extra_commands = ""):
        if not self.has_internet():
            return

        with open('/dev/null', 'w') as devnull:
            progress_dialog = subprocess.Popen(
                [GTK_PROGRESS_SCRIPT, "-w", "Download and Generate Module", "-m", "Application module is being processed...", "-t", " "],
                stderr=devnull
            )

        local_script_path = LOCAL_APPS_PATH + script_name + ".sh"
        if not is_recently_updated(local_script_path):
            with open(local_script_path, "w") as local_script, urlopen(REPO_APPS_URL + script_name + ".sh") as remote_script:
                remote_script_decoded = remote_script.read().decode("utf-8")
                local_script.write(remote_script_decoded)
            os.chmod(local_script_path, 0o755)

        activate_parameter = self.on_main_get_activate_module_paramater(self.check_button_module)
        result = subprocess.run(["/bin/bash", "-c", local_script_path + " " + extra_commands + " " + activate_parameter], stdout=subprocess.PIPE)
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

    def on_section_button_clicked(self, section_name, application_name):
        application = self.db_json[section_name][application_name]

        if "info_dialog" in application:
            subprocess.call([ GTK_DIALOG_SCRIPT, "-p", application["info_dialog"]])

        if "channels" in application:
            self.show_dialog_options(application_name, application)
        elif "ask_installation_path" in application:
            application_folder_dialog = GtkFolder(self, application_name)
            response = application_folder_dialog.run()
            if response == Gtk.ResponseType.OK:
                self.execute_external_script(application["script"], application_folder_dialog.get_result())
            application_folder_dialog.destroy()
        else:
            self.execute_external_script(application["script"])

    def on_dialog_combobox_channel_changed(self, combobox, combobox_language):
        combobox_language.set_sensitive(True)

    def on_dialog_combobox_language_changed(self, combobox, button_download):
        button_download.set_sensitive(True)

    def on_dialog_button_download_clicked(self, button, application, combobox_channel, combobox_language, dialog):
        channel = combobox_channel.get_active_text()
        language = combobox_language.get_active_text()
        self.execute_external_script(application["script"], "{0} {1}".format(channel, language))
        dialog.destroy()

    def on_dialog_button_close_clicked(self, button, dialog):
        dialog.destroy()

class GtkFolder(Gtk.Dialog):
    def __init__(self, parent, application_name):
        Gtk.Dialog.__init__(self, application_name + " Installation Path", parent, 0, border_width = 10, height_request = 200, width_request = 460)
        self.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OK, Gtk.ResponseType.OK)

        self.result = ""
        self.connect("response", self.on_response)
        self.vb = self.get_content_area()

        self.text = Gtk.Label()
        self.text.set_markup("Choose a folder to install " + application_name)
        self.vb.add(self.text)

        self.vb.pack_start(Gtk.Separator(), False, False, 10)

        self.grid = Gtk.Grid(column_spacing = 20)
        self.label = Gtk.Label(xalign = 0.0)
        self.label.set_markup("Folder:")
        self.grid.attach(self.label, 10, 0, 1, 1)
        self.entry = Gtk.Entry()
        self.grid.attach(self.entry, 11, 0, 19, 1)
        self.add_folder_button = Gtk.Button.new_from_icon_name("folder-open-symbolic", Gtk.IconSize.BUTTON)
        self.add_folder_button.connect("clicked", self.on_add_folder_button_clicked, application_name)
        self.grid.attach(self.add_folder_button, 30, 0, 1, 1)
        self.vb.add(self.grid)
        self.show_all()

    def on_add_folder_button_clicked(self, button, application_name):
        dir_dialog = Gtk.FileChooserDialog(title = "Choose Folder", parent = self, action = Gtk.FileChooserAction.SELECT_FOLDER)
        dir_dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, "Select", Gtk.ResponseType.OK)
        dir_dialog.set_default_size(400, 280)
        response = dir_dialog.run()

        if Gtk.ResponseType.OK == response:
            self.src_dir = dir_dialog.get_filename() + "/" + application_name.replace(" ", "-").lower()
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
            self.window.set_position(Gtk.WindowPosition.CENTER)
            self.window.set_icon_name("browser")
            self.window.connect("key-press-event", self.window.on_main_key_down)

        self.window.show_all()
        self.window.present()


    def update_changed_files(self):
        try:
            with open('/dev/null', 'w') as devnull:
                    progress_dialog = subprocess.Popen(
                        [GTK_PROGRESS_SCRIPT, "-w", "PorteuX App Store", "-m", "Updating application list...", "-t", " "],
                        stderr=devnull
                    )

            if not is_recently_updated(LOCAL_DB_JSON_PATH):
                with urlopen(REPO_APPSTORE_URL + DB_JSON_FILE) as remote_db_json_file:
                    if remote_db_json_file.status == 200:
                        remote_db_json_file_decoded = remote_db_json_file.read().decode('utf-8')
                        with open(LOCAL_APPSTORE_PATH + DB_JSON_FILE, 'w') as local_db_json_file:
                            local_db_json_file.write(remote_db_json_file_decoded)

            script_list = [ 'porteux-app-store-live.sh', 'appimage-builder.sh', 'module-builder.sh' ]

            for script_name in script_list:
                local_script_path = LOCAL_APPSTORE_PATH + script_name
                if is_recently_updated(local_script_path):
                    continue
                with open(local_script_path, 'wb') as local_script, urlopen(REPO_APPSTORE_URL + script_name) as remote_script:
                    local_script.write(remote_script.read())
                    os.chmod(local_script_path, 0o755)

            os.makedirs(LOCAL_APPS_PATH, exist_ok = True)

            with open(LOCAL_DB_JSON_PATH, 'r') as local_db_json_file:
                db_json = json.load(local_db_json_file)

            for _, section in db_json.items():
                for _, application in section.items():
                    local_icon_path = LOCAL_ICONS_PATH + application['icon']
                    if is_recently_updated(local_icon_path, 720):
                        continue
                    with open(local_icon_path, 'wb') as local_icon, urlopen(REPO_ICONS_URL + application['icon']) as remote_icon:
                        local_icon.write(remote_icon.read())
                    os.chmod(local_icon_path, 0o644)

            progress_dialog.send_signal(signal.SIGINT)

        except:
            progress_dialog.send_signal(signal.SIGINT)
            return

if __name__ == "__main__":
    application = Application()
    application.run(None)

