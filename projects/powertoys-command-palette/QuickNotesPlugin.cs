using Microsoft.PowerToys.CommandPalette;
using System.Diagnostics;
using System.Drawing;
using System.IO;

namespace QuickNotesCommandPalette;

public class QuickNotesPlugin : ICommandPalettePlugin
{
    public string Id => "QuickNotes";
    public string Name => "Quick Notes";
    public string Description => "Open Notepad, settings, or help for Quick Notes";
    public Image Icon => SystemIcons.Application.ToBitmap();

    public IEnumerable<ICommandPaletteResult> GetResults(string query)
    {
        var results = new List<ICommandPaletteResult>();

        // Command 1: Open Notepad
        if (string.IsNullOrWhiteSpace(query) || "open notepad".Contains(query.ToLower()))
        {
            results.Add(new CommandPaletteResult
            {
                Title = "Open Notepad",
                Subtitle = "Create a new note in Notepad",
                Icon = Icon,
                Action = () =>
                {
                    // Create notes directory if it doesn't exist
                    var notesDir = Path.Combine(
                        Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
                        "notes"
                    );
                    Directory.CreateDirectory(notesDir);

                    // Create a new text file with timestamp
                    var filename = DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss") + ".txt";
                    var filepath = Path.Combine(notesDir, filename);
                    File.Create(filepath).Close();

                    // Open the file in Notepad
                    Process.Start(new ProcessStartInfo
                    {
                        FileName = "notepad.exe",
                        Arguments = filepath,
                        UseShellExecute = true
                    });
                }
            });
        }

        // Command 2: Settings
        if (string.IsNullOrWhiteSpace(query) || "settings".Contains(query.ToLower()))
        {
            results.Add(new CommandPaletteResult
            {
                Title = "Settings",
                Subtitle = "Open Quick Notes settings",
                Icon = Icon,
                Action = () =>
                {
                    // TODO: Implement settings window
                    MessageBox.Show("Settings coming soon!", "Quick Notes", 
                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            });
        }

        // Command 3: Help
        if (string.IsNullOrWhiteSpace(query) || "help".Contains(query.ToLower()))
        {
            results.Add(new CommandPaletteResult
            {
                Title = "Help",
                Subtitle = "Show Quick Notes help",
                Icon = Icon,
                Action = () =>
                {
                    var helpText = @"Quick Notes Help

- Open Notepad: Creates a new note in ~/notes/
- Settings: Coming soon!
- Help: Shows this help

Notes are saved as timestamped .txt files in your user profile's notes folder.";

                    MessageBox.Show(helpText, "Quick Notes Help", 
                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            });
        }

        return results;
    }
}
