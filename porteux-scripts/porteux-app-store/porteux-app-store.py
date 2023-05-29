#!/usr/bin/python

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, Gio
import os
from os import getenv, getuid, path
import subprocess
from subprocess import run, Popen
import signal

if os.geteuid() != 0:
    this_script = path.abspath(__file__)
    run(['psu', this_script])
    quit()

class AppWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.set_has_tooltip(True)
        
        self.box_main = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)
        self.box_applications = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)
        self.box_action_buttons = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.HORIZONTAL)

        self.scrolled_window_applications = Gtk.ScrolledWindow(hscrollbar_policy=Gtk.PolicyType.NEVER, vscrollbar_policy=Gtk.PolicyType.AUTOMATIC)

        self.label_main = Gtk.Label()
        self.label_main.set_markup("<span size=\"x-large\" weight=\"bold\">Choose an application</span>")
        self.box_main.pack_start(self.label_main, False, False, 5)

        self.box_main.pack_start(Gtk.Separator(), False, False, 5)

        self.section_browsers = self.create_section_applications("Web Browsers", ["Chrome", "Chromium", "Firefox", "Opera", "Palemoon", "Vivaldi"])
        self.section_virtual_machines = self.create_section_applications("Virtual Machines", ["VirtualBox", "VirtualBox Guest Additions"])
        self.section_drivers = self.create_section_applications("Drivers", ["Nvidia 5xx"])
        self.section_development = self.create_section_applications("Development", ["Devel Kit", "Notepad++ (Next)", "VSCode (Codium)"])
        self.section_office = self.create_section_applications("Office", ["OnlyOffice"])
        self.section_games = self.create_section_applications("Games", ["Cemu (Wii U)", "PCSX2 (PS2)", "Steam"])
        self.section_messengers = self.create_section_applications("Messengers", ["Teams", "Telegram", "WhatsApp (WALC)"])
        self.section_utils = self.create_section_applications("Utils", ["Crippled Sources", "Etcher", "Multilib Lite", "Wine", "yt-dlp"])

        self.box_applications.pack_start(self.section_browsers, False, False, 5)
        self.box_applications.pack_start(self.section_virtual_machines, False, False, 5)
        self.box_applications.pack_start(self.section_drivers, False, False, 5)
        self.box_applications.pack_start(self.section_development, False, False, 5)
        self.box_applications.pack_start(self.section_office, False, False, 5)
        self.box_applications.pack_start(self.section_games, False, False, 5)
        self.box_applications.pack_start(self.section_messengers, False, False, 5)
        self.box_applications.pack_start(self.section_utils, False, False, 5)

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

    def create_button_application(self, label_name):
        icon_name = label_name.lower().split(" ")[0]

        icon = Gio.ThemedIcon(name=icon_name)
        image = Gtk.Image.new_from_gicon(icon, Gtk.IconSize.DIALOG)
        label = Gtk.Label(label=label_name)
        
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        box.pack_start(image, True, True, 0)
        box.pack_start(label, True, True, 0)
        
        button = Gtk.Button(relief=Gtk.ReliefStyle.NONE)
        button.set_can_focus(False)
        button.set_tooltip_text(label_name)
        
        button.add(box)
        
        return button

    def create_section_applications(self, section_name, button_names):
        box = Gtk.Box(spacing = 5, orientation = Gtk.Orientation.VERTICAL)

        flowbox = Gtk.FlowBox(max_children_per_line = 5, row_spacing = 25, homogeneous = True)

        for button_name in button_names:
            button = self.create_button_application(button_name)
            button.connect("clicked", lambda _, name=button_name: self.on_section_button_clicked(name))
            flowbox.add(button)

        label = Gtk.Label()
        label.set_markup("<span size=\"small\" weight=\"bold\">   " + section_name + ":</span>")
        label.set_halign(Gtk.Align.START)
        box.pack_start(label, False, False, 5)
        box.pack_start(flowbox, False, False, 5)
            
        box.pack_start(Gtk.Separator(), False, False, 5)

        return box

    def show_dialog_options(self, application):
        dialog = Gtk.Dialog(title="Select Options", parent=self, modal=True)
        dialog.set_default_size(250, 220)
        dialog.set_resizable(False)
        
        combobox_channel = Gtk.ComboBoxText()
        combobox_language = Gtk.ComboBoxText()

        index = -1
        locales = open("/opt/porteux-scripts/porteux-app-store/apps-locale-info/" + application + "-locales.txt", "r").read().splitlines()

        for locale in locales:
            combobox_language.append_text(locale)
            index += 1
            if "en-US" in locale:
                combobox_language.set_active(index)

        if application == "chromium":
            combobox_channel.append_text("developer")
            combobox_channel.append_text("stable")
            combobox_channel.set_active(1)
        elif application == "firefox":
            combobox_channel.append_text("beta-latest")
            combobox_channel.append_text("latest")
            combobox_channel.append_text("esr-latest")
            combobox_channel.set_active(1)
        elif application == "google-chrome":
            combobox_channel.append_text("unstable")
            combobox_channel.append_text("beta")
            combobox_channel.append_text("stable")
            combobox_channel.set_active(2)
        elif application == "opera":
            combobox_channel.append_text("developer")
            combobox_channel.append_text("beta")
            combobox_channel.append_text("stable")
            combobox_channel.set_active(2)
        elif application == "palemoon":
            combobox_channel.append_text("stable")
            combobox_channel.set_active(0)
        elif application == "vivaldi":
            combobox_channel.append_text("snapshot")
            combobox_channel.append_text("stable")
            combobox_channel.set_active(1)

        label_application=Gtk.Label(label=application.title())
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
        subprocess.call(["/opt/porteux-scripts/gtkdialog.py", "-p", input])
        
    def execute_external_script(self, script_command):
        hasInternet = subprocess.call(["/bin/bash", "-c", "ping -q -c1 8.8.8.8 > /dev/null 2>&1"])
        if hasInternet != 0:
            subprocess.call(["/opt/porteux-scripts/gtkdialog.py", "-p", "No internet connection"])
            return

        with open('/dev/null', 'w') as devnull:
            progress_dialog = subprocess.Popen(
                ["/opt/porteux-scripts/gtkprogress.py", "-w", "Download and Generate Module", "-m", "Application module is being processed...", "-t", " "],
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

    def on_section_button_clicked(self, button_name):
        if button_name == "Chrome":
            self.show_dialog_options("google-chrome")
        elif button_name == "Chromium":
            self.show_dialog_options("chromium")
        elif button_name == "Firefox":
            self.show_dialog_options("firefox")
        elif button_name == "Opera":
            self.show_dialog_options("opera")
        elif button_name == "Palemoon":
            self.show_dialog_options("palemoon")
        elif button_name == "Vivaldi":
            self.show_dialog_options("vivaldi")
        elif button_name == "VirtualBox":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/virtualbox-builder.sh")
        elif button_name == "VirtualBox Guest Additions":    
            subprocess.call(["/opt/porteux-scripts/gtkdialog.py", "-p", "This module is meant to be built and loaded inside VirtualBox."])
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/virtualbox-guestadditions-builder.sh")
        elif button_name == "Nvidia 5xx":
            subprocess.call(["/opt/porteux-scripts/gtkdialog.py", "-p", "Nvidia driver will be loaded after the system is restarted."])
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/nvidia-builder.sh")
        elif button_name == "Devel Kit":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/devel-builder.sh")
        elif button_name == "Notepad++ (Next)":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/notepadnext-builder.sh")
        elif button_name == "VSCode (Codium)":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/vscode-builder.sh")
        elif button_name == "OnlyOffice":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/onlyoffice-builder.sh")
        elif button_name == "Cemu (Wii U)":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/cemu-builder.sh")
        elif button_name == "PCSX2 (PS2)":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/pcsx2-builder.sh")
        elif button_name == "Steam":
            subprocess.call(["/opt/porteux-scripts/gtkdialog.py", "-p", "Steam requires multilib, also available in the app store."])
            steamFolderDialog = GtkFolder(self, "Steam")
            response = steamFolderDialog.run()
            if response == Gtk.ResponseType.OK:
                self.execute_external_script("/opt/porteux-scripts/porteux-app-store/steam-builder.sh " + steamFolderDialog.get_result())
            steamFolderDialog.destroy()
        elif button_name == "Teams":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/teams-builder.sh")
        elif button_name == "Telegram":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/telegram-builder.sh")
        elif button_name == "WhatsApp (WALC)":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/whatsapp-builder.sh")
        elif button_name == "Crippled Sources":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/crippled-sources-builder.sh")
        elif button_name == "Etcher":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/etcher-builder.sh")
        elif button_name == "Multilib Lite":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/multilib-builder.sh")
        elif button_name == "Wine":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/wine-builder.sh")
        elif button_name == "yt-dlp":
            self.execute_external_script("/opt/porteux-scripts/porteux-app-store/yt-dlp-builder.sh")

    def on_dialog_combobox_channel_changed(self, combobox, combobox_language):
        combobox_language.set_sensitive(True)

    def on_dialog_combobox_language_changed(self, combobox, button_download):
        button_download.set_sensitive(True)

    def on_dialog_button_download_clicked(self, button, application, combobox_channel, combobox_language, dialog):
        channel = combobox_channel.get_active_text()
        language = combobox_language.get_active_text()
        self.execute_external_script("/opt/porteux-scripts/porteux-app-store/browser-builder.sh {0} {1} {2}".format(application, channel, language))
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
        self.add_folder_button.connect("clicked", self.on_add_folder_button_clicked)
        self.grid.attach(self.add_folder_button, 30, 0, 1, 1)
        self.vb.add(self.grid)
        self.show_all()

    def on_add_folder_button_clicked(self, button):
        dir_dialog = Gtk.FileChooserDialog(title = "Choose Folder", parent = self, action = Gtk.FileChooserAction.SELECT_FOLDER)
        dir_dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, "Select", Gtk.ResponseType.OK)
        dir_dialog.set_default_size(400, 280)
        response = dir_dialog.run()
        
        if Gtk.ResponseType.OK == response:
            self.src_dir = dir_dialog.get_filename() + '/steam'
            self.entry.set_text(self.src_dir)

        dir_dialog.destroy()
        
    def on_response(self, widget, response_id):
        self.result = self.entry.get_text()

    def get_result(self):
        return self.result

class Application(Gtk.Application):
    def __init__(self, *args, **kwargs):
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

if __name__ == "__main__":
    app = Application()
    app.run(None)
