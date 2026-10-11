#!/usr/bin/env python3
import subprocess
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gtk, Gdk, GLib

GLib.set_prgname("power_popup")

class PowerPopup(Gtk.Window):
    def __init__(self):
        super().__init__(title="Power Menu")
        self.set_resizable(False)
        self.set_decorated(False)

        self.has_entered = False
        self.connect("enter-notify-event", self.on_enter)
        self.connect("leave-notify-event", self.on_leave)
        GLib.timeout_add_seconds(4, self.timeout_check)

        card = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        card.set_name("main-card")
        self.add(card)

        # Botão Reiniciar
        btn_reboot = Gtk.Button()
        btn_reboot.set_name("reboot-btn")
        btn_reboot.set_relief(Gtk.ReliefStyle.NONE)
        box_reboot = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        lbl_reboot_icon = Gtk.Label(label="󰜉")
        lbl_reboot_text = Gtk.Label(label="Reiniciar")
        box_reboot.pack_start(lbl_reboot_icon, False, False, 0)
        box_reboot.pack_start(lbl_reboot_text, False, False, 0)
        btn_reboot.add(box_reboot)
        btn_reboot.connect("clicked", self.on_reboot)
        card.pack_start(btn_reboot, False, False, 0)

        # Botão Desligar
        btn_poweroff = Gtk.Button()
        btn_poweroff.set_name("poweroff-btn")
        btn_poweroff.set_relief(Gtk.ReliefStyle.NONE)
        box_power = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        lbl_power_icon = Gtk.Label(label="")
        lbl_power_text = Gtk.Label(label="Desligar")
        box_power.pack_start(lbl_power_icon, False, False, 0)
        box_power.pack_start(lbl_power_text, False, False, 0)
        btn_poweroff.add(box_power)
        btn_poweroff.connect("clicked", self.on_poweroff)
        card.pack_start(btn_poweroff, False, False, 0)

        css = Gtk.CssProvider()
        css.load_from_data(b"""
            window {
                background-color: transparent;
            }
            #main-card {
                background-color: #21222c;
                border: 1px solid #44475a;
                border-radius: 12px;
                padding: 8px 10px;
            }
            button {
                background-color: #282a36;
                border: 1px solid #44475a;
                border-radius: 8px;
                padding: 6px 12px;
                color: #f8f8f2;
                font-family: "JetBrainsMono Nerd Font", monospace;
                font-size: 12px;
            }
            #reboot-btn:hover {
                background-color: #ffb86c;
                border-color: #ffb86c;
                color: #282a36;
            }
            #poweroff-btn:hover {
                background-color: #ff5555;
                border-color: #ff5555;
                color: #282a36;
            }
        """)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def on_enter(self, widget, event):
        self.has_entered = True

    def on_leave(self, widget, event):
        if event.detail == Gdk.NotifyType.INFERIOR:
            return False
        if self.has_entered:
            Gtk.main_quit()

    def timeout_check(self):
        if not self.has_entered:
            Gtk.main_quit()
        return False

    def on_reboot(self, btn):
        subprocess.run(["systemctl", "reboot"])

    def on_poweroff(self, btn):
        subprocess.run(["systemctl", "poweroff"])

if __name__ == "__main__":
    win = PowerPopup()
    win.show_all()
    Gtk.main()
