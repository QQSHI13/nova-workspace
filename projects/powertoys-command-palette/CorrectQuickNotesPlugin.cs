// Correct using directives for PowerToys CmdPal (Command Palette)
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using Microsoft.PowerToys.CmdPal; // THIS IS THE CORRECT NAMESPACE!
using Windows.Win32;
using Windows.Win32.Foundation;
using Windows.Win32.UI.WindowsAndMessaging;

namespace QuickNotesPlugin;

// Correct interface: ICmdPalPlugin (not ICommandPalettePlugin)
public class CorrectQuickNotesPlugin : ICmdPalPlugin
{
    public string Id => "QuickNotes";
    public string Name => "Quick Notes";
    public string Description => "Create notes in Notepad";
    public Icon Icon => SystemIcons.Application;

    // Correct method: GetQueryResults (not GetResults)
    public IEnumerable<ICmdPalResult> GetQueryResults(string query)
    {
        List<ICmdPalResult> results = new List<ICmdPalResult>();
        string lowerQuery = query.ToLower();

        // 1. Open Notepad
        if (string.IsNullOrEmpty(query) || lowerQuery.Contains("notepad") || lowerQuery.Contains("open"))
        {
            results.Add(new CmdPalResult
            {
                Title = "Open Notepad",
                Subtitle = "Create a new note in ~/notes/",
                Icon = this.Icon,
                // Correct action: Execute (not Action)
                Execute = () =>
                {
                    string home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                    string notesDir = Path.Combine(home, "notes");
                    Directory.CreateDirectory(notesDir);
                    string filename = DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss") + ".txt";
                    string fullPath = Path.Combine(notesDir, filename);
                    File.Create(fullPath).Close();
                    Process.Start(new ProcessStartInfo("notepad.exe", fullPath)?.Dispose();
                }
            });
        }

        // 2. Settings
        if (string.IsNullOrEmpty(query) || lowerQuery.Contains("settings"))
        {
            results.Add(new CmdPalResult
            {
                Title = "Settings",
                Subtitle = "Coming soon!",
                Icon = this.Icon,
                Execute = () =>
                {
                    MessageBox.Show(IntPtr.Zero, "Settings coming soon!", "Quick Notes", 
                        MB_ICONINFORMATION);
                }
            });
        }

        // 3. Help
        if (string.IsNullOrEmpty(query) || lowerQuery.Contains("help"))
        {
            results.Add(new CmdPalResult
            {
                Title = "Help",
                Subtitle = "Quick Notes help",
                Icon = this.Icon,
                Execute = () =>
                {
                    string help = "Quick Notes Help:\n\n" +
                                 "- Type 'Open Notepad' to create a new note\n" +
                                 "- Notes saved to C:\\Users\\<you>\\notes\\\n" +
                                 "- Files named with date/time";
                    MessageBox.Show(IntPtr.Zero, help, "Quick Notes Help", MB_ICONINFORMATION);
                }
            });
        }

        return results;
    }
}
